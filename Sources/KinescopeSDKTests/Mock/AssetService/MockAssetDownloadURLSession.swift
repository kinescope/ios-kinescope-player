////
////  MockAssetDownloadURLSession.swift
////  KinescopeSDKTests
////
////  Created by Artemii Shabanov on 12.04.2021.
////
//
//@testable import KinescopeSDK
//import Foundation
//import AVFoundation
//
//final class MockAVAssetDownloadTask: AVAssetDownloadTask {
//
//    override var urlAsset: AVURLAsset {
//        return AVURLAsset(url: url)
//    }
//
//    private let closure: (AVAssetDownloadTask, MockTaskState) -> Void
//    private let url: URL
//    private let result: MockResult
//
//    convenience init(url: URL,
//         result: MockResult,
//         closure: @escaping (AVAssetDownloadTask, MockTaskState) -> Void) {
//        self.url = url
//        self.result = result
//        self.closure = closure
//    }
//
//    override func resume() {
//        closure(self, .resume(result))
//    }
//
//    override func cancel() {
//        closure(self, .cancel)
//    }
//
//    override func suspend() {
//        closure(self, .suspend)
//    }
//
//}
//
//final class MockAVAssetDownloadURLSession: AVAssetDownloadURLSession {
//
//    var nextResult: MockResult = .success
//    // task : isActive
//    private var tasks: [URLSessionTask: Bool] = [:]
//    private var newDelegate: URLSessionDelegate?
//
//    override var delegate: URLSessionDelegate? {
//        return newDelegate
//    }
//
//    convenience init(delegate: URLSessionDelegate?) {
//        self.newDelegate = delegate
//    }
//
//    override func getAllTasks(completionHandler: @escaping ([URLSessionTask]) -> Void) {
//        return completionHandler(Array(tasks.keys))
//    }
//
//    override func makeAssetDownloadTask(asset URLAsset: AVURLAsset,
//                                        assetTitle title: String,
//                                        assetArtworkData artworkData: Data?,
//                                        options: [String: Any]? = nil) -> AVAssetDownloadTask? {
//        return MockAVAssetDownloadTask(url: URLAsset.url, result: nextResult) { task, state in
//            switch state {
//            case .resume(let result):
//                switch result {
//                case .success:
//                    self.tasks[task] = true
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                        guard self.tasks[task] ?? false else {
//                            return
//                        }
//                        (self.delegate as? AVAssetDownloadDelegate)?.urlSession?(self,
//                                                                                 assetDownloadTask: task,
//                                                                                 didFinishDownloadingTo: URLAsset.url)
//                        self.tasks.removeValue(forKey: task)
//                    }
//                case .error:
//                    let err = ServerErrorWrapper(error: .init(code: 1, message: "", detail: ""))
//                    (self.delegate as? URLSessionTaskDelegate)?.urlSession?(self, task: task, didCompleteWithError: err.error)
//                }
//            case .cancel:
//                self.tasks.removeValue(forKey: task)
//            case .suspend:
//                self.tasks[task] = false
//            }
//        }
//    }
//
//}
