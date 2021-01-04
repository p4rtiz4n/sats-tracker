//
// Created by p4rtiz4n on 28/12/2020.
//

import Foundation

class AsyncOperation: Operation {

    private var _finished = false
    private var _executing = false

    override var isFinished: Bool {
        _finished
    }

    override var isExecuting: Bool {
        _executing
    }

    override var isAsynchronous: Bool {
        true
    }

    func setIsFinishedWithKVO(value: Bool) {
        willChangeValue(forKey: "isFinished")
        _finished = value
        didChangeValue(forKey: "isFinished")
    }

    func setIsExecutingWithKVO(value: Bool) {
        willChangeValue(forKey: "isExecuting")
        _executing = value
        didChangeValue(forKey: "isExecuting")
    }

    override func start() {
        guard !isCancelled else {
            asyncFinish()
            return
        }

        setIsExecutingWithKVO(value: true)
        asyncStart()
    }

    /// Override this (no need to call super) to start your code.
    func asyncStart() {

    }

    /// Call this when you're done.
    func asyncFinish() {
        setIsExecutingWithKVO(value: false)
        setIsFinishedWithKVO(value: true)
    }
}
