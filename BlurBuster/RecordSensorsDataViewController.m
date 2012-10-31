//
//  RecordSensorsDataViewController.m
//  BlurBuster
//
//  Created by ishimaru on 2012/10/31.
//  Copyright (c) 2012年 ishimaru. All rights reserved.
//

#import "RecordSensorsDataViewController.h"

@interface RecordSensorsDataViewController ()

@end

@implementation RecordSensorsDataViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    sensorMonitor = [[SensorMonitor alloc]init];
    sensorMonitor.delegate = self;
    
    _isRunning = false;
    _frequency = 50.0;
    
    [sensorMonitor prepareCMDeviceMotion];
    [sensorMonitor startCMDeviceMotion:_frequency];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)dealloc{
    [[UIAccelerometer sharedAccelerometer]setDelegate:nil];
}


- (void)viewDidUnload {
    
    [sensorMonitor stopSensor];
    accelX = nil;
    accelY = nil;
    accelZ = nil;
    gyroX = nil;
    gyroY = nil;
    gyroZ = nil;
    attitudeRoll = nil;
    attitudePitch = nil;
    attitudeYaw = nil;
    startButton = nil;
    [super viewDidUnload];
}

- (IBAction)startButtonPushed:(id)sender {
    if(_isRunning == false){
        _isRunning = true;
        [startButton setTitle:@"Stop" forState:UIControlStateNormal];
    }else{
        _isRunning = false;
        ;
        [startButton setTitle:@"Start" forState:UIControlStateNormal];
    }
}

-(void)sensorValueChanged:(CMDeviceMotion *)motion{
    accelX.text = [NSString stringWithFormat:@"%lf",motion.userAcceleration.x];
    accelY.text = [NSString stringWithFormat:@"%lf",motion.userAcceleration.y];
    accelZ.text = [NSString stringWithFormat:@"%lf",motion.userAcceleration.z];
    gyroX.text = [NSString stringWithFormat:@"%lf",motion.rotationRate.x];
    gyroY.text = [NSString stringWithFormat:@"%lf",motion.rotationRate.y];
    gyroZ.text = [NSString stringWithFormat:@"%lf",motion.rotationRate.z];
    attitudeRoll.text = [NSString stringWithFormat:@"%lf",motion.attitude.roll];
    attitudePitch.text = [NSString stringWithFormat:@"%lf",motion.attitude.pitch];
    attitudeYaw.text = [NSString stringWithFormat:@"%lf",motion.attitude.yaw];
    
}


@end
