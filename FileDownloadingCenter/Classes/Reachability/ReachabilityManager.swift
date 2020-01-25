//
//  DownloadManager.swift
//  MP3Quran
//
//  Created by Ahmad Atef on 6/19/16.
//  Copyright © 2016 Smartech-Solutions. All rights reserved.
//

import Foundation
import Reachability

public class ReachabilityManager : NSObject {
    
    public static let shared = ReachabilityManager()
    fileprivate var internalReachability:Reachability?
    
    private override init() {
        
    }
    
    public var reachability: Reachability? {
        
        get {
       
            do {
            
            if internalReachability == nil {
                internalReachability = try Reachability()
            }
       
            guard internalReachability != nil else {
                return nil
            }
            try internalReachability!.startNotifier()
                
        } catch {
            print("Unable to start notifier")
        }
        
        return internalReachability
        
        }
        
    }
    
}
