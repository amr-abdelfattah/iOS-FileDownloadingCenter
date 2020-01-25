//
//  TracksRepository.swift
//  FileDownloadingCenter_Example
//
//  Created by Amr El-Sayed on 1/25/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation

class TracksRepository {
    
    public static let shared = TracksRepository()
    private var tracks: [Track]?
    
    private init() {
        
        self.load()
        
    }
    
    private func load() {
        
        self.consume(fileName: "tracks", success: { [weak self] tracks in
            
            self?.tracks = tracks
            
        }, failure: { message in
            
            print("Error Parsing Tracks File")
            
        })
        
    }
    
    func list() -> [Track] {
        return self.tracks ?? []
    }
    
    func get(url: URL) -> Track? {
        
        return self.tracks?.filter({ $0.downloadUrl.absoluteString == url.absoluteString }).first
        
    }
    
}

extension TracksRepository {
    
    func consume(fileName: String, success: @escaping (([Track]) -> Void), failure: @escaping ((String) -> Void)) {
            
            if let filePath = Bundle.main.path(forResource: fileName, ofType: "json") {
                
                do {
                    
                    let contentsString = try Data(contentsOf: URL(string: "file://"+filePath)!)
                    
                    let decoder = JSONDecoder()
                    let tracks = try decoder.decode([Track].self, from: contentsString)
                    
                    success(tracks)
                    
                    
                } catch {
                    
                    failure("\(fileName) Can not be loaded")
                    
                }
                
            } else {
                
                failure("\(fileName) is not found")
                
            }
            
        }
        
        private func convertArray(textResponse: String) -> [[String: Any]]? {
            
            if let data = textResponse.data(using: .utf8) {
                
                do {
                    
                    return try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]]
                    
                } catch {
                    
                    print(error.localizedDescription)
                    
                }
                
            }
            
            return nil
            
        }
        
}
