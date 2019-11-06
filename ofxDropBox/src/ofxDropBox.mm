


#include "ofxDropBox.h"
//#import <DropboxSDK/DropboxSDK.h>
#import <ObjectiveDropboxOfficial/ObjectiveDropboxOfficial.h>

vector<string> ofxDropBoxMetadata;

string DOWNLOAD_IN_PROCCESS,TARGET_PATH_TO_UPLOAD;
int ofConvertPdfToImg(string sourcePDFUrl, vector<ofImage> &reslt ,int limit ){
    //cout<<"SourcePDFDocument"<<endl;
    CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:ofxStringToNSString(sourcePDFUrl)];
    //string outputBaseName ; string directory;
    CGPDFDocumentRef SourcePDFDocument = CGPDFDocumentCreateWithURL(url);
    cout<<SourcePDFDocument<<endl;
    
    
    size_t numberOfPages =limit;
    
    int totalNu_=CGPDFDocumentGetNumberOfPages(SourcePDFDocument);

    
  if(limit==0)numberOfPages =  totalNu_;
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
  
    for(int currentPage = 1; currentPage <= numberOfPages; currentPage ++ )
    {
        CGPDFPageRef SourcePDFPage = CGPDFDocumentGetPage(SourcePDFDocument, currentPage);
        CGPDFPageRetain(SourcePDFPage);
     
        CGRect sourceRect = CGPDFPageGetBoxRect(SourcePDFPage, kCGPDFMediaBox);
        UIGraphicsBeginImageContext(CGSizeMake(sourceRect.size.width,sourceRect.size.height));
        CGContextRef currentContext = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(currentContext, 0.0, sourceRect.size.height); //596,842 //640×960,
        CGContextScaleCTM(currentContext, 1.0, -1.0);
        CGContextDrawPDFPage (currentContext, SourcePDFPage);
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        reslt.push_back(ofImage());
        ofxiPhoneUIImageToOFImage(image,reslt[reslt.size()-1]);
    }
    return totalNu_;
    
}
bool UPLOAD_INPROCESS;

ofxDropBox::ofxDropBox() {
    isAuthenticated = false;
    uploadsComplete = false;
    downloadsComplete = false;
    UPLOAD_INPROCESS=false;
    // we want to know when something has been launched with a url
    ofxiPhoneAlerts.addListener(this);
    client=NULL;
    // setup objc style delegate
    //dropBoxDelegate = [[ofxDropBoxDelegate alloc] init:	this ];
    
    cout<<"dfxDrop.. |||||"<<endl;

}


ofxDropBox::~ofxDropBox() {
    cout<<"~ofxDrop.. |||||"<<endl;

   // [dropBoxDelegate release];
}

void ofxDropBox::startSession(string appKey_, string appSecret_, bool useDBRootAppFolder) {
//Authorization: Bearer <"7Hu67kzeJq0AAAAAAAAylC4eXRyt14X0VHsLNGEVt1ZonQHluMbZnKlM7-7npOd3">
/*
    DBSession* dbSession = [[DBSession alloc]
                             initWithAppKey:ofxStringToNSString(appKey)
                             appSecret:ofxStringToNSString(appSecret)
                            root:(useDBRootAppFolder) ? kDBRootAppFolder : kDBRootDropbox]; // either kDBRootAppFolder or kDBRootDropbox
                            //autorelease];
    dbSession.delegate = dropBoxDelegate;
    [DBRequest setNetworkRequestDelegate:dropBoxDelegate];
    [DBSession setSharedSession:dbSession];
    
    // check if already authenticated- should only need auth once
    if ([[DBSession sharedSession] isLinked]) {
        notifyAuthorised();
    }
    */
    cout<<"startSession.. |||||"<<endl;
 
    NSString *appKey = @"kipbikyp6zwxt24";
    NSString *registeredUrlToHandle = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"][0][@"CFBundleURLSchemes"][0];
    
    
    if (!appKey || [registeredUrlToHandle containsString:@"<"]) {
        NSString *message = @"You need to set `appKey` variable in `AppDelegate.m`, as well as add to `Info.plist`, before you can use DBRoulette.";
        NSLog(@"%@", message);
        NSLog(@"Terminating...");
    }
    [DBClientsManager setupWithAppKey:appKey];
    
    
    ofNotifyEvent(onAuthorisedEvent, isAuthenticated, this);

    
    
}

void ofxDropBox::notifyAuthorised(bool success) {
    cout<<"notifyAuthorised.. |||||"<<endl;

    isAuthenticated = success;
    ofNotifyEvent(onAuthorisedEvent, isAuthenticated, this);
}


void ofxDropBox::linkAccount() {
    /*
    // connect to users account through dropbox app or mobile browser (safari)
    if (![[DBSession sharedSession] isLinked]) {
        NSLog(@"\n\n DropBox is not linked, launching native DropBox app or browser\n\n");
        [[DBSession sharedSession] linkFromController:ofxiPhoneGetViewController()];
    } 
     */

    cout<<"LINKING.. |||||"<<endl;
    
  //  UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
   /*
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
*/
    if(client==NULL){
        client = [DBClientsManager authorizedClient];
    }

    if([client isAuthorized]){
        cout<<"jis AUTH"<<endl;
        notifyAuthorised();

    }else{
 
    [DBClientsManager authorizeFromController:[UIApplication sharedApplication]
controller:ofxiOSGetViewController()
openURL:^(NSURL *url) {
    [[UIApplication sharedApplication] openURL:url];
    
}];
    
    }
    
    
    
}

void ofxDropBox::unlinkAccount() {
    /*
    NSLog(@"\n\n Unlinking DropBox\n\n");
    if ([[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] unlinkAll];
        notifyAuthorised(false);
    }
     */
    cout<<"unlinkAccount.. |||||"<<endl;

}

void ofxDropBox::uploadFile(string filePath,string pargetPath) {
    if(!UPLOAD_INPROCESS){
        if(TARGET_PATH_TO_UPLOAD.size()==0){
            cout<<": 00 0 0 0 0 0ddf0d0f0adsfsadfsdkjf   UPLOADING:! "<<endl;
            
            if(pargetPath.size()==0)pargetPath="/";else{
                ofDirectory fs(ofxiOSGetDocumentsDirectory()+pargetPath);
                if(!fs.exists()){cout<<"CATASTROPHIC ERRROR - while uploading - directory of uploaded file doesn't exist!!!!!"<<endl; }
                pargetPath = ""+pargetPath+"/";
            }
            TARGET_PATH_TO_UPLOAD =pargetPath;

        }
        UPLOAD_INPROCESS=true;
    cout<<"uploadFile.. |||||"<<endl;
        NSString *fileToUpload = ofxiOSStringToNSString(filePath);
        NSString *fileRev = nil;
        NSString *destDir =   ofxiOSStringToNSString(TARGET_PATH_TO_UPLOAD); //@"/ALLHLOGRAFIA/
        
       // NSData *fileData = [@"file data example" dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];

        string docDirectory =ofxiOSGetDocumentsDirectory();
        docDirectory.pop_back();
  NSString *localPath =ofxiOSStringToNSString(docDirectory+TARGET_PATH_TO_UPLOAD+ofxNSStringToString(fileToUpload));    // For overriding on upload
        
        NSString *output_ =ofxiOSStringToNSString(TARGET_PATH_TO_UPLOAD+filePath);
        NSData *fileData = [[NSFileManager defaultManager] contentsAtPath:localPath];

        cout<<" ou "<<ofxNSStringToString(output_)<<endl;
        
        mode  = [[DBFILESWriteMode alloc] initWithOverwrite];
    
    [[[client.filesRoutes uploadData:output_
                                mode:mode
                          autorename:@(YES)
                      clientModified:nil
                                mute:@(NO)
                           inputData:fileData]
      setResponseBlock:^(DBFILESFileMetadata *result, DBFILESUploadError *routeError, DBRequestError *networkError) {
          if (result) {
              notifyQueueUploaded();
              NSLog(@"%@\n", result);
          } else {
              NSLog(@"%@\n%@\n", routeError, networkError);
          }
      }] setProgressBlock:^(int64_t bytesUploaded, int64_t totalBytesUploaded, int64_t totalBytesExpectedToUploaded) {
          NSLog(@"\n%lld\n%lld\n%lld\n", bytesUploaded, totalBytesUploaded, totalBytesExpectedToUploaded);
      }];
    
    }
    
    
 /*
    if(TARGET_PATH_TO_UPLOAD.size()==0){
    uploadsComplete = false;
    if(pargetPath.size()==0)pargetPath="/";else{

        ofDirectory fs(ofxiOSGetDocumentsDirectory()+pargetPath);
        
        if(!fs.exists()){cout<<"CATASTROPHIC ERRROR - while uploading - directory of uploaded file doesn't exist!!!!!"<<endl; }
        
        pargetPath = ""+pargetPath+"/";
    }
    
    NSString *nFilePath = ofxStringToNSString(filePath);
    [[dropBoxDelegate uploadQueue] addObject:nFilePath];
    dropBoxDelegate.isUploading = YES;
    [[dropBoxDelegate restClient] loadMetadata:ofxStringToNSString(pargetPath)];
        TARGET_PATH_TO_UPLOAD =pargetPath;
    }
*/
}

// when a full queue is uploaded from delegate send notification
void ofxDropBox::notifyQueueUploaded(bool success) {
    cout<<"notifyQueueUploaded.. |||||"<<endl;

    uploadsComplete = success;
    ofNotifyEvent(onQueueUploadEvent, uploadsComplete, this);
}

void ofxDropBox::downloadFile(string filePath,string pargetPath) {
    if(DOWNLOAD_IN_PROCCESS==""&&filePath!="MAIL.app"){
        cout<<"DOWNLOADING: "<<filePath<<endl;
        if(pargetPath.size()==0)pargetPath="/";else{
            cout<<"SHIT:"<<pargetPath<<endl;
            ofDirectory fs(ofxiOSGetDocumentsDirectory()+pargetPath);
            if(!fs.exists())fs.createDirectory(ofxiOSGetDocumentsDirectory()+pargetPath,true,true);
            
            pargetPath = ""+pargetPath+"/";
        }
        NSString *nFilePath = ofxStringToNSString(filePath);
        NSString *fileWithPath =ofxStringToNSString(pargetPath+filePath);
        
        NSLog(@"%@\n", nFilePath);
        NSLog(@"%@\n", fileWithPath);

        DOWNLOAD_IN_PROCCESS = filePath;
    cout<<"))))))))downloadFile.. |||||"<<pargetPath<<endl;
        
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *outputDirectory = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
        pargetPath.erase(0,1);
        NSString *fileWithPath_trimmed =ofxStringToNSString(pargetPath+filePath);

    NSURL *outputUrl = [outputDirectory URLByAppendingPathComponent:fileWithPath_trimmed];
    
        cout<<outputDirectory<<outputUrl<<" - - - "<<endl;
        NSLog(@"%@\n", outputDirectory);
        NSLog(@"%@\n", outputUrl);

        
    [[[client.filesRoutes downloadUrl:fileWithPath overwrite:NO destination:outputUrl]
      setResponseBlock:^(DBFILESFileMetadata *result, DBFILESDownloadError *routeError, DBRequestError *networkError,
                         NSURL *destination) {
          if (result) {
              cout<<"THIS IS THE RESULT: "<<endl;
              NSLog(@"%@\n", result);
              NSData *data = [[NSFileManager defaultManager] contentsAtPath:[destination path]];
              NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
              NSLog(@"%@\n", dataStr);
              notifyQueueDownloaded();

          } else {
              DOWNLOAD_IN_PROCCESS.clear();
              cout<<"ERROR HOMMIEEE!!!"<<endl;
              NSLog(@"%@\n%@\n", routeError, networkError);
              cout<<filePath<<endl;
              GO_BACK_TO_LOAD_AGAIN_EVERYTHING= true;
          }
      }] setProgressBlock:^(int64_t bytesDownloaded, int64_t totalBytesDownloaded, int64_t totalBytesExpectedToDownload) {
          NSLog(@"%lld\n%lld\n%lld\n", bytesDownloaded, totalBytesDownloaded, totalBytesExpectedToDownload);
      }];
        
    }
    
/*
    if(DOWNLOAD_IN_PROCCESS==""){
    if(pargetPath.size()==0)pargetPath="/";else{
        cout<<"SHIT:"<<pargetPath<<endl;
        ofDirectory fs(ofxiOSGetDocumentsDirectory()+pargetPath);
        if(!fs.exists())fs.createDirectory(ofxiOSGetDocumentsDirectory()+pargetPath,true,true);

        pargetPath = ""+pargetPath+"/";
    }
    downloadsComplete = false; 
    NSLog(@"do download ");
    
    NSString *nFilePath = ofxStringToNSString(filePath);
    [[dropBoxDelegate downloadQueue] addObject:nFilePath];
    dropBoxDelegate.isDownloading = YES;
        dropBoxDelegate.hasMetaDataUpdated = YES;
        cout<<"@@@"<<pargetPath<<endl;
        
        [[dropBoxDelegate restClient] loadMetadata:ofxStringToNSString(pargetPath)];
        DOWNLOAD_IN_PROCCESS = filePath;
    }
 */
}

// when a full queue is uploaded from delegate send notification
void ofxDropBox::notifyQueueDownloaded(bool success) {
    cout<<"NOTIFYING SUCCESSS!!"<<endl;
    downloadsComplete = success;
    ofNotifyEvent(onQueueDownloadEvent, downloadsComplete, this);
}


vector<string> & ofxDropBox::listDirectory(string filePath){
   // filePath.erase(0,1);
trylistiagainlikeanidiot:
    if(loadedPath!=filePath){
        cout<<" LISTING DIRECTORY: "<<filePath<<" - "<<loadedPath<<endl;
        loadedPath=filePath;

        if(filePath=="/")filePath.clear();
        
        if(client==NULL){
    client = [DBClientsManager authorizedClient];
        }

        
    [[client.filesRoutes listFolder:ofxiOSStringToNSString(filePath)]
     setResponseBlock:^(DBFILESListFolderResult *result, DBFILESListFolderError *routeError, DBRequestError *networkError) {
         if (result) {
             
           //  NSLog(@"%@", [NSThread currentThread]); // Output: <NSThread: 0x600000261480>{number = 5, name = (null)}
           //  NSLog(@"%@", [NSThread mainThread]);    // Output: <NSThread: 0x618000062bc0>{number = 1, name = (null)}
          //   NSLog(@"%@\n", result);
        
             NSArray<DBFILESMetadata *> *entries = result.entries;
             
             LISTED_DIRECTORY  = loadedPath;
            // loadedPath=filePath;

            
                 ofxDropBoxMetadata.clear();
             for (DBFILESMetadata *entry in entries) {
                 
                     ofxDropBoxMetadata.push_back(ofxNSStringToString(entry.name));
                     
                
                 }
       
         }else{
           //  GO_BACK_TO_LOAD_AGAIN_EVERYTHING=true;
             cout<<"ERRROOOORRRRRR LISTING!!!!!!"<<endl;
          //   filePath = "";
          //   loadedPath.clear();
           //  ofxDropBoxMetadata.clear();
         }
     } ];
        
        
    }
    
/*
    NSString *nFilePath = ofxStringToNSString(filePath);
    if(loadedPath!=filePath){
        dropBoxDelegate.hasMetaDataUpdated = NO;
        loadedPath=filePath;

        dropBoxDelegate.hasMetaDataUpdated = YES;
        [[dropBoxDelegate restClient] loadMetadata:nFilePath];
    }
 */
    return ofxDropBoxMetadata;
    
}



// only gets called once when app launches dropbox as app or in browser
void ofxDropBox::launchedWithURL(string url_)
{
    
    cout<<"LUCCCCC --  - - - -  "<<url_<<endl;
    
    NSURL* nsUrl = [ [ NSURL alloc ] initWithString: ofxStringToNSString(url_) ];
    
    
    
    DBOAuthResult *authResult = [DBClientsManager handleRedirectURL:nsUrl];
    
    if (authResult != nil) {
        if ([authResult isSuccess]) {
            notifyAuthorised();
            cout<<"succexsssss!!!"<<endl;
            NSLog(@"Success! User is logged into Dropbox.");
        } else if ([authResult isCancel]) {
            cout<<"CANCELL!!1!!!"<<endl;

            NSLog(@"Authorization flow was manually canceled by user!");
        } else if ([authResult isError]) {
            cout<<"E&&&&&***ERreeeeREREREREREWWSDGDSFGSDFGDFSGFFFFFFFFFF1!!!1!!!"<<endl;

            NSLog(@"Error: %@", authResult);
        }
    }else cout<<" IT IS NIIIIIIIL!!!!!"<<endl;
    /*
    
    DBOAuthResult *authResult = [DBClientsManager handleRedirectURL:url];
    if (authResult != nil) {
        if ([authResult isSuccess]) {
            NSLog(@"Success! User is logged into Dropbox.");
            UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
            ViewController *viewController = (ViewController *)navigationController.childViewControllers[0];
            viewController.authSuccessful = YES;
            return YES;
        } else if ([authResult isCancel]) {
            NSLog(@"Authorization flow was manually canceled by user!");
        } else if ([authResult isError]) {
            NSLog(@"Error: %@", authResult);
        }
    }
*/
    
    cout<<" LAUCN WIHT URLF IS CALLED "<<endl;
    
    /*
    NSURL* nsUrl = [ [ NSURL alloc ] initWithString: ofxStringToNSString(url) ];
    if ([[DBSession sharedSession] handleOpenURL:nsUrl]) {
        if ([[DBSession sharedSession] isLinked]) {
            NSLog(@"App linked successfully! At this point you can start making API calls");
            notifyAuthorised();
        }
    }
     */
}

// activity indicator stuff
void ofxDropBox::showBusyIndicator() {
  //  [[dropBoxDelegate busyAnimation] startAnimating];
}

void ofxDropBox::hideBusyIndicator() {
  //  [[dropBoxDelegate busyAnimation] stopAnimating];
}



