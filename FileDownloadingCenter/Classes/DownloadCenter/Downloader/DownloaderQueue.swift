//
//  DownloaderQueue.swift
//  Al-Mushaf
//
//  Created by Amr Elsayed on 8/13/17.
//  Copyright © 2017 SmarTech. All rights reserved.
//

import Foundation

public enum QueueState {
    case enqueued
    case paused
    case pending
    case notExist
}

public enum DownloaderQueueNotification : String {
    case downloader_state_changed = "state_changed"
    case downloader_progress_updated = "progress_updated"
    case queue_progress_updated = "queue_progress_updated"
}

protocol DownloaderQueueDelegate : DownloaderDelegate {
    
    func queue(didPending downloader: FileDownloader)
    func queueDidProgressUpdate()
}

public class DownloaderQueue : NSObject {
    
    public static let shared = DownloaderQueue()
    private let downloadersDispatchQueue = DispatchQueue(label: "downloaders")
    public static let DEFAULT_QUEUE_CAPACITY = 120
    
    var queueCapacity = DownloaderQueue.DEFAULT_QUEUE_CAPACITY
    public var totalProgress : Float!
    fileprivate let sessionCenter = SessionCenter.shared
    fileprivate var enqueuedDownloaders = SafeDictionary<String, FileDownloader>() //[String : FileDownloader]()
    fileprivate var pendingDownloaders = SafeDictionary<String, FileDownloader>() //= [String : FileDownloader]()
    fileprivate var pausedDownloaders = SafeDictionary<String, FileDownloader>() //= [String : FileDownloader]()
    
    private var capacityAvailable : Bool {
        return enqueuedDownloaders.count < queueCapacity
    }
    
    private override init() {}
    
    public func enqueue(url: String, identifier: String, fileLocation: URL, configuration: SessionConfigurationProtocol) {
        
        let itemDownloader = sessionCenter.fileDownloader(withIdentifier: identifier, url: URL(string: url)!, fileLocation: fileLocation, configuration: configuration, downloaderDelegate: self)

        if !isExist(identifier: identifier) {
            enqueue(downloader: itemDownloader)
        }
        
    }
    
    public func enqueue(downloader: FileDownloader) {
        
        if capacityAvailable {
            
            appendToEnqueuedTasks(downloader: downloader)
            //            return .running
        } else {
            
            appendToPendingTasks(downloader: downloader)
            //            return .pending
        }
        
    }

    public func enqueue(downloaders: [FileDownloader]) {
        
        for downloader in downloaders {
            enqueue(downloader: downloader)
        }
    }
    
    public func start(identifier: String) {
        
        if isEnqueued(identifier: identifier) {
            let downloader = getEnqueuedDownloader(identifier: identifier)!
            _ = downloader.start()
        }
        
    }
    
    public func pause(identifier: String) {
        
        if isEnqueued(identifier: identifier) {
            let downloader = getEnqueuedDownloader(identifier: identifier)!
            _ = downloader.pause()
        }
        
    }
    
    public func stop(identifier: String) {
        
        if isExist(identifier: identifier) {
            if let downloader = getEnqueuedDownloader(identifier: identifier) {
                _ = downloader.stop()
            } else if let downloader = getPendingDownloader(identifier: identifier) {
                _ = downloader.stop()
            } else if let downloader = getPausedDownloader(identifier: identifier) {
                _ = downloader.stop()
            }
        }
        
    }
    
    public func resume(identifier: String) {
        
        if isPaused(identifier: identifier) {
            let downloader = getPausedDownloader(identifier: identifier)!
            removeFromPausedTasks(downloader: downloader)
            enqueue(downloader: downloader)
//            _ = downloader.resume()
        }
        
    }
    
}

// MARK :- Downloader Queue Delegate

extension DownloaderQueue : DownloaderQueueDelegate {
    
    internal func queue(didPending downloader: FileDownloader) {
        notify(fileDownloader: downloader, didChangeState: .pending)
    }
    
    internal func queueDidProgressUpdate() {
        
            totalProgress = calculateTotalRunningDownloadersProgress()
            notify(queue: self, didUpdateProgress: totalProgress)
        
    }
    
    public func state(didChangeTo newState: DownloadTaskState) {
        
        let downloader = newState as! FileDownloader
        manageState(didChangeDownloaderState: downloader)
        notify(fileDownloader: downloader, didChangeState: newState.state!)
    }
    
    internal func progress(_ identifier: String) -> Float {
        
        let enqueuedProgress = self.enqueuedDownloaders[identifier]?.progress ?? 0
        return enqueuedProgress
            + (self.pausedDownloaders[identifier]?.progress ?? 0.0)
            + (self.pendingDownloaders[identifier]?.progress ?? 0.0)
        
    }
    
//    func downloaderFileLocation(_ downloader : FileDownloader) -> URL {
//        return downloader.fileLocation
//    }
    
    public func download(_ downloader: FileDownloader, didProgressUpdate progress: Float) {
        notify(fileDownloader: downloader, didUpdateProgress: progress)
        queueDidProgressUpdate()
    }
    
    private func manageState(didChangeDownloaderState downloader: FileDownloader) {
        
        updateQueue(didChangeDownloaderState: downloader)
        
        switch downloader.state! {
        
        case .ready:
            start(identifier: downloader.identifier)
        
        default:
            break
            
        }
        
    }
    
    private func updateQueue(didChangeDownloaderState downloader: FileDownloader) {
        
        let state = downloader.state!
        
        switch state {
        
        case .paused, .error:
            removeFromEnqueuedTasks(downloader: downloader)
            appendToPausedTasks(downloader: downloader)
            enqeueNextPending()
          
        case .cancel:
            removeFromPausedTasks(downloader: downloader)
            removeFromPendingTasks(downloader: downloader)
            fallthrough
            
        case .completed:
            removeFromEnqueuedTasks(downloader: downloader)
            enqeueNextPending()
            
        default:
            break
            
        }
        
    }
    
    private func calculateTotalRunningDownloadersProgress() -> Float {
        
        print("CALC TOTAL RUNNING")
            var totalProgress : Float = 0.0
       /*     let enqueuedDownloaders = self.enqueuedDownloaders
        print("CALC TOTAL RUNNING QUEUE \(enqueuedDownloaders)")
            for (_, downloader) in enqueuedDownloaders {
                print("CALC TOTAL RUNNING \(downloader), \(downloader.progress)")
                totalProgress += downloader.progress
            }
            print("CALC TOTAL RUNNING QUEUE COUNT \(enqueuedDownloaders.count)")
            totalProgress /= Float(enqueuedDownloaders.count)*/
            return totalProgress
        
    }
    
}

extension DownloaderQueue {
    
    
    func notify(fileDownloader: FileDownloader, didChangeState state: DownloadState) {
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: DownloaderQueueNotification.downloader_state_changed.rawValue), object: fileDownloader, userInfo: ["state" : state])
        
        debugPrint("DOWNLOADER STATE \(fileDownloader) = \(state)")
    }
    
    func notify(fileDownloader: FileDownloader, didUpdateProgress progress: Float) {
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: DownloaderQueueNotification.downloader_progress_updated.rawValue), object: fileDownloader, userInfo: ["progress" : progress])
        debugPrint("DOWNLOADER PROGRESS \(  fileDownloader.identifier) = \(progress)")
    }
    
    func notify(queue: DownloaderQueue, didUpdateProgress progress: Float) {
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: DownloaderQueueNotification.queue_progress_updated.rawValue), object: self, userInfo: ["progress" : progress])
        debugPrint("QUEUE PROGRESS \(queue) = \(progress)")
    }
    
}


// MARK :- Queue Functions

extension DownloaderQueue {
    
    fileprivate func isExist(identifier: String) -> Bool {
        return isEnqueued(identifier: identifier)
            || isPending(identifier: identifier)
            || isPaused(identifier: identifier)
    }
    
    func stateFor(identifier: String) -> QueueState {
        
        var queueState = QueueState.notExist
        if isEnqueued(identifier: identifier) {
            queueState = .enqueued
        } else if isPending(identifier: identifier) {
            queueState = .pending
        } else if isPaused(identifier: identifier) {
            queueState = .paused
        }
        return queueState
        
    }
    
    func downloaders() -> [FileDownloader] {
        
         let downloaders = self.enqueuedDownloaders.values
            + self.pendingDownloaders.values
            + self.pausedDownloaders.values
        
       // let downloaders = Array(self.enqueuedDownloaders.values) + Array(self.pendingDownloaders.values) + Array(self.pausedDownloaders.values)
        
        return downloaders
        
    }
    
    fileprivate func isPending(identifier: String) -> Bool {
        return pendingDownloaders[identifier] != nil
    }
    
    fileprivate func isPaused(identifier: String) -> Bool {
        return pausedDownloaders[identifier] != nil
    }
    
    fileprivate func isEnqueued(identifier: String) -> Bool {
        return enqueuedDownloaders[identifier] != nil
    }
    
    fileprivate func getEnqueuedDownloader(identifier: String) -> FileDownloader? {
        return enqueuedDownloaders[identifier]
    }
    
    fileprivate func getPendingDownloader(identifier: String) -> FileDownloader? {
        return pendingDownloaders[identifier]
    }
    
    fileprivate func getPausedDownloader(identifier: String) -> FileDownloader? {
        return pausedDownloaders[identifier]
    }
    
    fileprivate func appendToEnqueuedTasks(downloader: FileDownloader) {
        
        debugPrint("ENQUEUED "+downloader.identifier+"  "+downloader.url.absoluteString)
        enqueuedDownloaders[downloader.identifier] = downloader
        if downloader.state! == .pending {
            _ = downloader.ready()
        } else {
            _ = downloader.resume()
        }
        
    }
    
    fileprivate func appendToPendingTasks(downloader: FileDownloader) {
        pendingDownloaders[downloader.identifier] = downloader
        queue(didPending: downloader)
    }
    
    fileprivate func appendToPausedTasks(downloader: FileDownloader) {
        pausedDownloaders[downloader.identifier] = downloader
    }
    
    
    fileprivate func removeFromEnqueuedTasks(downloader: FileDownloader) {
        enqueuedDownloaders.removeValue(forKey: downloader.identifier)
    }
    
    fileprivate func removeFromPendingTasks(downloader: FileDownloader) {
        pendingDownloaders.removeValue(forKey: downloader.identifier)
    }
    
    fileprivate func removeFromPausedTasks(downloader: FileDownloader) {
        pausedDownloaders.removeValue(forKey: downloader.identifier)
    }
    
    fileprivate func enqeueNextPending() {
        
        if let readyDownloader = getNextPendingTask() {
            removeFromPendingTasks(downloader: readyDownloader)
            enqueue(downloader: readyDownloader)
        }
        
    }
    
    fileprivate func getNextPendingTask() -> FileDownloader? {
        
        var downloader : FileDownloader?
        
        if let nextIdentifier = pendingDownloaders.keys.first {
            downloader = pendingDownloaders[nextIdentifier]
        }
        return downloader
        
    }
    
}
