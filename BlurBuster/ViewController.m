//
//  ViewController.m
//  BulerBuster
//
//  Created by ishimaru on 2012/10/17.
//  Copyright (c) 2012年 ishimaru. All rights reserved.
//

#import "ViewController.h"
#import <CoreMotion/CoreMotion.h>
#import <CoreImage/CoreImage.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>

@interface ViewController (){
    float _systemVersion;
    float frequency;
    float threshold;
    bool isRunning;
    bool readyToTake;
    int numberOfPictures;
}
@property(nonatomic, retain) CMMotionManager *manager;
@end

@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    session = [[AVCaptureSession alloc] init];
    session.sessionPreset = AVCaptureSessionPresetPhoto;
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (!input) {
        // Handle the error appropriately.
        NSLog(@"ERROR: trying to open camera: %@", error);
    }
    [session addInput:input];
    
    stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [stillImageOutput setOutputSettings:outputSettings];
    
    [session addOutput:stillImageOutput];
    [session startRunning];
    
    readyToTake =true;
    isRunning = false;
    numberOfPictures = 0;
    
    //iOSバージョン確認
    _systemVersion = [[[UIDevice currentDevice]systemVersion]floatValue];
    NSLog(@"iOS version: %f", _systemVersion);
    
    //写真撮影off
    isRunning = false;
    
    //周波数
    frequency = 60.0;
    
    //閾値
    threshold = 0.01;
    
    //インスタンスの作成
    self.manager = [[CMMotionManager alloc]init];
    
    //センサの利用開始
    [self startCMDeviceMotion:frequency];
}

-(void)startCMDeviceMotion:(int)frequency{
    
    //センサの有無を確認
    if(self.manager.deviceMotionAvailable){
        
        //更新間隔の指定
        self.manager.deviceMotionUpdateInterval = 1.0f/frequency;
        
        //ハンドラ
        CMDeviceMotionHandler handler = ^(CMDeviceMotion *motion, NSError *error){
            self->accelX.text = [NSString stringWithFormat:@"%lf",motion.userAcceleration.x];
            self->accelY.text = [NSString stringWithFormat:@"%lf",motion.userAcceleration.y];
            self->accelZ.text = [NSString stringWithFormat:@"%lf",motion.userAcceleration.z];
            
            self->gyroX.text = [NSString stringWithFormat:@"%lf",motion.rotationRate.x];
            self->gyroY.text = [NSString stringWithFormat:@"%lf",motion.rotationRate.y];
            self->gyroZ.text = [NSString stringWithFormat:@"%lf",motion.rotationRate.z];
            
            self->attitudeRoll.text = [NSString stringWithFormat:@"%lf", motion.attitude.roll];
            self->attitudePitch.text = [NSString stringWithFormat:@"%lf", motion.attitude.pitch];
            self->attitudeYaw.text = [NSString stringWithFormat:@"%lf", motion.attitude.yaw];
            
            if(pow(motion.rotationRate.x,2) < threshold && pow(motion.rotationRate.y,2) < threshold && pow(motion.rotationRate.z,2) < threshold && pow(motion.userAcceleration.x,2) < threshold && pow(motion.userAcceleration.y,2) < threshold){
                if(readyToTake && isRunning){
                    [self capture];
                }
                isStalableLabel.text = @"Stable";
                isStalableView.backgroundColor = [UIColor greenColor];
            }else{
                isStalableLabel.text = @"Upset";
                isStalableView.backgroundColor = [UIColor redColor];
            }
            
        };
        
        //deviceMotionの開始
        if(5.0 < _systemVersion){
            [self.manager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXTrueNorthZVertical toQueue:[NSOperationQueue currentQueue] withHandler:handler];
        }else{
            [self.manager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:handler];
        }
    }
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
    
    //センサの停止
    if(4.0 < _systemVersion){
        if(self.manager.deviceMotionActive){
            [self.manager stopDeviceMotionUpdates];
        }
    }
    
    self.manager = nil;
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
    frequency = slider.value;
    [self startCMDeviceMotion:frequency];
}

- (IBAction)thresholdSlideChanged:(id)sender {
    threshold = thresholdSlider.value;
    [self startCMDeviceMotion:frequency];
}

- (IBAction)startButtonPushed:(id)sender {
    if(isRunning == false){
        isRunning = true;
        [startButton setTitle:@"Stop" forState:UIControlStateNormal];
    }else{
        isRunning = false;
        [startButton setTitle:@"Start" forState:UIControlStateNormal];
    }
}

-(void) capture{
    readyToTake=false;
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in stillImageOutput.connections){
        for (AVCaptureInputPort *port in [connection inputPorts]){
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ){
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break; }
    }
    
    UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
	//AVCaptureVideoOrientation avcaptureOrientation = [self avOrientationForDeviceOrientation: *curDeviceOrientation];
	[videoConnection setVideoOrientation:curDeviceOrientation];
    
    
    NSLog(@"about to request a capture from: %@", stillImageOutput);
    [stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
     {
         CFDictionaryRef exifAttachments = CMGetAttachment( imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
         if (exifAttachments){
             // Do something with the attachments.
             NSLog(@"attachements: %@", exifAttachments);
         }
         else
             NSLog(@"no attachments");
         
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
         UIImage *image = [[UIImage alloc] initWithData:imageData];
         NSLog(@"%@",image);
         CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault,
                                                                     imageSampleBuffer,
                                                                     kCMAttachmentMode_ShouldPropagate);
         ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
         [library writeImageDataToSavedPhotosAlbum:imageData metadata:(__bridge id)attachments completionBlock:^(NSURL *assetURL, NSError *error) {
             [self setInterval];
             NSLog(@"saved");
             if (error) {
                 NSLog(@"Save to camera roll failed");
             }
         }];
     }];
    
    numberOfPictures ++;
    numberOfPicturesLabel.text = [NSString stringWithFormat:@"%d",numberOfPictures];
}

-(void)setInterval{
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(trigger:) userInfo:nil repeats:NO];
}

-(void)trigger:(NSTimer*)timer{
    readyToTake = true;
}

@end
