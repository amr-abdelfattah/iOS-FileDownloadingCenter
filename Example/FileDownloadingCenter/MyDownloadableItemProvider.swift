//
//  MyDownloadableItemProvider.swift
//  FileDownloadingCenter_Example
//
//  Created by admin on 1/25/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import FileDownloadingCenter

class MyDownloadableItemProvider : DownloadableItemProvider {
       
       public static let shared = MyDownloadableItemProvider()
       
       func downloadableItem(withIdentifier identifier: String) -> DownloadableItem? {
           
           // Return your item using the identifier (URL)
        return TracksRepository.shared.get(url: URL(string: identifier)!)
        
       }
       
       func downloadableItem(withUrl url: URL) -> DownloadableItem? {
           
           // Return your item using the identifier (URL)
           return TracksRepository.shared.get(url: url)
        
       }
       
}
