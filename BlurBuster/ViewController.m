//
//  ViewController.m
//  BulerBuster
//
//  Created by ishimaru on 2012/10/17.
//  Copyright (c) 2012年 ishimaru. All rights reserved.
//

#import "ViewController.h"

@interface ViewController(){
    float _frequency;
    float _threshold;
    int _numberOfPictures;
    bool _isRunning;
    bool _isStable;
    bool _readyToTake;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    sensorMonitor = [[SensorMonitor alloc]init];
    sensorMonitor.delegate = self;
    
    _readyToTake = true;
    _isRunning = false;
    _numberOfPictures = 0;
    _frequency = 50.0;
    _threshold = 0.01;
    
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
    accelX = nil;
    accelY = nil;
    accelZ = nil;
    gyroX = nil;
    gyroY = nil;
    gyroZ = nil;
    isStalableLabel = nil;
    attitudeRoll = nil;
    attitudePitch = nil;
    attitudeYaw = nil;
    slider = nil;
    isStalableView = nil;
    thresholdSlider = nil;
    startButton = nil;
    numberOfPicturesLabel = nil;
    [super viewDidUnload];
}

- (IBAction)slideChanged:(id)sender {
    _frequency = slider.value;
    [sensorMonitor startCMDeviceMotion:_frequency];
}

- (IBAction)thresholdSlideChanged:(id)sender {
    _threshold = thresholdSlider.value;
    [sensorMonitor startCMDeviceMotion:_frequency];
}

- (IBAction)startButtonPushed:(id)sender {
    if(_isRunning == false){
        _isRunning = true;
        [startButton setTitle:@"Stop" forState:UIControlStateNormal];
        [fileWriter startRecording];
    }else{
        _isRunning = false;
        ;
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
    
    if(pow(motion.rotationRate.x,2) < _threshold && pow(motion.rotationRate.y,2) < _threshold && pow(motion.rotationRate.z,2) < _threshold && pow(motion.userAcceleration.x,2) < _threshold && pow(motion.userAcceleration.y,2) < _threshold){
        if(_isRunning && _readyToTake){
            _readyToTake = false;
            [sensorMonitor capture];
            _numberOfPictures ++;
            numberOfPicturesLabel.text = [NSString stringWithFormat:@"%d",_numberOfPictures];
        [fileWriter recordSensorValue:motion timestamp:timestamp];
        }
        isStalableLabel.text = @"Stable";
        isStalableView.backgroundColor = [UIColor greenColor];
    }else{
        isStalableLabel.text = @"Upset";
        isStalableView.backgroundColor = [UIColor redColor];
    }
}

-(void)finishedTakePicture{
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(trigger:) userInfo:nil repeats:NO];
}

-(void)trigger:(NSTimer*)timer{
    _readyToTake = true;
}

@end
