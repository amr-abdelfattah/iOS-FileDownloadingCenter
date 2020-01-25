//
//  DownloadSessionConfiguration.swift
//  FileDownloadingCenter_Example
//
//  Created by admin on 1/25/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import FileDownloadingCenter

class DownloadSessionConfiguration : SessionConfigurationProtocol {
    
        public static let instance = DownloadSessionConfiguration()
        
        var sessionBackgroundIdentifier: String = "app.example.background"
        var isDiscretionary: Bool = false
        var allowsCellularAccess: Bool = true
    
}
