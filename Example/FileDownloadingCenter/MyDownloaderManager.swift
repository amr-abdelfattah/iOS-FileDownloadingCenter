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
    
    override var noInternetConnectionMessage: String {
        
        "No Internet Connection !"
        
    }
    
    override var celluarNetworkInternetConnectionMessage: String {
        
        "Connection may be not allow to establish this downloading session, you may review settings page to enable downloading over cellular connection"
        
    }
    
    override var sessionConfiguration: SessionConfigurationProtocol {
        
        return DownloadSessionConfiguration.instance
        
    }
   
    override var downloadableItemProvider: DownloadableItemProvider? {
    
        return MyDownloadableItemProvider.shared
        
    }
    
    override func allowCelluarNetworkDownload() -> Bool {
        
       return false
        
    }
    
    override func showErrorMessage(errorMessage: String) {
        
        // Show the error Message.
        print(errorMessage)
        
    }
    
    override func updateItemDownloadFlag(itemIndentifier: String, isDownloaded: Bool) {
        
        // item state is changed to isDownloaded, do your staff.
        
    }
    
}
