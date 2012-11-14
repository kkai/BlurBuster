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
extern NSString* const kTimestampFileAppendix;

@interface FileWriter : NSObject{
    
    bool isRecording;
    
    NSFileManager *fileManager;
    
    FILE *accelerometerFile;
    FILE *gyroFile;
    FILE *timestampFile;
    
    NSString *accelerometerFileName;
    NSString *gyroFileName;
    NSString *timestampFileName;
    NSString *currentFilePrefix;
    NSString *currentRecordingDirectory;
    NSString *currentRecordingDirectoryForpicture;
    
}

@property(nonatomic,retain)NSString *currentFilePrefix;
@property(nonatomic,retain)NSString *currentRecordingDirectory;
@property(nonatomic,retain)NSString *currentRecordingDirectoryForPicture;
@property(nonatomic,retain)NSString *accelerometerFileName;
@property(nonatomic,retain)NSString *gyroFileName;
@property(nonatomic,retain)NSString *timestampFileName;

-(void)startRecording;
-(void)stopRecording;
-(void)recordSensorValue:(CMDeviceMotion *)motionTN timestamp:(NSTimeInterval)timestampTN;
-(void)recordPicture:(UIImage*)image timestamp:(NSTimeInterval)timestamp;

-(NSString *)setupTextFile:(FILE **)file withBaseFileName:(NSString *)baseFileName appendix:(NSString *)appendix dataDescription:(NSString *) description subtitle:(NSString *) subtitle columnDescriptions:(NSArray *)columnDescriptions;
-(void)initAccelerometerFile:(NSString*)name;
-(void)initGyroFile:(NSString*)name;
-(void)initTimestampFile:(NSString*)name;

@end
