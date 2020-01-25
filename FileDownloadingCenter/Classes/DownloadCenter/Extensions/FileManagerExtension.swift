//
//  FileManager.swift
//  Al-Mushaf
//
//  Created by Amr Elsayed on 8/6/17.
//  Copyright © 2017 SmarTech. All rights reserved.
//

import Foundation

public extension FileManager {
    
    public func read(url: URL) -> Data? {
        
        var fileData: Data?
        do {
            let fileHandle = try FileHandle(forReadingFrom: url)
            fileData = fileHandle.readDataToEndOfFile();
        } catch {
            print(error)
        }
        
        return fileData
        
    }
    
    public func write(toFileLocation fileLocation: URL, fromLocation currentLocation: URL) {
        
        do {
            
            let fileManager = FileManager.default
            
            //            if let filePath = pathForFile(fileName: fileName) {
            
            //                let fileURL = URL(fileURLWithPath: filePath)
            let folderUrl = fileLocation.deletingLastPathComponent()
            createDirectoryIfNotExists(folderUrl: folderUrl)
            try fileManager.moveItem(at: currentLocation, to: fileLocation)
            
            //            }
        } catch {
            print(error)
        }
    }
    
    public func createDirectoryIfNotExists(folderUrl: URL) {
        
        do {
            
            let fileManager = FileManager.default
            
            if !fileManager.fileExists(fileLocation: folderUrl) {
                
                try fileManager.createDirectory(at: folderUrl, withIntermediateDirectories: true, attributes: nil)
                
            }
            
        } catch let error as NSError {
            print(error)
        }
        
    }
    
    public func delete(fileLocation: URL) -> Bool {
        
        do {
            //        if let filePath = pathForFile(fileName: fileName) {
            
            let fileManager = FileManager.default
            //            let fileURL = URL(fileURLWithPath: filePath)
            try fileManager.removeItem(at: fileLocation)
            return true
            //        }
        }catch {
            print(error)
        }
        return false
    }
    
    public func fileExists(fileLocation : URL) -> Bool {
        
        var exists = false
        //        if let filePath = pathForFile(fileName: fileName) {
        
        let fileManager = FileManager.default
        let filePath = fileLocation.absoluteString.replacingOccurrences(of: "file://", with: "")
        exists = fileManager.fileExists(atPath: filePath.removingPercentEncoding ?? filePath)
        print("CHECK \(exists) && \(filePath)")
        //        }
        
        return exists
    }
    
    public func pathForFile(fileName : String) -> URL? {
        
        var filePathUrl : URL?
        
        if let folderPath = pathForMainFolder() {
            
            let filePath = folderPath + "/" + fileName
            filePathUrl = URL(fileURLWithPath: filePath)
        }
        
        return filePathUrl
    }
    
    public func fileNameFrom(absoluteUrl: URL) -> String {
        
        var urlComponents = absoluteUrl.absoluteString.components(separatedBy: "/")
        let fileName = "\(urlComponents[urlComponents.count-2])-\(urlComponents[urlComponents.count-1])"
        return fileName
        
    }
    
    fileprivate func pathForMainFolder() -> String? {
        
        var folderPath : String?
        //        let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let cacheDirectory = FileManager.SearchPathDirectory.cachesDirectory
        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(cacheDirectory, userDomainMask, true)
        if (paths.count > 0) {
            folderPath = String(paths[0])
        }
        return folderPath
    }
    
}

