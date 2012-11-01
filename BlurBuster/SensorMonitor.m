//
//  SensorMonitor.m
//  BlurBuster
//
//  Created by ishimaru on 2012/10/31.
//  Copyright (c) 2012年 ishimaru. All rights reserved.
//

#import "SensorMonitor.h"

@implementation SensorMonitor

- (void)prepareCMDeviceMotion{
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
    
    //iOSバージョン確認
    _systemVersion = [[[UIDevice currentDevice]systemVersion]floatValue];
    NSLog(@"iOS version: %f", _systemVersion);
    
    //インスタンスの作成
    self.manager = [[CMMotionManager alloc]init];
    
    beginningOfEpoch = [[NSDate alloc]initWithTimeIntervalSince1970:0.0];
    timestampOffsetInitialized = false;
}

-(void)startCMDeviceMotion:(int)frequency{
    
    //センサの有無を確認
    if(self.manager.deviceMotionAvailable){
        
        //更新間隔の指定
        self.manager.deviceMotionUpdateInterval = 1.0f/frequency;
        
        //ハンドラ
        CMDeviceMotionHandler handler = ^(CMDeviceMotion *motion, NSError *error){
            
            if (!timestampOffsetInitialized) {
                timestampOffsetFrom1970 = [self getTimestamp] - motion.timestamp;
                timestampOffsetInitialized = true;
            }
            
            NSTimeInterval timestamp = motion.timestamp + timestampOffsetFrom1970;
            
            [self.delegate sensorValueChanged:motion timestamp:timestamp];
            
        };
        
        //deviceMotionの開始
        if(5.0 < _systemVersion){
            [self.manager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXTrueNorthZVertical toQueue:[NSOperationQueue currentQueue] withHandler:handler];
        }else{
            [self.manager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:handler];
        }
    }
}

-(void)dealloc{
    [[UIAccelerometer sharedAccelerometer]setDelegate:nil];
}


- (void)stopSensor{
    
    //センサの停止
    if(4.0 < _systemVersion){
        if(self.manager.deviceMotionActive){
            [self.manager stopDeviceMotionUpdates];
        }
    }
}

-(void) capture{
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
             [self.delegate finishedTakePicture];
             NSLog(@"saved");
             if (error) {
                 NSLog(@"Save to camera roll failed");
             }
         }];
     }];
    
}

-(NSTimeInterval)getTimestamp {	
	NSTimeInterval timestamp = -[beginningOfEpoch timeIntervalSinceNow];
	return timestamp;
}


@end