//
//  KinescopeInspectableMock.swift
//  KinescopeSDKTests
//
//  Created by Никита Коробейников on 29.03.2021.
//

@testable import KinescopeSDK
import GoSwiftyM3U8

final class KinescopeInspectableMock: KinescopeInspectable {

    // MARK: - Spy Properties

    private(set) var listRequests = [KinescopeVideosRequest]()
    private(set) var videoRequests = [String]()

    // MARK: - Mock Properties

    var listSuccessMock: [Int: ([KinescopeVideo], KinescopeMetaData)] = [:]
    var videoSuccessMock: [String: KinescopeVideo] = [:]

    // MARK: - Methods

    func list(request: KinescopeVideosRequest,
              onSuccess: @escaping (([KinescopeVideo], KinescopeMetaData)) -> Void,
              onError: @escaping (KinescopeInspectError) -> Void) {
        listRequests.append(request)

        if let result = listSuccessMock[request.page] {
            onSuccess(result)
        } else {
            onSuccess(([], .init(pagination: .init(page: request.page,
                                                   perPage: request.perPage,
                                                   total: 0))))
        }
    }

    func video(id: String, onSuccess: @escaping (KinescopeVideo) -> Void, onError: @escaping (KinescopeInspectError) -> Void) {
        videoRequests.append(id)

        if let result = videoSuccessMock[id] {
            onSuccess(result)
        } else {
            onSuccess(.stub())
        }
    }

    func fetchPlaylist(video: KinescopeVideo, completion: @escaping (M3U8Manager.Result<MasterPlaylist>) -> (Void)) {
    }

    func fetchPlaylist(link: String, completion: @escaping (M3U8Manager.Result<MasterPlaylist>) -> (Void)) {
    }

}
