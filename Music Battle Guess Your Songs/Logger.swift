import Foundation

enum Logger {

    static func log(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {

        let fileName = (file as NSString).lastPathComponent
        let className = fileName.replacingOccurrences(of: ".swift", with: "")

        print("📁 \(fileName)\n📍 \(className)\n⚙️ \(function)\n🏁 \(line)\n💬 \(message)")
    }
}
