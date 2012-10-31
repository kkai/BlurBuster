//
//  FileWriter.m
//  iPhoneLogger
//
//  Created by Benjamin Thiel on 14.03.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FileWriter.h"
#import "Preferences.h"

NSString* const FileWriterRecordingStatusChangedNotification = @"FileWriterRecordingStatusChangedNotification";

NSString* const kAccelerometerFileAppendix = @"_Accel";
NSString* const kGyroscopeFileAppendix = @"_Gyro";
NSString* const kCompassFileAppendix = @"_Comp";

//anonymous category extending the class with "private" methods
//MARK: private methods
@interface FileWriter ()

@property(nonatomic) BOOL useHighPassFilter;

@property(nonatomic, retain) NSString *currentRecordingDirectory;
@property(nonatomic, retain) NSString *accelerometerFileName;
@property(nonatomic, retain) NSString *gpsFileName;
@property(nonatomic, retain) NSString *gyroFileName;
@property(nonatomic, retain) NSString *compassFileName;

-(NSString *)initTextFile:(FILE **)file withBaseFileName:(NSString *)baseFileName appendix:(NSString *)appendix dataDescription:(NSString *) description subtitle:(NSString *) subtitle columnDescriptions:(NSArray *)columnDescriptions;

- (void)initAccelerometerFile:(NSString*)name;
- (void)initGpsFile:(NSString*)name;
- (void)initGyroFile:(NSString*)name;
- (void)initCompassFile:(NSString*)name;

@end


@implementation FileWriter

@synthesize isRecording;

@synthesize useHighPassFilter;

@synthesize currentFilePrefix, currentRecordingDirectory;
@synthesize accelerometerFileName;
@synthesize gpsFileName;
@synthesize gyroFileName;
@synthesize compassFileName;

#pragma mark -
#pragma mark initialization methods
-(id)init {
    
    self = [super init];
    
    if (self != nil) {
        
        //The alloc-inited NSFileManager is thread-safe in contrast to the singleton (see documentation)
        fileManager = [[NSFileManager alloc] init];
    }
    
    return self;
}

-(void)dealloc {
    
    [self stopRecording];
    
    //release by setting to nil with the synthesized (retain)-setter
    self.currentFilePrefix = nil;
    self.accelerometerFileName = nil;
    self.gpsFileName = nil;
    self.gyroFileName = nil;
    self.compassFileName = nil;
    
}

#pragma mark -
#pragma mark recording methods

-(void)startRecording {
    
    if (!isRecording) {
        
        //use the current date and time as a basis for the filename and directory
        NSDate *now = [NSDate date];
       
        //remove colons (which are represented as slashes in HFS+ and vice versa) from the directory name, as they might be interpreted as actual directory seperators
        self.currentFilePrefix = [[now description] stringByReplacingOccurrencesOfString:@":" withString:@"."];
        
        //create a directory for the recordings and the file name
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory = [paths lastObject];
        //we're also using the file prefix as the name for our new directory
        self.currentRecordingDirectory = [documentDirectory stringByAppendingPathComponent:self.currentFilePrefix];
        [fileManager createDirectoryAtPath:self.currentRecordingDirectory withIntermediateDirectories:NO attributes:nil error:NULL];
        
        //init the files (and their filenames)
        [self initAccelerometerFile:self.currentFilePrefix];
        [self initGyroFile:self.currentFilePrefix];
        [self initGpsFile:self.currentFilePrefix];
        [self initCompassFile:self.currentFilePrefix];
#ifndef APP_STORE
#endif
        
        //used to determine whether the respective file has been written to
        usedAccelerometer = NO;
        usedGyro = NO;
        usedCompass = NO;
        
        isRecording = YES;
        
        NSNotification *notification = [NSNotification notificationWithName:FileWriterRecordingStatusChangedNotification
                                                                     object:self];
        [[NSNotificationQueue defaultQueue] enqueueNotification:notification 
                                                   postingStyle:NSPostWhenIdle];
    }
}

-(void)stopRecording {
    
    if (isRecording) {
        
        isRecording = NO;
        
        //close all open files
        fclose(accelerometerFile);
        fclose(gyroFile);
        fclose(compassFile);
#ifndef APP_STORE
#endif
        
        //check for usage of files and delete them if unused
        //no check if label file has been used, it is always kept
        if (!usedAccelerometer) [fileManager removeItemAtPath:self.accelerometerFileName error:NULL];
        if (!usedGyro) [fileManager removeItemAtPath:self.gyroFileName error:NULL];
        if (!usedCompass) [fileManager removeItemAtPath:self.compassFileName error:NULL];
#ifndef APP_STORE
#endif
        
        NSNotification *notification = [NSNotification notificationWithName:FileWriterRecordingStatusChangedNotification
                                                                     object:self];
        [[NSNotificationQueue defaultQueue] enqueueNotification:notification 
                                                   postingStyle:NSPostWhenIdle];
    }
}


#pragma mark -
#pragma mark file initialization methods

//creates "file", returns its "filename" and writes a header to the file containing the information provided in the arguments
-(NSString *)initTextFile:(FILE **)file withBaseFileName:(NSString *)baseFileName appendix:(NSString *)appendix dataDescription:(NSString *) description subtitle:(NSString *) subtitle columnDescriptions:(NSArray *)columnDescriptions {
    

    NSString *fileName = [[baseFileName stringByAppendingString:appendix] stringByAppendingPathExtension:@"txt"];
	NSString *completeFilePath = [currentRecordingDirectory stringByAppendingPathComponent:fileName];
	
	// create the file for the record
	*file = fopen([completeFilePath UTF8String],"a");
	
	// write an initial header
	fprintf(*file, "%% %s recorded with '%s'\n%% \n", [description UTF8String], [MY_PRODUCT_NAME UTF8String]);
	
    if (subtitle) {
        
        fprintf(*file, "%s", [subtitle UTF8String]);
    }
	
	fprintf(*file, "%% \n");
	fprintf(*file, "%% Label description:\n");	
    
	fprintf(*file, "%% \n%% Column description:\n");
    
    for (int i = 0; i < [columnDescriptions count]; i++) {
        
        fprintf(*file, "%% \t %i: %s\n", i + 1, [[columnDescriptions objectAtIndex:i] UTF8String]);
    }
	
	fprintf(*file, "%% \n%% \n");
    
    return completeFilePath;
}

- (void)initAccelerometerFile:(NSString*)name {
    
    self.accelerometerFileName = [self initTextFile:&accelerometerFile 
                                   withBaseFileName:name 
                                           appendix:kAccelerometerFileAppendix
                                  dataDescription:@"Accelerometer data"
                                           subtitle:[NSString stringWithFormat:@"%% Sampling frequency: %i Hz\n", [[NSUserDefaults standardUserDefaults] integerForKey:kAccelerometerFrequency]]
                                 columnDescriptions:[NSArray arrayWithObjects:
                                                     @"Seconds.milliseconds since 1970",
                                                     @"Number of skipped measurements",
                                                     @"Acceleration value in x-direction",
                                                     @"Acceleration value in y-direction",
                                                     @"Acceleration value in z-direction",
                                                     @"Label used for the current sample",
                                                     nil]
                                  ];
	
}

- (void)initGyroFile:(NSString*)name {
    
    self.gyroFileName = [self initTextFile:&gyroFile
                         withBaseFileName:name
                                 appendix:kGyroscopeFileAppendix
                          dataDescription:@"Gyrometer data"
                                 subtitle:nil
                       columnDescriptions:[NSArray arrayWithObjects:
                                           @"Seconds.milliseconds since 1970",
                                           @"Number of skipped measurements",
                                           @"Gyro X",
                                           @"Gyro Y",
                                           @"Gyro Z",
                                           @"Roll of the device",
                                           @"Pitch of the device",
                                           @"Yaw of the device",
                                           @"Quaternion X",
                                           @"Quaternion Y",
                                           @"Quaternion Z",
                                           @"Quaternion W",
                                           @"Label used for the current sample",
                                           nil]
                        ];
}

- (void)initCompassFile:(NSString*)name {
    
    self.compassFileName = [self initTextFile:&compassFile
                             withBaseFileName:name
                                     appendix:kCompassFileAppendix 
                              dataDescription:@"Compass data"
                                     subtitle:nil
                           columnDescriptions:[NSArray arrayWithObjects:
                                               @"Seconds.milliseconds since 1970",
                                               @"Magnetic heading in degrees starting at due north and continuing clockwise (e.g. east = 90) - negative values indicate invalid values\n% \t\t NOTE: True heading only provides valid values when GPS is activated at same time!",
                                               @"True heading in degrees starting at due north and continuing clockwise (e.g. east = 90) - negative values indicate invalid values",
                                               
                                               @"Error likelihood - negative values indicate invalid values",
                                               @"Geomagnetic data for the x-axis measured in microteslas",
                                               @"Geomagnetic data for the y-axis measured in microteslas",
                                               @"Geomagnetic data for the z-axis measured in microteslas",
                                               @"Label used for the current sample"
                                               , nil]
                            ];	
}

#pragma mark -
#pragma mark implementation of Listener protocol (writing the data)

-(void)didReceiveAccelerometerValueWithX:(double)x Y:(double)y Z:(double)z timestamp:(NSTimeInterval)timestamp label:(int)label  skipCount:(NSUInteger)skipCount {
    
    if (isRecording) {
        
		//double xVal;
		//double yVal;
		//double zVal;
		
		// If filtering is active, apply a basic high-pass filter to remove the gravity influence from the accelerometer values
		/*if (useHighPassFilter) {
         acceleration[0] = x * kFilteringFactor + acceleration[0] * (1.0 - kFilteringFactor);
         x = x - acceleration[0];
         acceleration[1] = y * kFilteringFactor + acceleration[1] * (1.0 - kFilteringFactor);
         y = y - acceleration[1];
         acceleration[2] = z * kFilteringFactor + acceleration[2] * (1.0 - kFilteringFactor);
         z = z - acceleration[2];
         }*/		
		// write the acceleration data to the file
		fprintf(accelerometerFile,"%10.3f\t %i\t %f\t %f\t %f\t %i\n", timestamp, skipCount, x, y, z, label);
        usedAccelerometer = YES;
	}
    
}

-(void)didReceiveGyroscopeValueWithX:(double)x Y:(double)y Z:(double)z roll:(double)roll pitch:(double)pitch yaw:(double)yaw quaternion:(CMQuaternion)quaternion timestamp:(NSTimeInterval)timestamp label:(int)label skipCount:(NSUInteger)skipCount {
    
    if (isRecording) {
        
		fprintf(gyroFile, "%10.3f\t %i\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %i\n", timestamp, skipCount, x, y, z, roll, pitch, yaw, quaternion.x, quaternion.y, quaternion.z, quaternion.w, label);
        usedGyro = YES;
        
	}
    
}

-(void)didReceiveCompassValueWithMagneticHeading:(double)magneticHeading trueHeading:(double)trueHeading headingAccuracy:(double)headingAccuracy X:(double)x Y:(double)y Z:(double)z timestamp:(NSTimeInterval)timestamp label:(int)label {
    
    if (isRecording) {
        
        fprintf(compassFile,"%10.3f\t %f\t %f\t %f\t %f\t %f\t %f\t %i\n", timestamp, magneticHeading, trueHeading, headingAccuracy, x, y, z, label);
        usedCompass = YES;
        
    }
}

@end
