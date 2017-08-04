//
//  RNTextToSpeech.m
//  RNBluemixBoilerplate
//
//  Created by Patrick cremin on 8/2/17.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(RNTextToSpeech, NSObject)

// TextToSpeech
RCT_EXTERN_METHOD(initialize:(NSString *)username password:(NSString *)password)

RCT_EXTERN_METHOD(synthesize:(NSString *)text voice:(NSString *)voice
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(getVoices: (RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

@end


@interface RCT_EXTERN_MODULE(RNSpeechToText, NSObject)

RCT_EXTERN_METHOD(initialize:(NSString *)username password:(NSString *)password)

RCT_EXTERN_METHOD(startStreaming: (RCTResponseSenderBlock *)errorCallback)

RCT_EXTERN_METHOD(stopStreaming)

@end