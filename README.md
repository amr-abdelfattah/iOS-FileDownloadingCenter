# FileDownloadingCenter


[![CI Status](https://img.shields.io/travis/amr-abdelfattah/FileDownloadingCenter.svg?style=flat)](https://travis-ci.org/amr-abdelfattah/FileDownloadingCenter)
[![Version](https://img.shields.io/cocoapods/v/FileDownloadingCenter.svg?style=flat)](https://cocoapods.org/pods/FileDownloadingCenter)
[![License](https://img.shields.io/cocoapods/l/FileDownloadingCenter.svg?style=flat)](https://cocoapods.org/pods/FileDownloadingCenter)
[![Platform](https://img.shields.io/cocoapods/p/FileDownloadingCenter.svg?style=flat)](https://cocoapods.org/pods/FileDownloadingCenter)

File Downloading Center is an iOS downloading library for files.


## Features

Download Files based on objects.
Download Files based on Urls.
Retrieve the current downloading items.
Monitor the downloading process using Notification Center.
Monitor the downloading process using Delegates.
Configuare the internet source (3G/ Wifi).
Configure the notification messages for any issue.
Restore and resuming the items that were downloading  while the Application is interrupted. 


## Usage

The following is the least sample to work with the library, but Acctually you can deal directly with, 
DownloaderManager or DownloaderQueue corresponding on your level of details that you want.

### 1 - Conform to "DownloadableItem" Protocol.

    class Track: DownloadableItem {

        var downloadUrl : URL
        var downloadableItemDescription : Description
        var downloadFileLocation : URL
        // MARK:- Optional Functions
        var downloadableItemIdentifier : String
        var itemGroupBy : String?
        func isItemDownloaded() -> Bool

    }

### 2- Conform to "SessionConfigurationProtocol" Protocol.
    
    class DownloadSessionConfiguration : SessionConfigurationProtocol {
        
            public static let instance = DownloadSessionConfiguration()
            
            var sessionBackgroundIdentifier: String = "Your.Identifier.background"
            var isDiscretionary: Bool = false
            var allowsCellularAccess: Bool = true
        
    }

### 3-  Conform to "DownloadableItemProvider" Protocol.

    Class MyDownloadableItemProvider : DownloadableItemProvider {
        
        public static let shared = MyDownloadableItemProvider()
        
        func downloadableItem(withIdentifier identifier: String) -> DownloadableItem? {
            
            // Return your item using the identifier (URL) 
            
        }
        
        func downloadableItem(withUrl url: URL) -> DownloadableItem? {
            
            // Return your item using the identifier (URL)
            
        }
        
    }


### 4- Create your FileDownloadManager, Subclass "ModelDownloaderManager" class.

    class MyDownloaderManager : ModelDownloaderManager {
        
        public static var shared = AudioDownloaderManager()
        
        override var noInternetConnectionMessage: String {
            
            "No Internet Connection !".localized()
            
        }
        
        override var celluarNetworkInternetConnectionMessage: String {
            
            "Connection may be not allow to establish this downloading session, you may review settings page to enable downloading over cellular connection".localized()
            
        }
        
        override var sessionConfiguration: SessionConfigurationProtocol {
            
            return DownloadSessionConfiguration.instance
            
        }
       
        override var downloadableItemProvider: DownloadableItemProvider? {
        
            return MyDownloadableItemProvider.shared
            
        }
        
        override func allowCelluarNetworkDownload() -> Bool {
            
           return false
            
        }
        
        override func showErrorMessage(errorMessage: String) {
            
            // Show the error Message.
            
        }
        
        override func updateItemDownloadFlag(itemIndentifier: String, isDownloaded: Bool) {
            
            // item state is changed to isDownloaded, do your staff.
            
        }
        
    }

### 5- Call this function in AppDelegate, func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
That is for restoring the intrupted downloads.

    private func initDownloaderManager() {
        
        let _ = AudioDownloaderManager.shared
        DownloaderManager.shared.restore(downloadableItemProvider: self, configuration: DownloadSessionConfiguration.instance, finished: { _ in
                // Do your staff
            })
            
        }
        
    }

### 6- Conform to the "DownloaderListener" protocol in order for listening and handling the callbacks of the downloading progress

    Class MyViewController : DownloaderListener {

        func addDownloadObserver() {
               
               MyDownloaderManager.shared.addListener(downloaderListener: self, forDownloadableItems: self.downloadableItems)
               
        }

        func removeObservers() {
             
             AudioDownloaderManager.shared.removeListener(downloaderListener: self)
               
        }
           
           // MARK:- Delegates
           
           private func isCurrentDownloader(downloader: FileDownloader) -> Bool {
               
               return downloader.identifier == self.downloadableItem?.downloadableItemIdentifier ?? ""
           }
           
           func downloader(didChangeState fileDownloader: FileDownloader) {
               
               if self.isCurrentDownloader(downloader: fileDownloader) {
               
                   if let state = fileDownloader.state
                   {
                       switch state {
                           
                       case .error:
                       // Do Your Staff.
                           
                        case .completed:
                        // Do Your Staff.
                           
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
                   
               }
               
           }
           
           func queue(didUpdateProgress downloaderQueue: DownloaderQueue) {
               
           }
           
    }


## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

iOS 10.0+
Xcode 10.2+
Swift 5+

## Installation

FileDownloadingCenter is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'FileDownloadingCenter'
```

## License

FileDownloadingCenter is available under the MIT license. See the LICENSE file for more info.
