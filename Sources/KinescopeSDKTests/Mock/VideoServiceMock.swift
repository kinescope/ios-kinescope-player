//
//  VideoServiceMock.swift
//  KinescopeSDKTests
//
//  Created by Никита Коробейников on 24.03.2021.
//

@testable import KinescopeSDK

final class VideoServiceMock: VideosApiClient {

    // MARK: - Properties

    var allVideosMock: [Int: Result<AllVideosResponse, Error>] = [:]
    var singleVideoMock: [String: Result<KinescopeVideo, Error>] = [:]

    // MARK: - Methods

    func getAll(request: KinescopeVideosRequest,
                completion: @escaping (Result<AllVideosResponse, Error>) -> Void) {
        if let result = allVideosMock[request.page] {
            completion(result)
        } else {
            fatalError("Cannot find mock for getAll page \(request.page)")
        }
    }

    func getVideo(by id: String, completion: @escaping (Result<KinescopeVideo, Error>) -> Void) {
        if let result = singleVideoMock[id] {
            completion(result)
        } else {
            fatalError("Cannot find mock for getVideo by \(id)")
        }
    }

}
