//
//  BaseDownloaderManagerProtocol.swift
//
//  Created by Amr Elsayed on 12/5/19.
//  Copyright © 2019 SmarTech. All rights reserved.
//

import Foundation

public protocol DownloaderListener : class {
    
    func downloader(didChangeState fileDownloader: FileDownloader)
    func file(didDelete downloadableItem : DownloadableItem, withError hasError:Bool)
    func downloader(didUpdateProgress fileDownloader: FileDownloader)
    func queue(didUpdateProgress downloaderQueue: DownloaderQueue)
    
}

public class ListenerItem {
    
    weak var listener: DownloaderListener?
    var identifiers : [String]?
    
    init (_ downloaderListener: DownloaderListener, forIdentifiers identifiers: [String]? = nil) {
        
        self.listener = downloaderListener
        self.identifiers = identifiers
        
    }
    
}

public protocol ModelDownloaderManagerProtocol {
    
    var downloaderManager : DownloaderManager { get }
    var downloaderListeners : [ListenerItem] { set get }
    func canDownload(withShowingMessage: Bool) -> (canDownload: Bool, errorMessage: String?)
    func showErrorMessage(errorMessage: String)
//    var noInternetConnectionMessage : String { get }
//    var celluarNetworkInternetConnectionMessage : String { get }
    func handleDownloadContinouty() -> Bool
    func updateItemDownloadFlag(itemIndentifier: String, isDownloaded: Bool)
    var sessionConfiguration: SessionConfigurationProtocol { get }
//    func allowCelluarNetworkDownload() -> Bool
    var downloadableItemProvider: DownloadableItemProvider? { get }
    
}

public extension ModelDownloaderManagerProtocol {
    
    var downloaderManager : DownloaderManager {
        
        return DownloaderManager.shared
        
    }
    
}

// Listeners
public extension ModelDownloaderManagerProtocol {

    func index(of downloaderListener : DownloaderListener) -> Int? {
        
        return downloaderListeners.firstIndex(where: {
         //   print("\($0.listener)    VS  \(downloaderListener)   RS   \($0.listener === downloaderListener)")
            return $0.listener === downloaderListener
            })
        
    }
    
    mutating func addListener(downloaderListener : DownloaderListener, forDownloadableItems items: [DownloadableItem]?) {
        
        if let listenerIndex = self.index(of: downloaderListener) {
            self.downloaderListeners[listenerIndex].identifiers = self.getIdentifiers(of: items)
            
        } else {
            self.downloaderListeners.append(ListenerItem(downloaderListener, forIdentifiers: self.getIdentifiers(of: items)))
            
        }
        
    }
    
    mutating func addListener(downloaderListener : DownloaderListener, forDownloadableItem item: DownloadableItem? = nil) {
        
        self.addListener(downloaderListener: downloaderListener, forDownloadableItems: item == nil ? nil : [item!])
        
    }
    
    mutating func removeListener(downloaderListener : DownloaderListener) {
      
        print("Downloader Remove \(downloaderListener)")
       
        self.clearDead()
        
       if let index = self.index(of: downloaderListener) {
         downloaderListeners.remove(at: index)
        print("Downloader Remove DONE")
        
        }
        
    }
    
    func isEnabledListener(_ downloaderListener: ListenerItem?, forIdentifier downloadableItemIdentifier: String?) -> Bool {
        
        return ( downloaderListener?.identifiers == nil ||
            ( downloaderListener?.identifiers != nil && downloaderListener?.identifiers?.contains(downloadableItemIdentifier ?? "") ?? false ) )
        
    }
    
    func getIdentifiers(of downloadableItems: [DownloadableItem]?) -> [String]? {
        
        guard downloadableItems != nil else {
            return nil
        }
        
        var identifiers = [String]()
        
        for downloadableItem in downloadableItems! {
            identifiers.append(downloadableItem.downloadableItemIdentifier)
        }
        
        return identifiers
        
    }
    
    private mutating func clearDead () {
        
        self.downloaderListeners.removeAll {
            
            nil == $0.listener
            
        }
        
    }
    
}


// Downloader
public extension ModelDownloaderManagerProtocol {
    
    func stop(downloadableItem : DownloadableItem) {
        
        self.downloaderManager.stop(downloadableItem: downloadableItem)
    }
    
    func stateFor(downloadableItem : DownloadableItem) -> QueueState {
        
        return self.downloaderManager.queueStateFor(downloadableItem : downloadableItem)
    }
    
    func downloadableItems(downloadableItemProvider: DownloadableItemProvider) -> [DownloadableItem] {
        
        return self.downloaderManager.downloadableItems(downloadableItemProvider: downloadableItemProvider)
    }
    
}

// Actions
public extension ModelDownloaderManagerProtocol {
    
    func handleDownloadAction(downloadableItem : DownloadableItem) {
        
            updateDownloadState(downloadableItem: downloadableItem)

    }
    
    func updateDownloadState(downloadableItem : DownloadableItem) {
        
            switch self.downloaderManager.queueStateFor(downloadableItem : downloadableItem) {
                
            case .enqueued:
                self.downloaderManager.pause(downloadableItem : downloadableItem)
                
            case .paused:
                self.download(downloadableItem: downloadableItem)
                
            case .pending:
                self.downloaderManager.stop(downloadableItem : downloadableItem)
                
            case .notExist:
                self.download(downloadableItem: downloadableItem)
                
            }
        
    }
    
    func download(downloadableItem: DownloadableItem) {
            
        if self.canDownload(withShowingMessage: true).canDownload {
                
                switch self.downloaderManager.queueStateFor(downloadableItem : downloadableItem) {
                    
                case .enqueued, .pending:
                    break
                case .paused:
                    self.downloaderManager.resume(downloadableItem : downloadableItem)
                case .notExist:
                    _ = self.downloaderManager.enqueue(downloadableItem : downloadableItem, configuration: self.sessionConfiguration)
                }
                
            }
        
    }
    
    func download(downloadableItems: [DownloadableItem]){
        
        print("DOWNLOAD ALL BEFORE")
       // download(downloadableItem: downloadableItems[0])
        
        downloadableItems.forEach({
          downloadableItem in
            
            print("DOWNLOAD ALL \(downloadableItem.downloadUrl)")
            
            if downloadableItem.canBeDownloaded() {
            
                print("DOWNLOAD ALL IN")
                
                download(downloadableItem: downloadableItem)
                
            }
            print("DOWNLOAD ALL OUT")
            
        })
        
        print("DOWNLOAD ALL AFTER")
        
    }
    
    func hold(downloadableItem: DownloadableItem) {
   
        switch self.downloaderManager.queueStateFor(downloadableItem : downloadableItem) {
            
        case .enqueued:
            self.downloaderManager.pause(downloadableItem : downloadableItem)
            
        case .pending:
            self.downloaderManager.stop(downloadableItem : downloadableItem)
            
        case .paused, .notExist:
            break
            
        }
        
    }
    
    func hold(downloadableItems: [DownloadableItem]) {
        
        print("DOWNLOAD ALL HOLD BEFORE")
        
        downloadableItems.forEach({
            downloadableItem in
            
            if downloadableItem.canBeDownloaded() {
            
                hold(downloadableItem: downloadableItem)
                
            }
        
        })
        
        print("DOWNLOAD ALL HOLD AFTER")
        
    }
    
    func delete(downloadableItem : DownloadableItem) {
        self.downloaderManager.delete(downloadableItem: downloadableItem)
    }
    
    func handleDownloadContinouty() -> Bool {
        
        let downloadAbility = self.canDownload(withShowingMessage: false)
        
        if !downloadAbility.canDownload {
            
            if let downloadableItemProvider = self.downloadableItemProvider {
             
                let downloadableItems = self.downloaderManager.downloadableItems(downloadableItemProvider: downloadableItemProvider)
                
                self.hold(downloadableItems: downloadableItems)
                
            }
            
            if let errorMessage = downloadAbility.errorMessage {
                self.showErrorMessage(errorMessage: errorMessage)
            }
            
            return false
            
        }
        
        return true
        
    }
    
    
}
