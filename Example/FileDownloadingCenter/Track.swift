//
//  Track.swift
//  FileDownloadingCenter_Example
//
//  Created by Amr El-Sayed on 1/25/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import FileDownloadingCenter

class Track: DownloadableItem, Decodable {

    enum CodingKeys: String, CodingKey {
      case downloadUrl = "url", title
    }
    
    var title: String
    var downloadUrl : URL
    var downloadableItemDescription : Description {
        return Description(title: self.title, subTitle: "")
    }
    var downloadFileLocation : URL {
        
        let fileLocation = DownloadFileLocationManager.shared.pathForFile(folderPath: "Tracks", fileName: self.downloadUrl.pathComponents.last ?? self.title)
        
        return fileLocation ?? URL(string: "file://notexist.com")!
        
    }
   
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.downloadUrl = try container.decode(URL.self, forKey: .downloadUrl)
        
    }
    
    init(downloadUrl: URL, title: String) {

        self.downloadUrl = downloadUrl
        self.title = title
        
    }
    
}
