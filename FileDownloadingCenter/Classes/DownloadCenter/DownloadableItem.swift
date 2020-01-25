//
//  DownloadableFile.swift
//  Al-Mushaf
//
//  Created by Amr Elsayed on 8/28/17.
//  Copyright © 2017 SmarTech. All rights reserved.
//

import Foundation

public struct Description {
    public var title : String
    public var subTitle : String
    
    public init(title: String, subTitle: String) {
        self.title = title
        self.subTitle = subTitle
    }
}

public protocol DownloadableItem {
    
    var downloadUrl : URL { get }
    var downloadableItemIdentifier : String { get }
    var downloadableItemDescription : Description { get }
    var downloadFileLocation : URL { get }
    var itemGroupBy : String? { get }
    func isItemDownloaded() -> Bool
    
}

public extension DownloadableItem {
    
    public func isItemDownloaded() -> Bool {
        print("IS ITEM DOWNLOADED : LIB")
        return FileManager.default.fileExists(fileLocation: downloadFileLocation)
    }
    
    public var downloadableItemIdentifier : String {
        return downloadUrl.absoluteString
    }
    
    public var itemGroupBy : String? {
        return nil
    }
    
    public func canBeDownloaded() -> Bool {
        return !self.isItemDownloaded()
    }
    
}

public extension DownloadableItem {
    
    public var progress : Float {
           return DownloaderManager.shared.progress(downloadableItem: self)
    }
       
}

public protocol DownloadableItemProvider {
    func downloadableItem(withIdentifier identifier: String) -> DownloadableItem?
    func downloadableItem(withUrl url: URL) -> DownloadableItem?
}
