//
//  RecordSensorsDataViewController.h
//  BlurBuster
//
//  Created by ishimaru on 2012/10/31.
//  Copyright (c) 2012年 ishimaru. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SensorMonitor.h"

@interface RecordSensorsDataViewController : UIViewController<SensorMonitorDelegate>{
    
    __weak IBOutlet UILabel *accelX;
    __weak IBOutlet UILabel *accelY;
    __weak IBOutlet UILabel *accelZ;
    __weak IBOutlet UILabel *gyroX;
    __weak IBOutlet UILabel *gyroY;
    __weak IBOutlet UILabel *gyroZ;
    __weak IBOutlet UILabel *isStalableLabel;
    __weak IBOutlet UILabel *attitudeRoll;
    __weak IBOutlet UILabel *attitudePitch;
    __weak IBOutlet UILabel *attitudeYaw;
    __weak IBOutlet UIButton *startButton;
    AVCaptureSession *session;
    AVCaptureStillImageOutput *stillImageOutput;
    float _frequency;
    bool _isRunning;
    
    SensorMonitor *sensorMonitor;

}

- (IBAction)startButtonPushed:(id)sender;

@end

