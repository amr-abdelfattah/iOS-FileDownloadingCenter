//
//  SafeDictionary.swift
//  FileDownloadingCenter
//
//  Created by Amr Elsayed on 7/11/19.
//

import Foundation

class SafeDictionary<K: Hashable, V> {
    
    private var dictionary = [K: V]()
    private let concurrentQueue = DispatchQueue(label: "com.threadsafe.dictionary", attributes: .concurrent)
   
    var count : Int {
        
        var _count = 0
        print("DOWNLOAD ALL COUNT BEFORE")
        self.concurrentQueue.sync {
            
            _count = self.dictionary.count
            
        }
        print("DOWNLOAD ALL COUNT AFTER")
        return _count
        
    }
    
    var keys : [K] {
        
        var _keys = [K]()
        print("DOWNLOAD ALL KEYS BEFORE")
        self.concurrentQueue.sync {
            
            _keys = Array(self.dictionary.keys)
        }
        print("DOWNLOAD ALL KEYS AFTER")
        return _keys
        
    }
    
    var values : [V] {
        
        var _values = [V]()
        print("DOWNLOAD ALL VALUES BEFORE")
        self.concurrentQueue.sync {
            
            _values = Array(self.dictionary.values)
        }
        print("DOWNLOAD ALL VALUES AFTER")
        return _values
        
    }
    
    subscript(key: K) -> V? {
        
        get {
            
            var value : V?
            print("DOWNLOAD ALL GET BEFORE")
            self.concurrentQueue.sync {
                
                print("DOWNLOAD ALL GET INSIDE")
                value = self.dictionary[key]
                
            }
            
            print("DOWNLOAD ALL GET DONE")
            return value
            
        }
        
        set {
            
            print("DOWNLOAD ALL SET BEFORE \(key)")
            self.concurrentQueue.async(flags: .barrier) {
//          self.concurrentQueue.sync {
            
                print("DOWNLOAD ALL SET DONE \(key)")
                self.dictionary[key] = newValue
                
            }
            
        }
        
    }
    
    func removeValue(forKey key: K) {
        
        print("DOWNLOAD ALL REMOVE BEFORE \(key)")
        self.concurrentQueue.async(flags: .barrier) {
            
            print("DOWNLOAD ALL REMOVE DONE \(key)")
            self.dictionary.removeValue(forKey: key)
            
        }
        
    }
    
}
