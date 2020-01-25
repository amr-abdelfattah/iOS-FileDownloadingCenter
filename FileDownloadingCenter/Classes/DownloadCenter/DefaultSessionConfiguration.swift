//
//  SessionConfiguration.swift
//  Al-Mushaf
//
//  Created by Amr Elsayed on 9/10/17.
//  Copyright © 2017 SmarTech. All rights reserved.
//

import Foundation

public class DefaultSessionConfiguration : SessionConfigurationProtocol {
    
    public static let instance = DefaultSessionConfiguration()
    
    private init() {}
    
    public var sessionBackgroundIdentifier: String =  "my.smartech.pkFileDownloadingCenter.background" 
    
    
    public var isDiscretionary: Bool = false
    
    
    public var allowsCellularAccess: Bool = true
    
    
}
