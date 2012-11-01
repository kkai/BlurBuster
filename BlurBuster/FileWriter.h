//
//  FileWriter.h
//  BlurBuster
//
//  Created by ishimaru on 2012/11/01.
//  Copyright (c) 2012年 ishimaru. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SensorMonitor.h"

#define PRODUCT_NAME @"BlurBuster"


extern NSString* const kAccelerometerFileAppendix;
extern NSString* const kGyroscopeFileAppendix;

@interface FileWriter : NSObject<SensorMonitorDelegate>{
    
    bool isRecording;
    
    NSFileManager *fileManager;
    
    FILE *accelerometerFile;
    FILE *gyroFile;
    
    NSString *accelerometerFileName;
    NSString *gyroFileName;
    
    NSString *currentFilePrefix;
    NSString *currentRecordingDirectory;
}

@property(nonatomic,retain)NSString *currentFilePrefix;

@property(nonatomic,retain)NSString *currentRecordingDirectory;
@property(nonatomic,retain)NSString *accelerometerFileName;
@property(nonatomic,retain)NSString *gyroFileName;

-(void)startRecording;
-(void)stopRecording;


-(NSString *)setupTextFile:(FILE **)file withBaseFileName:(NSString *)baseFileName appendix:(NSString *)appendix dataDescription:(NSString *) description subtitle:(NSString *) subtitle columnDescriptions:(NSArray *)columnDescriptions;
- (void)initAccelerometerFile:(NSString*)name;
- (void)initGyroFile:(NSString*)name;

@end
