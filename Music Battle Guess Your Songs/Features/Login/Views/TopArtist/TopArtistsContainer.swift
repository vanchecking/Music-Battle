import UIKit

// MARK: - Cell

final class ArtistCell: UICollectionViewCell {

    static let reuseId = "ArtistCell"

    private let artistView = TopArtistView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(artistView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        artistView.frame = contentView.bounds
    }

    func configure(with artistImage: ArtistImage) {
        let placeholder = UIImage(named: artistImage.assetPlaceholder)
        artistView.configure(image: artistImage.loadedImage,
                             placeholder: placeholder)
    }
}

// MARK: - Constants for Layout and Scrolling

private struct LayoutConstants {
    static let itemWidth: CGFloat = 80                  // Width of each artist cell
    static let itemHeight: CGFloat = 100                // Height of each artist cell
    static let minimumLineSpacing: CGFloat = 24         // Spacing between items in the collection view
    static let itemSpacingTotal: CGFloat = itemWidth + minimumLineSpacing // Total horizontal space per item including spacing
    static let duplicationCount: Int = 5                 // Number of times the artist arrays are duplicated to enable infinite scrolling. Minimum 5 for proper behavior.
    static let scrollSpeed: CGFloat = 0.4                // Speed at which the collections auto-scroll horizontally
}

// MARK: - Carousel

final class TopArtistsCarouselView: UIView {

    // MARK: - State

    private var didSetupInitialPosition = false
    private var displayLink: CADisplayLink?

    // MARK: - UI

    private var topCollection: UICollectionView!
    private var bottomCollection: UICollectionView!

    // MARK: - Data

    private var topData: [ArtistImage] = []
    private var bottomData: [ArtistImage] = []

    // MARK: - Init

    override init(frame: CGRect) {
        assert(LayoutConstants.duplicationCount >= 5,
               "Duplication count must be at least 5 to ensure proper infinite scrolling behavior.")
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    deinit {
        displayLink?.invalidate()
    }

    // MARK: - Setup

    private func setup() {

        let layout = createLayout()

        topCollection = UICollectionView(frame: .zero,
                                         collectionViewLayout: layout)

        bottomCollection = UICollectionView(frame: .zero,
                                            collectionViewLayout: createLayout())

        [topCollection, bottomCollection].forEach {

            $0.backgroundColor = .clear
            $0.showsHorizontalScrollIndicator = false
            $0.isScrollEnabled = false
            $0.dataSource = self
            $0.delegate = self
            $0.register(ArtistCell.self,
                        forCellWithReuseIdentifier: ArtistCell.reuseId)

            addSubview($0)
        }
    }

    private func createLayout() -> UICollectionViewFlowLayout {

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = LayoutConstants.minimumLineSpacing
        layout.itemSize = CGSize(width: LayoutConstants.itemWidth,
                                 height: LayoutConstants.itemHeight)

        return layout
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()

        let half = bounds.height / 2

        topCollection.frame = CGRect(
            x: 0,
            y: 0,
            width: bounds.width,
            height: half
        )

        bottomCollection.frame = CGRect(
            x: 0,
            y: half,
            width: bounds.width,
            height: half
        )
    }

    // MARK: - Configure

    /// Configures the carousel with a list of artist images.
    /// The list is split into two halves for top and bottom collections,
    /// and each half is duplicated multiple times to enable infinite scrolling.
    func configure(with artists: [ArtistImage]) {

        guard artists.count >= 2 else { return }

        // Split the artists array approximately in half
        let middleIndex = artists.count / 2

        let topPart = Array(artists[..<middleIndex])
        let bottomPart = Array(artists[middleIndex...])

        // Duplicate each half duplicationCount times to create a large data set for infinite scrolling
        topData = Array(repeating: topPart,
                        count: LayoutConstants.duplicationCount).flatMap { $0 }

        bottomData = Array(repeating: bottomPart,
                           count: LayoutConstants.duplicationCount).flatMap { $0 }

        didSetupInitialPosition = false

        topCollection.reloadData()
        bottomCollection.reloadData()

        DispatchQueue.main.async { [weak self] in
            self?.scrollToMiddle()
        }
    }

    // MARK: - Infinite Scrolling Setup

    /// Scrolls both collections to the middle of their duplicated data sets.
    /// This allows the illusion of infinite scrolling by resetting position before bounds are reached.
    private func scrollToMiddle() {

        guard !didSetupInitialPosition,
              topData.count > 0 else { return }

        didSetupInitialPosition = true

        let middle = topData.count / 2

        topCollection.scrollToItem(
            at: IndexPath(item: middle, section: 0),
            at: .left,
            animated: false
        )

        bottomCollection.scrollToItem(
            at: IndexPath(item: middle, section: 0),
            at: .left,
            animated: false
        )

        startAutoScroll()
    }

    // MARK: - Auto Scroll

    /// Starts the CADisplayLink to update the scroll position continuously.
    private func startAutoScroll() {

        displayLink?.invalidate()

        displayLink = CADisplayLink(
            target: self,
            selector: #selector(updateScroll)
        )

        displayLink?.add(to: .main, forMode: .common)
    }

    @objc private func updateScroll() {

        autoScroll(collection: topCollection,
                   speed: LayoutConstants.scrollSpeed)

        autoScroll(collection: bottomCollection,
                   speed: -LayoutConstants.scrollSpeed)
    }

    /// Handles automatic scrolling of a collection view by a fixed speed.
    /// Resets the scroll position to the middle when reaching bounds to create infinite scrolling effect.
    /// - Parameters:
    ///   - collection: The UICollectionView to scroll.
    ///   - speed: The horizontal scroll speed (positive or negative).
    private func autoScroll(collection: UICollectionView,
                            speed: CGFloat) {

        var offset = collection.contentOffset
        offset.x += speed
        collection.contentOffset = offset

        let totalItems = collection.numberOfItems(inSection: 0)
        let middleIndex = totalItems / 2
        let originalCount = totalItems / LayoutConstants.duplicationCount

        // Calculate current item index based on offset and item width + spacing
        let currentIndex = Int(offset.x / LayoutConstants.itemSpacingTotal)
        // When scrolling too far to the left, reset to middle
        if currentIndex < middleIndex - originalCount {
            collection.scrollToItem(
                at: IndexPath(item: middleIndex, section: 0),
                at: .left,
                animated: false
            )
        }
        // When scrolling too far to the right, reset to middle
        if currentIndex >= middleIndex + originalCount {
            collection.scrollToItem(
                at: IndexPath(item: middleIndex, section: 0),
                at: .left,
                animated: false
            )
        }
    }
}

// MARK: - DataSource and Delegate

extension TopArtistsCarouselView:
    UICollectionViewDataSource,
    UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {

        return topData.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath)
    -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ArtistCell.reuseId,
            for: indexPath
        ) as? ArtistCell else {
            return UICollectionViewCell()
        }

        if collectionView == topCollection {
            cell.configure(with: topData[indexPath.item])
        } else {
            cell.configure(with: bottomData[indexPath.item])
        }

        return cell
    }
}
