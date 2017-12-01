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


@interface RCT_EXTERN_MODULE(RNToneAnalyzer, NSObject)

RCT_EXTERN_METHOD(initialize:(NSString *)username password:(NSString *)password)

RCT_EXTERN_METHOD(getTone:(NSString *)ofText
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

@end


@interface RCT_EXTERN_MODULE(RNNaturalLanguageUnderstanding, NSObject)

RCT_EXTERN_METHOD(initialize:(NSString *)username password:(NSString *)password)

RCT_EXTERN_METHOD(analyzeContent:(NSDictionary *)contentToAnalyze featuresDict:(NSDictionary *)featuresDict
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
@end

@interface RCT_EXTERN_MODULE(RNConversation, NSObject)

RCT_EXTERN_METHOD(initialize:(NSString *)username password:(NSString *)password)

RCT_EXTERN_METHOD(message:(NSString *)workspaceID inputDict: (NSDictionary *) inputDict
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
@end
