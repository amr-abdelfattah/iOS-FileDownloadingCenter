//
//  ViewController.swift
//  FileDownloadingCenter
//
//  Created by amr-abdelfattah on 01/23/2020.
//  Copyright (c) 2020 amr-abdelfattah. All rights reserved.
//

import UIKit
import FileDownloadingCenter

class ViewController: UITableViewController {

    private var tracks: [Track]?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tracks = TracksRepository.shared.list()
        
    }
   
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tracks?.count ?? 0
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "trackCellIdentifier") as? TrackTableViewCell, let track = self.tracks?[indexPath.row] else {
            
            return UITableViewCell()
            
        }
        
        cell.configure(track)
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        if let track = self.tracks?[indexPath.row] {
            
            MyDownloaderManager.shared.download(downloadableItem: track)
            
        }
        
    }
    
}
