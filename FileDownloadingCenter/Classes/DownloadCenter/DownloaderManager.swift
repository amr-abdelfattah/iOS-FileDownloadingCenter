//
//  DownloaderManager.swift
//  Al-Mushaf
//
//  Created by Amr Elsayed on 8/13/17.
//  Copyright © 2017 SmarTech. All rights reserved.
//

import Foundation

public enum DownloaderManagerNotification : String {
    case downloaded_file_deleted = "file_deleted"
}

public class DownloaderManager {
    
    public static let shared = DownloaderManager()
    let downloaderQueue : DownloaderQueue
    
    init() {
        self.downloaderQueue = DownloaderQueue.shared
//        self.downloaderQueue.queueCapacity = 150
    }
    
}

// MARK :- FileManager and Storage Functions

public extension DownloaderManager {
    
    public func delete(downloadableItem : DownloadableItem) {
        
        if FileManager.default.delete(fileLocation: downloadableItem.downloadFileLocation) {
            notifyFileDeleted(downloadableItem: downloadableItem, withError: false)
        } else {
            notifyFileDeleted(downloadableItem: downloadableItem, withError: true)
        }
        
    }
    
    func notifyFileDeleted(downloadableItem : DownloadableItem, withError: Bool) {
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: DownloaderManagerNotification.downloaded_file_deleted.rawValue), object: downloadableItem, userInfo: ["error" : withError])
    }
}

// MARK :- Queue Download Functions

public extension DownloaderManager {

    public func queueStateFor(downloadableItem : DownloadableItem) -> QueueState {
        
        return self.downloaderQueue.stateFor(identifier: downloadableItem.downloadableItemIdentifier)
    }
    
    public func downloadableItems(downloadableItemProvider : DownloadableItemProvider) -> [DownloadableItem] {
        
        var downloadableItems = [DownloadableItem]()
        let downloaders = self.downloaderQueue.downloaders()
        for downloader in downloaders {
            if let downloadableItem = downloadableItemProvider.downloadableItem(withIdentifier: downloader.identifier) {
                downloadableItems.append(downloadableItem)
            }
        }
        return downloadableItems
        
    }
    
    public func restore(downloadableItemProvider: DownloadableItemProvider, configuration: SessionConfigurationProtocol, finished: @escaping ([FileDownloader]) -> Void) {
        
        SessionCenter.shared.restoreRunningDownloaders(configuration: configuration, downloaderDelegate: self.downloaderQueue, downloadableItemProvider: downloadableItemProvider) {
            (restoredDownloaders) in
            
            self.downloaderQueue.enqueue(downloaders: restoredDownloaders)
            finished(restoredDownloaders)
            
        }
        
    }
    
    public func enqueue(downloadableItem : DownloadableItem, configuration: SessionConfigurationProtocol) -> Bool {
        
//        if !downloadableItem.isDownloaded() {
        
        
        self.downloaderQueue.enqueue(url: downloadableItem.downloadUrl.absoluteString, identifier: downloadableItem.downloadableItemIdentifier, fileLocation: downloadableItem.downloadFileLocation, configuration: configuration)
        return true
//        } else {
//            return false
//        }
    
    }
    
    /*func start(downloadableItem : DownloadableItem) {
        
        self.downloaderQueue.start(identifier: downloadableItem.identifier())
        
    }*/
    
    public func pause(downloadableItem : DownloadableItem) {
        
       self.downloaderQueue.pause(identifier: downloadableItem.downloadableItemIdentifier)
        
    }
    
    public func stop(downloadableItem : DownloadableItem) {
        
        self.downloaderQueue.stop(identifier: downloadableItem.downloadableItemIdentifier)
    }
    
    
    public func resume(downloadableItem : DownloadableItem) {
        
        self.downloaderQueue.resume(identifier: downloadableItem.downloadableItemIdentifier)
        
    }

}

internal extension DownloaderManager {
    
    func progress(downloadableItem: DownloadableItem) -> Float {
        
        return self.downloaderQueue.progress(downloadableItem.downloadableItemIdentifier)
        
    }
    
}
