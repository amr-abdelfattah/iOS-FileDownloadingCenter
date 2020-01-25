//
//  DownloadFileManager.swift
//  FileDownloadingCenter_Example
//
//  Created by admin on 1/26/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation

class DownloadFileLocationManager {
    
    static let shared = DownloadFileLocationManager()
    
    func pathForMainFolder() -> String? {
        
        var folderPath : String?
        let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)
        if (paths.count > 0) {
            
            folderPath = paths[0]
            if let _ = folderPath {
                
                if let bundleId = Bundle.main.bundleIdentifier {
                    
                    folderPath = folderPath!.appending("/\(bundleId)")
                    
                }
                
                FileManager.default.createDirectoryIfNotExists(folderUrl: URL(string: folderPath!)!)
                
            }
            
        }
        return folderPath
    }
    
    public func pathForFile(folderPath: String?, fileName : String) -> URL? {
        
        var filePathUrl : URL?
        
        if let mainFolderPath = pathForMainFolder() {
            
            var completePath = mainFolderPath
            
            if let _ = folderPath {
            
                completePath = mainFolderPath + "/" + folderPath!
                FileManager.default.createDirectoryIfNotExists(folderUrl: URL(string: (completePath.contains("file://") ? "" : "file://") + completePath)!)
                
            }
            
            completePath = completePath + "/" + fileName
            filePathUrl = URL(fileURLWithPath: completePath)
            
        }
        
        return filePathUrl
        
    }
    
}
