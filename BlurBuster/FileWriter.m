//
//  FileWriter.m
//  BlurBuster
//
//  Created by ishimaru on 2012/11/01.
//  Copyright (c) 2012年 ishimaru. All rights reserved.
//

#import "FileWriter.h"

NSString* const kAccelerometerFileAppendix = @"_Accel";
NSString* const kGyroscopeFileAppendix = @"_Gyro";

@implementation FileWriter

@synthesize currentFilePrefix, currentRecordingDirectory;
@synthesize accelerometerFileName;
@synthesize gyroFileName;

-(id)init{
    self = [super init];
    if(self != nil){
        fileManager = [[NSFileManager alloc]init];
        isRecording = false;
        
    }
    return self;
}

-(void)dealloc{
    [self stopRecording];
}

-(void)startRecording{
    
    if(!isRecording){

        NSDate *now = [NSDate date];
        self.currentFilePrefix = [[now description] stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory = [paths lastObject];
        self.currentRecordingDirectory = [documentDirectory stringByAppendingPathComponent:self.currentFilePrefix];
        [fileManager createDirectoryAtPath:self.currentRecordingDirectory withIntermediateDirectories:NO attributes:nil error:NULL];

        //init files
        [self initAccelerometerFile:self.currentFilePrefix];
        [self initGyroFile:self.currentFilePrefix];
        
        isRecording = true;
    }
}

-(void)stopRecording{
    
    if(isRecording){
        
        //close all open files
        fclose(accelerometerFile);
        fclose(gyroFile);
    
//        [fileManager removeItemAtPath:self.accelerometerFileName error:NULL];
//        [fileManager removeItemAtPath:self.gyroFileName error:NULL];
        isRecording = false;
    }
}

-(NSString *)setupTextFile:(FILE **)file withBaseFileName:(NSString *)baseFileName appendix:(NSString *)appendix dataDescription:(NSString *)description subtitle:(NSString *)subtitle columnDescriptions:(NSArray *)columnDescriptions{
    
    NSString *fileName = [[baseFileName stringByAppendingString:appendix] stringByAppendingPathExtension:@"csv"];
    NSString *completeFilePath = [currentRecordingDirectory stringByAppendingPathComponent:fileName];

    //create the file for the record
    *file = fopen([completeFilePath UTF8String], "a");
    
    bool isExists = [fileManager fileExistsAtPath:completeFilePath];
    NSLog(@"%@ is exists:%d",completeFilePath, isExists);
    
    //write an initial header
    //fprintf(*file, "%% %s recorded with '%s' \n %% \n",[description UTF8String],[PRODUCT_NAME UTF8String]);
    
    //if(subtitle){
    //    fprintf(*file, "%s",[subtitle UTF8String]);
    //}
    
    //fprintf(*file, "%% \n%% \n");
	//fprintf(*file, "%% \n%% Column description:\n");
    for (int i = 0; i < [columnDescriptions count]; i++) {
        //fprintf(*file, "%% ,%i: %s\n", i + 1, [[columnDescriptions objectAtIndex:i] UTF8String]);
        if([columnDescriptions count] == (i+1)){
            fprintf(*file, "%s\n",[[columnDescriptions objectAtIndex:i] UTF8String]);
        }else{
            fprintf(*file, "%s,",[[columnDescriptions objectAtIndex:i] UTF8String]);
        }
    }
	//fprintf(*file, "%% \n%% \n");
    
    return completeFilePath;
}

- (void)initAccelerometerFile:(NSString*)name {
    self.accelerometerFileName = [self setupTextFile:&accelerometerFile
                                    withBaseFileName:name 
                                            appendix:kAccelerometerFileAppendix
                                     dataDescription:@"Accelerometer data"
                                            subtitle:[NSString stringWithFormat:@"%% Sampling frequency: 50 Hz\n"]
//                                       subtitle:[NSString stringWithFormat:@"%% Sampling frequency: %i Hz\n",
//                                                 [Gyroscope sharedInstance].frequency]
                                  columnDescriptions:[NSArray arrayWithObjects:
                                                      @"Seconds.milliseconds since 1970",
                                                      @"Queue size of CMController",
                                                      @"Acceleration value in x-direction",
                                                      @"Acceleration value in y-direction",
                                                      @"Acceleration value in z-direction",
                                                      @"Label used for the current sample",
                                                      nil]
                                  ];
}


- (void)initGyroFile:(NSString*)name {
    
    self.gyroFileName = [self setupTextFile:&gyroFile
                           withBaseFileName:name
                                   appendix:kGyroscopeFileAppendix
                            dataDescription:@"Gyrometer data"
                                   subtitle:nil
                         columnDescriptions:[NSArray arrayWithObjects:
                                             @"Seconds.milliseconds since 1970",
                                             @"Queue size of CMController",
                                             @"Gyro X",
                                             @"Gyro Y",
                                             @"Gyro Z",
                                             @"Roll of the device",
                                             @"Pitch of the device",
                                             @"Yaw of the device",
                                             @"Quaternion X",
                                             @"Quaternion Y",
                                             @"Quaternion Z",
                                             @"Quaternion W",
                                             @"X-axis magnetic field in microteslas",
                                             @"Y-axis magnetic field in microteslas",
                                             @"Z-axis magnetic field in microteslas",
                                             [NSString stringWithFormat:@"Magnetic field accuracy (%i: not calibrated, %i: low, %i: medium, %i: high)",
                                              CMMagneticFieldCalibrationAccuracyUncalibrated,
                                              CMMagneticFieldCalibrationAccuracyLow,
                                              CMMagneticFieldCalibrationAccuracyMedium,
                                              CMMagneticFieldCalibrationAccuracyHigh],
                                             @"Label used for the current sample",
                                             nil]
                         ];
}

-(void)recordSensorValue:(CMDeviceMotion *)motionTN timestamp:(NSTimeInterval)timestampTN{
    
    if(isRecording){
    
    fprintf(accelerometerFile,
            "%10.3f,%i,%f,%f,%f,%i\n",
            timestampTN,
            0,
            motionTN.userAcceleration.x,
            motionTN.userAcceleration.y,
            motionTN.userAcceleration.z,
            0);
    
    CMAttitude *attitude = motionTN.attitude;
    CMRotationRate rate = motionTN.rotationRate;
    CMQuaternion quaternion = motionTN.attitude.quaternion;
    CMCalibratedMagneticField magneticField = motionTN.magneticField;
    
    double x = rate.x;
    double y = rate.y;
    double z = rate.z;
    
    double roll = attitude.roll;
    double pitch = attitude.pitch;
    double yaw = attitude.yaw;
    
    fprintf(gyroFile,
            "%10.3f,%i,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%i,%i\n",
            timestampTN,
            0,
            x,
            y,
            z,
            roll,
            pitch,
            yaw,
            quaternion.x,
            quaternion.y,
            quaternion.z,
            quaternion.w,
            magneticField.field.x,
            magneticField.field.y,
            magneticField.field.z,
            magneticField.accuracy,
            0);
    }
}

@end
