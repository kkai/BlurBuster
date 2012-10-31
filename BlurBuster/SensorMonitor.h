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

@protocol SensorMonitorDelegate <NSObject>

-(void)sensorValueChanged:(CMDeviceMotion *)motion;
-(void)finishedTakePicture;

@end

@interface SensorMonitor : NSObject{
    
    __weak id <SensorMonitorDelegate> _delegate;
    float _systemVersion;
    
    AVCaptureSession *session;
    AVCaptureStillImageOutput *stillImageOutput;
}


@property(nonatomic, weak) id <SensorMonitorDelegate> delegate;
@property(nonatomic, retain) CMMotionManager *manager;

-(void)prepareCMDeviceMotion;
-(void)startCMDeviceMotion:(int)frequency;
-(void)capture;
-(void)stopSensor;

@end
