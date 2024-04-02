//
//  MockDownloadURLSession.swift
//  KinescopeSDKTests
//
//  Created by Никита Гагаринов on 11.04.2021.
//

@testable import KinescopeSDK
import Foundation

final class MockURLSessionDownloadTask: URLSessionDownloadTask {

    override var currentRequest: URLRequest? {
        return URLRequest(url: url)
    }

    private let closure: (URLSessionDownloadTask, MockTaskState) -> Void
    private let url: URL
    private let result: MockResult

    init(url: URL,
         result: MockResult,
         closure: @escaping (URLSessionDownloadTask, MockTaskState) -> Void) {
        self.url = url
        self.result = result
        self.closure = closure
    }

    override func resume() {
        closure(self, .resume(result))
    }

    override func cancel() {
        closure(self, .cancel)
    }

    override func suspend() {
        closure(self, .suspend)
    }

}

final class MockDownloadURLSession: URLSession {

    var nextResult: MockResult = .success
    // task : isActive
    private var tasksCache: [URLSessionTask: Bool] = [:]
    private var newDelegate: URLSessionDelegate?

    override var delegate: URLSessionDelegate? {
        return newDelegate
    }

    init(delegate: URLSessionDelegate?) {
        self.newDelegate = delegate
        super.init()
    }

    override func getAllTasks(completionHandler: @escaping ([URLSessionTask]) -> Void) {
        return completionHandler(Array(tasksCache.keys))
    }

    override func downloadTask(with url: URL) -> URLSessionDownloadTask {
        return MockURLSessionDownloadTask(url: url, result: nextResult) { task, state in
            switch state {
            case .resume(let result):
                switch result {
                case .success:
                    self.tasksCache[task] = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        guard self.tasksCache[task] ?? false else {
                            return
                        }
                        (self.delegate as? URLSessionDownloadDelegate)?.urlSession(self,
                                                                                   downloadTask: task,
                                                                                   didFinishDownloadingTo: url)
                        self.tasksCache.removeValue(forKey: task)
                    }
                case .error:
                    let err = ServerErrorWrapper(error: .init(code: 1, message: "", detail: ""))
                    (self.delegate as? URLSessionDownloadDelegate)?.urlSession?(self, task: task, didCompleteWithError: err.error)
                }
            case .cancel:
                self.tasksCache.removeValue(forKey: task)
            case .suspend:
                self.tasksCache[task] = false
            }
        }
    }

}
