//
//  File.swift
//  
//
//  Created by Amr Elsayed on 10/17/19.
//

import Foundation

open class ModelDownloaderManager : ModelDownloaderManagerProtocol {
    
    public var downloaderListeners = [ListenerItem]()
    
    public init() {
        addDownloadObservers()
    }
    
    deinit {
        removeObservers()
    }
    
    open func addDownloadObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(downloader(didChangeState:)), name: Notification.Name(DownloaderQueueNotification.downloader_state_changed.rawValue), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(downloader(didUpdateProgress:)), name: Notification.Name(DownloaderQueueNotification.downloader_progress_updated.rawValue), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(queue(didUpdateProgress:)), name: Notification.Name(DownloaderQueueNotification.queue_progress_updated.rawValue), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(file(didDelete:)), name: Notification.Name(DownloaderManagerNotification.downloaded_file_deleted.rawValue), object: nil)
        
    }
    
    open func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    open var noInternetConnectionMessage : String {
        
        "No Internet Connection !"
        
    }
    
    open var celluarNetworkInternetConnectionMessage : String {
        
        "Connection may be not allow to establish this downloading session, you may review settings page to enable downloading over cellular connection"
        
    }
    
    open func allowCelluarNetworkDownload() -> Bool {
        
        return true
        
    }
    
    open var downloadableItemProvider: DownloadableItemProvider? {
        return nil
    }
    
    open var sessionConfiguration: SessionConfigurationProtocol {
        
        return DefaultSessionConfiguration.instance
        
    }
    
    open func updateItemDownloadFlag(itemIndentifier: String, isDownloaded: Bool) {
           
       }
       
    open func showErrorMessage(errorMessage: String) {
           
    }
    
}

// Observers
public extension ModelDownloaderManager {
    
    @objc fileprivate func downloader(didChangeState notification: NSNotification) {
        
        print("LISTENER: didChangeState 1")
        DispatchQueue.global(qos: .background).async {
            
            let downloader = notification.object as! FileDownloader
            
            // Update Database with Download Flag
            if downloader.state == .completed {
                
                DispatchQueue.main.sync {
                    
                    self.updateItemDownloadFlag(itemIndentifier: downloader.identifier, isDownloaded: true)
                    
                }
                
            }
            
            print("CHANGE_STATE: OUTSIDE \(downloader.identifier)   \(self.downloaderListeners.count)")
            
            print("CHANGE_STATE - BEFORE")
            
            for downloaderListener in self.downloaderListeners {
                
                if self.isEnabledListener(downloaderListener, forIdentifier: downloader.identifier) {
                    print("CHANGE_STATE: INSIDE \(downloader.identifier)")
                    print("NEED TO POST CHANGE STATE FOR \(downloader.identifier)")
                    DispatchQueue.main.async {
                        
                       print("CHANGE_STATE - NOTIFYING")
                        downloaderListener.listener?.downloader(didChangeState: downloader)
                        
                    }
                    
                }
                
            }
            
            print("CHANGE_STATE - AFTER")
            print("LISTENER: didChangeState 2")
            
        }
        
    }
    
    @objc fileprivate func file(didDelete notification: NSNotification) {
        
        let downloadableItem = notification.object as! DownloadableItem
        let hasError = notification.userInfo?["error"] as! Bool
        
        // Update Database with Download Flag
       self.updateItemDownloadFlag(itemIndentifier: downloadableItem.downloadableItemIdentifier, isDownloaded: false)

        print("LISTENER: didDelete 1")

        for downloaderListener in self.downloaderListeners {
            
            if self.isEnabledListener(downloaderListener, forIdentifier: downloadableItem.downloadableItemIdentifier)  {
                
                 downloaderListener.listener?.file(didDelete: downloadableItem, withError: hasError)
                
            }
           
        }
        
        print("LISTENER: didDelete 2")
        
    }
    
    
    @objc fileprivate func downloader(didUpdateProgress notification: NSNotification) {
        
       // print("LISTENER: didUpdateProgress 1")
        
        guard self.handleDownloadContinouty() else {
            return
        }

        DispatchQueue.global(qos: .background).async {
            
            let downloader = notification.object as! FileDownloader
            
            for downloaderListener in self.downloaderListeners {
                
                    if self.isEnabledListener(downloaderListener, forIdentifier: downloader.identifier) {
                
                        print("NEED TO POST PROGRESS FOR \(downloader.identifier)")
                        DispatchQueue.main.async {
                            downloaderListener.listener?.downloader(didUpdateProgress: downloader)
                        
                        }
                    
                    }
                
            }
            
            print("LISTENER: didUpdateProgress 2")
            
        }
        
    }
    
    @objc fileprivate func queue(didUpdateProgress notification: NSNotification) {
        
        print("LISTENER: didUpdateProgress queue 1")
        
        guard self.handleDownloadContinouty() else {
            return
        }
        
      /*  DispatchQueue.global(qos: .background).async {
            
           /* let queue = notification.object as! DownloaderQueue
            
            for downloaderListener in self.downloaderListeners {
                DispatchQueue.main.async {
                    

                }
            }*/
            print("LISTENER: didUpdateProgress queue 2")
        }*/
        
    }

}
