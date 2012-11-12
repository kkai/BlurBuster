//
//  SensorMonitor.h
//  BlurBuster
//
//  Created by ishimaru on 2012/10/31.
//  Copyright (c) 2012年 ishimaru. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMotion/CoreMotion.h>
#import <CoreImage/CoreImage.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>


@protocol SensorMonitorDelegate <NSObject>

-(void)sensorValueChanged:(CMDeviceMotion *)motion timestamp:(NSTimeInterval)timestamp;
-(void)finishedTakePicture;

@end

@interface SensorMonitor : NSObject{
    
    __weak id <SensorMonitorDelegate> _delegate;
    float _systemVersion;
    
    AVCaptureSession *session;
    AVCaptureStillImageOutput *stillImageOutput;
    
    NSDate *beginningOfEpoch;
    
    NSTimeInterval timestampOffsetFrom1970;
    BOOL timestampOffsetInitialized;
    
    NSString *timestampFile;
}


@property(nonatomic, weak) id <SensorMonitorDelegate> delegate;
@property(nonatomic, retain) CMMotionManager *manager;

-(void)prepareCMDeviceMotion;
-(void)startCMDeviceMotion:(int)frequency;
-(void)capture;
-(void)stopSensor;

@end
