//
//  VideoServiceMock.swift
//  KinescopeSDKTests
//
//  Created by Никита Коробейников on 24.03.2021.
//

@testable import KinescopeSDK

final class VideoServiceMock: VideosService {

    // MARK: - Properties

    var singleVideoMock: [String: Result<KinescopeVideo, Error>] = [:]

    // MARK: - Methods

    func getVideo(by id: String, completion: @escaping (Result<KinescopeVideo, Error>) -> Void) {
        if let result = singleVideoMock[id] {
            completion(result)
        } else {
            fatalError("Cannot find mock for getVideo by \(id)")
        }
    }

}
