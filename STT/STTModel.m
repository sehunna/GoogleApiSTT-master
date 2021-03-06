//
//  TTSModel.m
//  WhiteLabelCartCheckout
//
//  Created by Abdul, Karim (Contractor) on 7/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "STTModel.h"
#include "wav_to_flac.h"
#import "STTController.h"

//Url for Google Speech-To-Text Api.
NSString *googleSTT = @"https://www.google.com/speech-api/v1/recognize?xjerr=1&client=chromium&lang=en-US&maxresults=10&pfilter=0";
//NSString *googleSTT = @"https://www.google.com/speech-api/v1/recognize?xjerr=1&client=chromium&lang=ar";

@implementation STTModel

@synthesize delegate;

- (id)init {
    
    self = [super init];
    if (self) {

        
    }
    return self;
}

- (void)dealloc {
    
}

- (BOOL)convertWaveToFlac:(NSString*) inputWaveFile
           OutputFileName:(NSString*)outputFlacFile {
    
    //Input file
    NSString *waveFile = [NSString stringWithFormat:@"%@/%@",[self applicationDocumentDirectory], inputWaveFile];
    NSLog(@"waveFile %@", waveFile);
    //Output file
    //Check if output File exists
    if (![self fileExistsInDocumentFolder:outputFlacFile]) {
        if ([self successfullyCreateNewFileInApplicationDirectory:outputFlacFile]) {
            NSLog(@"file created successfully");
        }
        
        else {
            return false;
        }
    }
    
    NSString *flacFile = [NSString stringWithFormat:@"%@/%@",[self applicationDocumentDirectory], outputFlacFile];
    
    
    NSLog(@"%@",[waveFile description]);
    NSLog(@"%@",[flacFile description]);
    
    const char *wave_file = [waveFile UTF8String];
    const char *flac_file = [flacFile UTF8String];

    int conversionResult = convertWavToFlac(wave_file, flac_file);
    
    NSLog(@"%i",conversionResult);
    
    return conversionResult;
    
}

- (void)STTFromGoogle:(NSString*)fileName {
    
    NSURL *url = [NSURL URLWithString:googleSTT];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    NSString *file_Path = [NSString stringWithFormat:@"%@/%@",[self applicationDocumentDirectory], fileName];
    
    NSData *myData = [NSData dataWithContentsOfFile:file_Path];

    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"audio/x-flac; rate=16000" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:myData];
    [request setTimeoutInterval:60];
 
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               if (!error) {
                                   NSLog(@"%@",data);
                                   NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions 
                                                         error:&error];
                                   NSLog(@"%@",json);
                                   
                                   //[self.delegate audioConvertedToTextFromModel:json];
                                   [self.delegate speechToTextCompletion:response data:data error:error];
                               }
                           
                           }];
        
}

- (NSString*)applicationDocumentDirectory {
    
    NSArray *dirPaths;
    NSString *docsDir;
    
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 
                                                   NSUserDomainMask, YES);
    
    docsDir = [dirPaths objectAtIndex:0];
    NSLog(@"docs dir %@",docsDir);
    return (NSString*)docsDir;
    
}

- (BOOL)fileExistsInDocumentFolder:(NSString*)fileName {
    
    NSString *docFolder = (NSString*)[self applicationDocumentDirectory];
    NSString *_fileName = [docFolder stringByAppendingPathComponent:(NSString*)fileName];
    NSLog(@"fileName %@", _fileName);
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:_fileName];
    NSLog(@"%d",fileExists);
    return fileExists;
}

- (BOOL)successfullyCreateNewFileInApplicationDirectory:(NSString*)fileName {
    
    NSError *err;
    
    NSString *documentDirectory = [NSString stringWithFormat:@"%@/", [self applicationDocumentDirectory]];
                                   
    NSString *newfileName = [documentDirectory stringByAppendingFormat:@"%@",fileName];
                
    NSLog(@"newfileName %@", newfileName);
    //Keep it empty.
    NSString *dummyDataToWrite = @"";
                                   
    //Write to file
    NSFileManager *fileMgr = [[NSFileManager alloc] init];
    fileMgr.delegate = self;
    
    NSData *dataWithStr = [NSData dataWithContentsOfFile:dummyDataToWrite];
    
    BOOL fileResult = [fileMgr createFileAtPath:newfileName contents:dataWithStr attributes:nil];
    
    NSLog(@"error %@",err);
    NSLog(@"fileResult %d",fileResult);
    return fileResult;
                       
}

@end
