

#import <UIKit/UIKit.h>
#import "ofMain.h"
#import "ofxiPhoneExtras.h"
//#include "ofxiPhoneAlerts.h"
#include "ofxiPhone.h"

//#import <DropboxSDK/DropboxSDK.h>
#import <ObjectiveDropboxOfficial/ObjectiveDropboxOfficial.h>

extern     bool UPLOAD_INPROCESS;
extern bool GO_BACK_TO_LOAD_AGAIN_EVERYTHING;

/*
 ofxDropBox Originally created by Trent Brooks.
    - original dropbox ios tutorial: https://www.dropbox.com/developers/start/setup#ios
 
    Steps to setup DropBox SDK: 
    1. create a dropbox app on https://www.dropbox.com/developers/apps
    2. download the dropbox sdk: https://www.dropbox.com/developers/reference/sdk
        - once downloaded, drag and drop the 'DropboxSDK.framework' onto your OF xcode project
        - make sure you check the 'copy items into destination group's folder' checkbox.
    3. add the 'Security.framework' to your OF xcode project
        - Under TARGETS > ofxDropBoxExample, under the 'Build Phases' tab, where it says 'Link binary with libraries', click '+' and select the 'Security.framework'.
    4. copy your dropbox app key + secret from dropbox website
        - ref: https://www.dropbox.com/developers/start/authentication#ios
    5. Edit the ofxiphone-info.plist in your OF xcode project (right click open as source code)
        - make sure the UIApplicationExitsOnSuspend is set to false 
        - Add the following code at the top after the first <dict> tag and replace 'db-APP_KEY' with your app key eg. 'db-n0vfoe7o3a5bmtz'.
        <key>CFBundleURLTypes</key>
        <array>
            <dict>
                <key>CFBundleURLSchemes</key>
                <array>
                    <string>db-APP_KEY</string>
                </array>
            </dict>
        </array>
    6. If testing with the ofxDropBoxExample project. Remember to copy 'test.jpg' to your DropBox/Apps/YourApp folder otherwise the download won't work.
    7. That should be it. See the example testApp to see how to connect, upload, and download using ofxDropBox.
 */
/*revised by Kyriacos Kousoulides to support V2 api*/




int ofConvertPdfToImg(string pdfpath , vector<ofImage> &reslt ,int limit =0);
#pragma once
extern vector<string> ofxDropBoxMetadata;
extern string DOWNLOAD_IN_PROCCESS,TARGET_PATH_TO_UPLOAD,LISTED_DIRECTORY;



// OF CLASS
class ofxDropBox : public ofxiPhoneAlertsListener
{

public:
    
    ofxDropBox();
    virtual ~ofxDropBox();
    
    // ios delegate
   // ofxDropBoxDelegate* dropBoxDelegate; 
    
    void startSession(string appKey, string appSecret, bool useDBRootAppFolder = true);
    
    // authenticate  
    void linkAccount();
    void unlinkAccount();
    void notifyAuthorised(bool success = true);
    bool isAuthenticated;
    
    // upload

    void uploadFile(string filePath,string targetpath = "");
    void notifyQueueUploaded(bool success = true);
    bool uploadsComplete;
    
    //download
    void downloadFile(string filePath,string pargetPath="");
    void notifyQueueDownloaded(bool success = true);
    bool downloadsComplete;
    
    // handle url notification
    void launchedWithURL(string url); // notifications
    
    // activity indicator animation
    void showBusyIndicator();
    void hideBusyIndicator();
    
    // events
    ofEvent<bool> onAuthorisedEvent;
    ofEvent<bool> onQueueUploadEvent; // notifies when a whole queue has uploaded instead of individually
    ofEvent<bool> onQueueDownloadEvent;
    
    vector<string> & listDirectory(string f="/");
    string loadedPath;
    DBUserClient *client;
    DBFILESWriteMode * mode;
protected:


};

