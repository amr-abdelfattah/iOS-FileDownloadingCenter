//
//  DownloadTaskOperation.swift
//  Al-Mushaf
//
//  Created by Amr Elsayed on 8/13/17.
//  Copyright © 2017 SmarTech. All rights reserved.
//

import Foundation


class DownloadTaskOperation : DownloadTaskState {
    
    private var currentState : DownloadTaskState?
    let url : URL!
    var task : URLSessionDownloadTask?
    var data : Data?
    var sessionData : SessionData!
    var identifier: String!
    
    override var state: DownloadState? {
        return currentState?.state
    }
    
    init(identifier: String, url : URL, sessionData : SessionData) {
        
        self.identifier = identifier
        self.url = url
        self.sessionData = sessionData
        self.currentState = PendingState()
        
    }
    
    init(identifier: String, runningDownloadTask: URLSessionDownloadTask, sessionData: SessionData) {
        
        self.identifier = identifier
        self.task = runningDownloadTask
        self.url = runningDownloadTask.currentRequest!.url!
        self.sessionData = sessionData
        self.currentState = runningDownloadTask.state == .running
            ? DownloadingState()
            : PendingState()
        
    }
    
    init(identifier: String, url: URL, downloadedData: Data?, sessionData: SessionData) {
        
        self.identifier = identifier
        self.url = url
        self.data = downloadedData
        self.sessionData = sessionData
        self.currentState = ErrorState()
        
    }
    
    override func ready() -> DownloadTaskState? {
        
        if let state = self.currentState!.ready() {
            
            updateState(state: state)
        }
        return self
        
    }
    
    override func start() -> DownloadTaskState? {
        
        if let state = self.currentState!.start() {
            
            self.task = self.sessionData.session.downloadTask(with: self.url)
            self.task!.resume()
            
            updateState(state: state)
        }
        return self
        
    }
    
    override func pause() -> DownloadTaskState? {
        
        if let state = self.currentState!.pause() {
            
            print("PAUSED TASK BEFORE \(self.identifier)")
            
            self.task!.cancel(byProducingResumeData: { [weak self] in
//                if self.data == nil || ($0 != nil && $0!.count > self.data!.count) {
//                print("\(self.data?.count)  DATA COUNT \($0?.count)")
                print("PAUSED TASK \(self?.identifier)")
                if $0 != nil {
                    self?.data = $0 // Retain cycle check !!
                }
                
                print("PAUSED TASK AFTER \(self?.identifier)")
                
              ///  self?.updateState(state: state)
//                }
            })
//            self.task = nil
            
            updateState(state: state)
        }
        return self
        
    }
    
    override func resume() -> DownloadTaskState? {
        
        if let state = self.currentState!.resume() {
            
            if self.data == nil {
                self.task = self.sessionData.session.downloadTask(with: self.url)
            } else {
                self.task = self.sessionData.session.downloadTask(withResumeData: self.data!)
            }
//            if self.task?.state == .suspended {
//                self.task = self.sessionData.session.downloadTask(with: self.url)
//            }
//            print("TASKSTATE B \(self.task!.state.rawValue)")
            
            self.task!.resume()
//            print("TASKSTATE A \(self.task!.state.rawValue)")
//            self.data = nil
            
            updateState(state: state)
        }
        
        return self
    }
    
    override func stop() -> DownloadTaskState? {
        
        if let state = self.currentState!.stop() {
            
            self.task?.cancel()
            self.task = nil
            self.data = nil
            
            updateState(state: state)
            
        }
        return self
    }
    
    
    func didComplete() {
        
        let newState = CompleteState()
        updateState(state: newState)
        self.task = nil
        self.data = nil
        
    }

    func didError(withData data: Data?) {
        
        let newState = ErrorState()
        self.data = data
        updateState(state: newState)
        //        self.task = nil
        //        self.data = nil
        
    }

    fileprivate func updateState(state : DownloadTaskState) {
        
        self.currentState = state
        self.delegate?.state(didChangeTo: self)
    }
    
}
