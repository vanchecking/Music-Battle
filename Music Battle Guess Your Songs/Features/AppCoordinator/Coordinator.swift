//
//  Coordinator.swift
//  Music Battle Guess Your Songs
//
//  Created by PowerMac on 01.03.2026.
//
import UIKit

protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get }
    func start()
}
