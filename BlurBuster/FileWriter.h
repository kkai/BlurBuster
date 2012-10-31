//
//  FileWriter.h
//  iPhoneLogger
//
//  Created by Benjamin Thiel on 14.03.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Listener.h"

// Constant for the high-pass filter.
#define kFilteringFactor 0.1
extern NSString* const FileWriterRecordingStatusChangedNotification;

extern NSString* const kAccelerometerFileAppendix;
extern NSString* const kGyroscopeFileAppendix;
extern NSString* const kCompassFileAppendix;

@interface FileWriter : NSObject <Listener> {
    
    BOOL isRecording;
    
    BOOL useHighPassFilter;
    
    //indicate whether the created files have actually been used
    BOOL usedAccelerometer;
	BOOL usedGyro;
	BOOL usedCompass;
    int currentWifiRun;
    
    NSFileManager *fileManager;
	
    //text files
	FILE *accelerometerFile;
	FILE *gyroFile;
	FILE *compassFile;
    
    NSString *currentFilePrefix;
    NSString *currentRecordingDirectory;
	NSString *accelerometerFileName;
	NSString *gyroFileName;
	NSString *compassFileName;
    
}

@property(nonatomic, readonly) BOOL isRecording;
@property(nonatomic, retain) NSString *currentFilePrefix;

-(void)startRecording;
-(void)stopRecording;


@end
