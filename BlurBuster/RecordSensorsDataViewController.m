//
//  RecordSensorsDataViewController.m
//  BlurBuster
//
//  Created by ishimaru on 2012/10/31.
//  Copyright (c) 2012年 ishimaru. All rights reserved.
//

#import "RecordSensorsDataViewController.h"

@interface RecordSensorsDataViewController (){
    float _frequency;
    bool _isRunning;
    bool _readyToTake;
    int _numberOfPictures;
}

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
    _readyToTake = true;
    _frequency = 100.0;
    _numberOfPictures = 0;
    
    [sensorMonitor prepareCMDeviceMotion];
    [sensorMonitor startCMDeviceMotion:_frequency];
    
    fileWriter = [[FileWriter alloc]init];
    
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
    [fileWriter stopRecording];
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
        [fileWriter startRecording];
    }else{
        _isRunning = false;
        [startButton setTitle:@"Start" forState:UIControlStateNormal];
        [fileWriter stopRecording];
    }
}

-(void)sensorValueChanged:(CMDeviceMotion *)motion timestamp:(NSTimeInterval)timestamp{
    accelX.text = [NSString stringWithFormat:@"%lf",motion.userAcceleration.x];
    accelY.text = [NSString stringWithFormat:@"%lf",motion.userAcceleration.y];
    accelZ.text = [NSString stringWithFormat:@"%lf",motion.userAcceleration.z];
    gyroX.text = [NSString stringWithFormat:@"%lf",motion.rotationRate.x];
    gyroY.text = [NSString stringWithFormat:@"%lf",motion.rotationRate.y];
    gyroZ.text = [NSString stringWithFormat:@"%lf",motion.rotationRate.z];
    attitudeRoll.text = [NSString stringWithFormat:@"%lf",motion.attitude.roll];
    attitudePitch.text = [NSString stringWithFormat:@"%lf",motion.attitude.pitch];
    attitudeYaw.text = [NSString stringWithFormat:@"%lf",motion.attitude.yaw];
    
    if(_isRunning){
        
        //I put this out of _readyToTake (as otherwise we will record very little sensor values (only 2-3 Hz)
        [fileWriter recordSensorValue:motion timestamp:timestamp];
        
        
        //this should not be in sensorValueChanged ... maybe it does not matter though
        if(_readyToTake){
            _readyToTake = false;
            [sensorMonitor capture];
            _numberOfPictures ++;
            numberOfPicturesLabel.text = [NSString stringWithFormat:@"%d",_numberOfPictures];
        }
        
    
    }
}

-(void)finishedTakePicture{
    _readyToTake = true;
}

@end
