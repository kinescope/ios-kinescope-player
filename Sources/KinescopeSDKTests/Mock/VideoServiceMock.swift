//
//  VideoServiceMock.swift
//  KinescopeSDKTests
//
//  Created by Никита Коробейников on 24.03.2021.
//

@testable import KinescopeSDK
import GoSwiftyM3U8

final class VideoServiceMock: VideosService {

    // MARK: - Properties

    var allVideosMock: [Int: Swift.Result<AllVideosResponse, Error>] = [:]
    var singleVideoMock: [String: Swift.Result<KinescopeVideo, Error>] = [:]

    // MARK: - Methods

    func getAll(request: KinescopeVideosRequest,
                completion: @escaping (Swift.Result<AllVideosResponse, Error>) -> Void) {
        if let result = allVideosMock[request.page] {
            completion(result)
        } else {
            fatalError("Cannot find mock for getAll page \(request.page)")
        }
    }

    func getVideo(by id: String, completion: @escaping (Swift.Result<KinescopeVideo, Error>) -> Void) {
        if let result = singleVideoMock[id] {
            completion(result)
        } else {
            fatalError("Cannot find mock for getVideo by \(id)")
        }
    }


    func fetchPlaylist(video: KinescopeVideo, completion: @escaping (M3U8Manager.Result<MasterPlaylist>) -> (Void)) {
    }

}
