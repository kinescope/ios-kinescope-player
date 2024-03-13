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
        executionQueue.async { [weak self] in
            guard let url = URL(string: url),
                    let data = try? Data(contentsOf: url) else {
                return
            }
            let image = UIImage(data: data)
            self?.completionQueue.async {
                imageView.contentMode = .scaleAspectFill
                imageView.image = image
            }
        }
    }

}
