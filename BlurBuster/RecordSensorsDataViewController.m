//
//  RecordSensorsDataViewController.m
//  BlurBuster
//
//  Created by ishimaru on 2012/10/29.
//  Copyright (c) 2012年 ishimaru. All rights reserved.
//

#import "RecordSensorsDataViewController.h"

#import <CoreMotion/CoreMotion.h>
#import <CoreImage/CoreImage.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>

@interface RecordSensorsDataViewController (){
    float _systemVersion;
    float frequency;
    bool isRunning;
    bool readyToTake;
}

@property(nonatomic, retain) CMMotionManager *manager;
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
    
    //iOSバージョン確認
    _systemVersion = [[[UIDevice currentDevice]systemVersion]floatValue];
    NSLog(@"iOS version: %f", _systemVersion);
    
    //周波数
    frequency = 50.0;
    
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
            
            if(isRunning && readyToTake){
                
                [self capture];
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
    attitudeRoll = nil;
    attitudePitch = nil;
    attitudeYaw = nil;
    startButton = nil;
    [super viewDidUnload];
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
    [stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error){
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
             readyToTake = true;
             NSLog(@"saved");
             if (error) {
                 NSLog(@"Save to camera roll failed");
             }
         }];
     }];
    
}

@end