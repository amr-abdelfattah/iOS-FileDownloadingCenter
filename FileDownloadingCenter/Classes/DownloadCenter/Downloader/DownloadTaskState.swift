//
//  DownloadTaskState.swift
//  Al-Mushaf
//
//  Created by Amr Elsayed on 8/13/17.
//  Copyright © 2017 SmarTech. All rights reserved.
//

import Foundation

public enum DownloadState : String {
    case pending
    case ready
    case downloading
    case paused
    case completed
    case error
    case cancel
}

public protocol DownloadTaskStateDelegate {
    func state(didChangeTo newState: DownloadTaskState)
}

public class DownloadTaskState : NSObject {
    
    public var state : DownloadState? { return nil }
    var delegate : DownloadTaskStateDelegate?
    
    func ready() -> DownloadTaskState? {
        return nil
    }
    
    func start() -> DownloadTaskState? {
        return nil
    }
    
    func pause() -> DownloadTaskState? {
        return nil
    }
    
    func resume() -> DownloadTaskState? {
        return nil
    }
    
    func stop() -> DownloadTaskState? {
        return nil
    }
}

class PendingState : DownloadTaskState {
    
    override var state: DownloadState? {
        return .pending
    }
    
    override func ready() -> DownloadTaskState? {
        let newState = ReadyState()
        delegate?.state(didChangeTo: newState)
        return newState
    }
    
    override func stop() -> DownloadTaskState? {
        let newState = CancelState()
        delegate?.state(didChangeTo: newState)
        return newState
    }
    
}

class ReadyState : DownloadTaskState {
    
    override var state: DownloadState? {
        return .ready
    }
    
    override func start() -> DownloadTaskState? {
        let newState = DownloadingState()
        delegate?.state(didChangeTo: newState)
        return newState
    }
    
    override func stop() -> DownloadTaskState? {
        let newState = CancelState()
        delegate?.state(didChangeTo: newState)
        return newState
    }
    
}

class PausedState : DownloadTaskState {
    
    override var state: DownloadState? {
        return .paused
    }
    
    override func resume() -> DownloadTaskState? {
        let newState = DownloadingState()
        delegate?.state(didChangeTo: newState)
        return newState
    }
    
    override func stop() -> DownloadTaskState? {
        let newState = CancelState()
        delegate?.state(didChangeTo: newState)
        return newState
    }
    
}

class DownloadingState : DownloadTaskState {
    
    override var state: DownloadState? {
        return .downloading
    }
    
    override func pause() -> DownloadTaskState? {
        let newState = PausedState()
        delegate?.state(didChangeTo: newState)
        return newState
    }
    
    override func stop() -> DownloadTaskState? {
        let newState = CancelState()
        delegate?.state(didChangeTo: newState)
        return newState
    }
    
}

class CompleteState : DownloadTaskState {
    
    override var state: DownloadState? {
        return .completed
    }
    
}

class ErrorState : DownloadTaskState {
    
    override var state: DownloadState? {
        return .error
    }
    
    override func resume() -> DownloadTaskState? {
        let newState = DownloadingState()
        delegate?.state(didChangeTo: newState)
        return newState
    }
    
    override func stop() -> DownloadTaskState? {
        let newState = CancelState()
        delegate?.state(didChangeTo: newState)
        return newState
    }
    
}

class CancelState : DownloadTaskState {
    
    override var state: DownloadState? {
        return .cancel
    }
    
}
