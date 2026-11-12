//
//  PreviewService.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 27.02.2024.
//

import Foundation
import UIKit

public protocol PreviewService {
    func fetchPreview(for url: String, into imageView: UIImageView)
}

final class PreviewNetworkService: PreviewService {

    // MARK: - Private Properties

    private let executionQueue = DispatchQueue.global(qos: .utility)
    private let completionQueue = DispatchQueue.main

    // MARK: - Public Methods

    func fetchPreview(for url: String, into imageView: UIImageView) {
        let mark = {
            imageView.accessibilityIdentifier = url
        }
        if Thread.isMainThread {
            mark()
        } else {
            completionQueue.async(execute: mark)
        }

        executionQueue.async { [weak self] in
            let image: UIImage?
            if let remote = URL(string: url),
               let data = try? Data(contentsOf: remote) {
                image = UIImage(data: data)
            } else {
                image = nil
            }
            let poster = image ?? .image(named: "defaultPoster")
            self?.completionQueue.async {
                guard imageView.accessibilityIdentifier == url else {
                    return
                }
                imageView.contentMode = .scaleAspectFit
                imageView.image = poster
            }
        }
    }

}
