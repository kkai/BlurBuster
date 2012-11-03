//
//  ViewController.h
//  BulerBuster
//
//  Created by ishimaru on 2012/10/17.
//  Copyright (c) 2012年 ishimaru. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SensorMonitor.h"

@interface ViewController : UIViewController<SensorMonitorDelegate>{
    
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
    __weak IBOutlet UISlider *slider;
    __weak IBOutlet UIView *isStalableView;
    __weak IBOutlet UISlider *thresholdSlider;
    __weak IBOutlet UIButton *startButton;
    __weak IBOutlet UILabel *numberOfPicturesLabel;
    
    SensorMonitor *sensorMonitor;
}

- (IBAction)slideChanged:(id)sender;
- (IBAction)thresholdSlideChanged:(id)sender;
- (IBAction)startButtonPushed:(id)sender;

@end
