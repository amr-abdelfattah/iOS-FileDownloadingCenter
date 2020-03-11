//
//  MyDownloaderManager.swift
//  FileDownloadingCenter_Example
//
//  Created by Amr El-Sayed on 1/25/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import FileDownloadingCenter

class MyDownloaderManager : ModelDownloaderManager {
    
    public static var shared = MyDownloaderManager()
    
    private var noInternetConnectionMessage: String {
        
        "No Internet Connection !"
        
    }
    
    private var celluarNetworkInternetConnectionMessage: String {
        
        "Connection may be not allow to establish this downloading session, you may review settings page to enable downloading over cellular connection"
        
    }
    
    override var sessionConfiguration: SessionConfigurationProtocol {
        
        return DownloadSessionConfiguration.instance
        
    }
   
    override var downloadableItemProvider: DownloadableItemProvider? {
    
        return MyDownloadableItemProvider.shared
        
    }
    
    private func allowCelluarNetworkDownload() -> Bool {
        
       return false
        
    }
    
    override func canDownload(withShowingMessage: Bool = true) -> (canDownload: Bool, errorMessage: String?) {
        
        var _canDownload = false
        var errorMessage: String?
        
        if let connection = ReachabilityManager.shared.reachability?.connection {
            
            switch connection {
                
            case .none, .unavailable:
                errorMessage = self.noInternetConnectionMessage
                _canDownload = false
                
            case .wifi:
                _canDownload = true
                
            case .cellular:
                let allowCelluar = self.allowCelluarNetworkDownload()
                errorMessage = allowCelluar ? nil : self.celluarNetworkInternetConnectionMessage
                _canDownload = allowCelluar
                
            }
            
        }
        
        if withShowingMessage, let errorMessage = errorMessage {
            
            self.showErrorMessage(errorMessage: errorMessage)
            
        }
        
        return (canDownload: _canDownload, errorMessage: errorMessage)
        
    }
    
    override func showErrorMessage(errorMessage: String) {
        
        // Show the error Message.
        print(errorMessage)
        
    }
    
    override func updateItemDownloadFlag(itemIndentifier: String, isDownloaded: Bool) {
        
        // item state is changed to isDownloaded, do your staff.
        
    }
    
}
