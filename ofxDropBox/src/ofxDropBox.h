

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
 
 */
/*revised by Kyriacos Kousoulides to support V2 api*/




int ofConvertPdfToImg(string pdfpath , vector<ofImage> &reslt ,int limit =0);
#pragma once
extern vector<string> ofxDropBoxMetadata;
extern string DOWNLOAD_IN_PROCCESS,TARGET_PATH_TO_UPLOAD,LISTED_DIRECTORY;



class ofxDropBox : public ofxiPhoneAlertsListener
{

public:
    
    ofxDropBox();
    virtual ~ofxDropBox();
    
   
 
    
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
    
 //list a directory
    vector<string> & listDirectory(string f="/");
    string loadedPath;
    DBUserClient *client;
    DBFILESWriteMode * mode;
protected:


};

