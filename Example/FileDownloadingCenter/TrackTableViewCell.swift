//
//  TrackTableViewCell.swift
//  FileDownloadingCenter_Example
//
//  Created by admin on 1/26/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import FileDownloadingCenter

class TrackTableViewCell: UITableViewCell {

    private var track: Track? {
        
        didSet {
            self.addDownloadObserver()
        }
        
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        self.setIsDownloading(false)
        
    }

    deinit {
        self.removeObservers()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func configure(_ track: Track) {
        
        self.track = track
        self.textLabel?.text = self.track?.downloadableItemDescription.title
//        self.detailTextLabel?.text = self.track?.downloadableItemDescription.subTitle
        
    }

    private func setIsDownloading(_ isDownloading: Bool) {
        
        self.detailTextLabel?.text = isDownloading ? "Downloading ..." : ""
        
    }
    
}


extension TrackTableViewCell : DownloaderListener {

    func addDownloadObserver() {
           
           MyDownloaderManager.shared.addListener(downloaderListener: self, forDownloadableItem: self.track!)
           
    }

    func removeObservers() {
         
         MyDownloaderManager.shared.removeListener(downloaderListener: self)
           
    }
       
       // MARK:- Delegates
       
       private func isCurrentDownloader(downloader: FileDownloader) -> Bool {
           
           return downloader.identifier == self.track?.downloadableItemIdentifier ?? ""
        
       }
       
       func downloader(didChangeState fileDownloader: FileDownloader) {
           
           if self.isCurrentDownloader(downloader: fileDownloader) {
           
               if let state = fileDownloader.state
               {
                   switch state {
                       
                   case .error:
                    self.setIsDownloading(false)
                    print("Downloading Error \(fileDownloader.url)")
                       
                    case .completed:
                        self.setIsDownloading(false)
                        print("Downloading Completed \(fileDownloader.url)")
                       
                   default:
                       break
                       
                   }
               }
            }
       }
       
       func downloader(didUpdateProgress fileDownloader: FileDownloader) {
           
           if self.isCurrentDownloader(downloader: fileDownloader) {
               
            let progress = fileDownloader.progress!
               // Do Your Staff.
            self.setIsDownloading(true)
            
            print("Track Progress \(progress)")
               
           }
           
       }
       
       func queue(didUpdateProgress downloaderQueue: DownloaderQueue) {
           
       }
       
    func file(didDelete downloadableItem: DownloadableItem, withError hasError: Bool) {
        
        print("File is Deleted \(downloadableItem.downloadUrl)")
        
    }
    
}

