//
//  SessionCenter.swift
//  Al-Mushaf
//
//  Created by Amr Elsayed on 8/14/17.
//  Copyright © 2017 SmarTech. All rights reserved.
//

import Foundation

protocol DownloaderSessionDelegate {
    
    func downloadSession(_ sessionData: SessionData, downloader: FileDownloader, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64)
    
    func downloadSession(_ sessionData: SessionData, downloader: FileDownloader, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64)
    
    func downloadSession(_ sessionData: SessionData, downloader: FileDownloader, didFinishDownloadingTo location: URL)
    
    func downloadSession(_ sessionData: SessionData, downloader: FileDownloader, errorWithData data: Data?)
    
    func downloadSessionDidFinishEvents(forBackgroundDownloadSession sessionData: SessionData)
    
    func downloadSession(_ sessionData: SessionData, didBecomeInvalidWithError error: Error?)
    
}

public protocol SessionConfigurationProtocol {
    
    
    var sessionBackgroundIdentifier:String {get}
    
    var isDiscretionary : Bool {
        get
    }
    
    var allowsCellularAccess : Bool {
        get
    }
    
}


public struct SessionData {
    
    var session : URLSession!
    var configuration : URLSessionConfiguration!
    
    public init(configuration: SessionConfigurationProtocol, delegate: URLSessionDelegate, queue: OperationQueue) {
        
//        let operationQueue = OperationQueue()//OperationQueue.main
        initConfiguration(fromConfiguration: configuration)
        initSession(delegate: delegate, queue: queue)
    }
    
    mutating func initConfiguration(fromConfiguration configuration: SessionConfigurationProtocol) {
        
        self.configuration = URLSessionConfiguration.background(withIdentifier: configuration.sessionBackgroundIdentifier)
        self.configuration.isDiscretionary = configuration.isDiscretionary
        self.configuration.allowsCellularAccess = configuration.allowsCellularAccess
        
    }
    
    mutating func initSession(delegate: URLSessionDelegate, queue: OperationQueue) {
        
        self.session = URLSession(configuration: self.configuration, delegate: delegate, delegateQueue: queue)
        
    }
    
}

public class SessionCenter : NSObject {
    
    public var completionHandler : (() -> Void)?
    private var downloaders = SafeDictionary<URL, FileDownloader>() //= [FileDownloader]()
    fileprivate var terminattedDownloadersData = SafeDictionary<URL, Data>() //= [URL : Data]()
    public static let shared = SessionCenter()
    private let queue : OperationQueue = {
        let q = OperationQueue()
//         let q = DispatchQueue.global(qos: .background)
     //   q.maxConcurrentOperationCount = 1
        return q
    }()
    
    private override init() {
    }
    
//    func allowsCellularAccess(configuration: SessionConfigurationProtocol, enabled: Bool) {
//        var sessionData = self.getSessionData(withConfiguration: configuration)
//        sessionData.allowsCellularAccess = enabled
//    }
    
    public func restoreRunningDownloaders(configuration: SessionConfigurationProtocol, downloaderDelegate: DownloaderDelegate, downloadableItemProvider: DownloadableItemProvider, restoredDownloaderCompletion : @escaping ([FileDownloader]) -> Void) {
        
            
        let sessionData = self.getSessionData(withConfiguration: configuration)
        sessionData.session.getTasksWithCompletionHandler () { (_, _, downloadTasks) in
            
            DispatchQueue.main.async {
                
            var restoredDownloaders = [FileDownloader]()
            
            for downloadTask in downloadTasks {
               
                let url = downloadTask.currentRequest!.url!
                if let downloadableItem = downloadableItemProvider.downloadableItem(withUrl: url)
                {
                    let identifier = downloadableItem.downloadableItemIdentifier
                    let fileLocation = downloadableItem.downloadFileLocation
                    
                    var restoredDownloader : FileDownloader?
                    
                    if downloadTask.state == .running {
                        
                        //FileManager.default.fileNameFrom(absoluteUrl: downloadTask.currentRequest!.url!)
                        restoredDownloader = self.fileDownloader(withIdentifier: identifier, fileLocation: fileLocation, runningDownloadTask: downloadTask, sessionData: sessionData, downloaderDelegate: downloaderDelegate)
                    } else if downloadTask.state == .completed {
                        
                        //DispatchQueue.global(qos: .background).sync {
                        
                            print("terminattedDownloadersData Before Read \(url)")
                            let downloadedData = self.terminattedDownloadersData[url]
                            restoredDownloader = self.fileDownloader(withIdentifier: identifier, url: url, fileLocation: fileLocation, downloadedData: downloadedData, sessionData: sessionData, downloaderDelegate: downloaderDelegate)
                            print("terminattedDownloadersData Before Remove \(url)")
                            self.terminattedDownloadersData.removeValue(forKey: url)
                            
                       // }
                        
                    }
                    
                    if restoredDownloader != nil {
                        restoredDownloaders.append(restoredDownloader!)
                    }
                    

                }
            }
                
            restoredDownloaderCompletion(restoredDownloaders)
                
            }
            
        }
        
    }
    
    func fileDownloader(withIdentifier identifier: String, url: URL, fileLocation: URL, configuration: SessionConfigurationProtocol, downloaderDelegate: DownloaderDelegate) -> FileDownloader {
        
        let sessionData = getSessionData(withConfiguration: configuration)
        let fileDownloader = FileDownloader(identifier: identifier, url: url, fileLocation: fileLocation, sessionData: sessionData, delegate: downloaderDelegate)
        registerDownloader(downloader: fileDownloader)
        return fileDownloader
    }
    
    func fileDownloader(withIdentifier identifier: String, fileLocation: URL, runningDownloadTask: URLSessionDownloadTask, sessionData: SessionData, downloaderDelegate: DownloaderDelegate) -> FileDownloader {
        
        let fileDownloader = FileDownloader(identifier: identifier, fileLocation: fileLocation, downloadTask: runningDownloadTask, sessionData: sessionData, delegate: downloaderDelegate)
        registerDownloader(downloader: fileDownloader)
        return fileDownloader
    }

    func fileDownloader(withIdentifier identifier: String, url: URL, fileLocation: URL, downloadedData: Data?, sessionData: SessionData, downloaderDelegate: DownloaderDelegate) -> FileDownloader {
        
        let fileDownloader = FileDownloader(identifier: identifier, url: url, fileLocation: fileLocation, downloadedData: downloadedData, sessionData: sessionData, delegate: downloaderDelegate)
        registerDownloader(downloader: fileDownloader)
        return fileDownloader
    }
    
    private func getSessionData(withConfiguration configuration: SessionConfigurationProtocol) -> SessionData {
        
        let sessionData = SessionData(configuration: configuration, delegate: self, queue: self.queue)
        return sessionData
    }
    
    private func registerDownloader(downloader: FileDownloader) {
        
        self.downloaders[downloader.url] = downloader        
        //self.downloaders.append(downloader)
    }
    
    fileprivate func getDownloader(inSession session: URLSession, task: URLSessionTask) -> FileDownloader? {
        
        var downloader : FileDownloader?
        
        if let url = task.originalRequest?.url, let _downloader = self.downloaders[url], _downloader.sessionData.session == session {
            
            downloader = _downloader
            
        }
        
        return downloader
        
    }

}

// MARK :- URLSessionDownloadDelegate

extension SessionCenter : URLSessionDownloadDelegate {
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
       // let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite);
        
        debugPrint("DELEGATE  didWriteData ")
        
        if let downloader = getDownloader(inSession: session, task: downloadTask) {
        
            debugPrint("DELEGATE  didWriteData \(downloader)")
            
            downloader.sessionDelegate.downloadSession(downloader.sessionData, downloader: downloader, didWriteData: bytesWritten, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
        }
        
        
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        
        debugPrint("DELEGATE  didResumeAtOffset ")
        
        if let downloader = getDownloader(inSession: session, task: downloadTask) {
            
            downloader.sessionDelegate.downloadSession(downloader.sessionData, downloader: downloader, didResumeAtOffset: fileOffset, expectedTotalBytes: expectedTotalBytes)
        }

    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        debugPrint("DELEGATE  didFinishDownloadingTo ")
//        showSuccessDownloadMessage(id: (downloadTask.currentRequest?.url?.absoluteString)!)
        if let downloader = getDownloader(inSession: session, task: downloadTask) {
            debugPrint("DELEGATE  didFinishDownloadingTo FOUNDED")
            downloader.downloadSession(downloader.sessionData, downloader: downloader, didFinishDownloadingTo: location)
        }
        
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    
        debugPrint("DELEGATE  didCompleteWithError \(task.state)")
        
//        do {
        
            if error != nil {
            
            debugPrint("DELEGATE didCompleteWithError ERROR")
            
            let downloader = getDownloader(inSession: session, task: task)
            
            let downloadedData = self.extractDownloadedData(fromError: error!)
            
            if downloader != nil && downloader!.state == .error {
            
            downloader!.downloadSession(downloader!.sessionData, downloader: downloader!, errorWithData: downloadedData)
            
            } else if let taskUrl = task.currentRequest?.url {
            
//                if let downloadedData = downloadedData {
                
                     print("terminattedDownloadersData BEFORE COUNT:  \(terminattedDownloadersData.count)")
                    
                  //  DispatchQueue.global(qos: .background).sync {
                        
                        print("terminattedDownloadersData COUNT:  \(terminattedDownloadersData.count), \(taskUrl)")
                        print("terminattedDownloadersData \(terminattedDownloadersData)")
                        terminattedDownloadersData[taskUrl] = downloadedData
                        
                    //}
                    
                    
//                }
            
            }
            
            }
        
//        } catch let err as NSError {
//
//            print("Error inside didCompleteWithError \(err)")
//        }
        
    }
    
}

// MARK :- URLSessionDelegate

public extension SessionCenter {
    
     func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        
        debugPrint("DELEGATE  urlSessionDidFinishEvents forBackgroundURLSession ")
        if let completionHandler = self.completionHandler {
            completionHandler()
            self.completionHandler = nil
        }
        
    }
    
     func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {

        debugPrint("DELEGATE  didBecomeInvalidWithError ")
    }
}

// MARK :- Resumed Data

extension SessionCenter {
    
    func extractDownloadedData(fromError error: Error) -> Data? {
        
        let nsError = error as NSError
        let data = nsError.userInfo[NSURLSessionDownloadTaskResumeData] as? Data
        print("DATAAA \(data?.count)")
        return data
        
    }

}
