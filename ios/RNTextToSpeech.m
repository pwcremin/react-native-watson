//
//  RNTextToSpeech.m
//  RNBluemixSkeleton
//
//  Created by Patrick cremin on 8/2/17.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(RNTextToSpeech, NSObject)

RCT_EXTERN_METHOD(initialize:(NSString *)username password:(NSString *)password)

RCT_EXTERN_METHOD(synthesize:(NSString *)text voice:(NSString *)voice
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(getVoices: (RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

@end
