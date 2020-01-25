//
//  FileDownloader.swift
//  Al-Mushaf
//
//  Created by Amr Elsayed on 8/6/17.
//  Copyright © 2017 SmarTech. All rights reserved.
//

import Foundation

public protocol DownloaderDelegate : DownloadTaskStateDelegate {
    
//    func downloaderFileLocation(_ downloader : FileDownloader) -> URL
    func download(_ downloader : FileDownloader, didProgressUpdate progress: Float)
    
}

public class FileDownloader : DownloadTaskState {
    
    public var identifier : String!
    public var fileLocation : URL!
    var taskOperation : DownloadTaskOperation!

    public var progress : Float!
    
    public var url : URL {
        return taskOperation.url
    }
    
    var sessionData : SessionData! {
        return taskOperation.sessionData
    }
    
    var sessionDelegate : DownloaderSessionDelegate!
    
    var downloaderDelegate : DownloaderDelegate? {
        
        didSet(newValue) {
            self.delegate = newValue
        }
    }
    
    override public var state: DownloadState? {
        return taskOperation.state
    }
    
    private init(identifier: String, fileLocation: URL, sessionData: SessionData, delegate: DownloaderDelegate) {
        
        super.init()
        self.progress = 0.0
        self.identifier = identifier
        self.fileLocation = fileLocation
        self.downloaderDelegate = delegate
        self.sessionDelegate = self

    }
    
    convenience init(identifier: String, url: URL, fileLocation: URL, sessionData: SessionData, delegate: DownloaderDelegate) {
        
        self.init(identifier: identifier, fileLocation: fileLocation, sessionData: sessionData, delegate: delegate)
        self.taskOperation = DownloadTaskOperation(identifier: identifier, url: url, sessionData: sessionData)
        self.taskOperation.delegate = self
    }
    
    convenience init(identifier: String, fileLocation: URL, downloadTask: URLSessionDownloadTask, sessionData: SessionData, delegate: DownloaderDelegate) {
        
        self.init(identifier: identifier, fileLocation: fileLocation, sessionData: sessionData, delegate: delegate)
        self.taskOperation = DownloadTaskOperation(identifier: identifier, runningDownloadTask: downloadTask, sessionData: sessionData)
        self.taskOperation.delegate = self
    }
    
    convenience init(identifier: String, url: URL, fileLocation: URL, downloadedData: Data?, sessionData: SessionData, delegate: DownloaderDelegate) {
        
        self.init(identifier: identifier, fileLocation: fileLocation, sessionData: sessionData, delegate: delegate)
        self.taskOperation = DownloadTaskOperation(identifier: identifier, url: url, downloadedData: downloadedData, sessionData: sessionData)
        self.taskOperation.delegate = self
    }

    override func ready() -> DownloadTaskState? {
        _ = self.taskOperation.ready()
        return self
    }
    
    override func start() -> FileDownloader {
        
        _ = self.taskOperation.start()
        return self

    }
    
    override func pause() -> FileDownloader {
        
        _ = self.taskOperation.pause()
        return self
        
    }
    
    override func resume() -> FileDownloader {
        
        _ = self.taskOperation.resume()
        return self
        
    }
    
    override func stop() -> FileDownloader {
        _ = self.taskOperation.stop()
        return self
    }
    
    fileprivate func didComplete(tempLocation: URL) {
        
//        DispatchQueue.main.async {
//        FileManager.default.write(toFileLocation: self.downloaderDelegate!.downloaderFileLocation(self), fromLocation: tempLocation)
        FileManager.default.write(toFileLocation: self.fileLocation, fromLocation: tempLocation)
        self.taskOperation.didComplete()
//        }
        
    }

    fileprivate func didError(withData data: Data?) {
        
        self.taskOperation.didError(withData: data)
        
    }

    
    fileprivate func notifyProgress(totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        print("FILE DOWNLOADER PROGRESS BEFORE \(self.progress)")
        self.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite);
        print("FILE DOWNLOADER PROGRESS AFTER \(self.progress)")
        self.downloaderDelegate?.download(self, didProgressUpdate: self.progress)
        
    }
    
}

extension FileDownloader : DownloadTaskStateDelegate {
    
    public func state(didChangeTo newState: DownloadTaskState) {
        notifyState(didChange: newState)
    }
    
    fileprivate func notifyState(didChange newState: DownloadTaskState) {
        self.downloaderDelegate?.state(didChangeTo: self)
    }
    
}

// MARK :- DownloadSessionDelegate

extension FileDownloader : DownloaderSessionDelegate {
    
    
    func downloadSession(_ sessionData: SessionData, downloader: FileDownloader, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
     
        notifyProgress(totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
    }
    
    func downloadSession(_ sessionData: SessionData, downloader: FileDownloader, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        
        notifyProgress(totalBytesWritten: fileOffset, totalBytesExpectedToWrite: expectedTotalBytes)
    }
    
    func downloadSession(_ sessionData: SessionData, downloader: FileDownloader, errorWithData data: Data?) {
        
//        if error != nil {
            didError(withData: data)
//        }
    }
    
    func downloadSession(_ sessionData: SessionData, downloader: FileDownloader, didFinishDownloadingTo location: URL) {
        
        didComplete(tempLocation: location)
    }
    
    func downloadSessionDidFinishEvents(forBackgroundDownloadSession sessionData: SessionData) {
        
    }
    
    func downloadSession(_ sessionData: SessionData, didBecomeInvalidWithError error: Error?) {
        
    }
}
