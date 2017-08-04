//
//  RNTextToSpeech.swift
//  RNBluemixBoilerplate
//
//  Created by Patrick cremin on 8/2/17.
//  Copyright © 2017 Facebook. All rights reserved.
//

import Foundation
import TextToSpeechV1
import SpeechToTextV1
import AVFoundation

// TextToSpeech
@objc(RNTextToSpeech)
class RNTextToSpeech: NSObject {
  
  var textToSpeech: TextToSpeech?
  var audioPlayer = AVAudioPlayer()
  
  static let sharedInstance = RNTextToSpeech()
  private override init() {}
  
  @objc func initialize(_ username: String, password: String) -> Void {
      textToSpeech = TextToSpeech(username: username, password: password)
  }
  
  @objc func synthesize(_ text: String, voice: String,
                        resolver resolve: RCTPromiseResolveBlock,
                        rejecter reject: @escaping RCTPromiseRejectBlock) -> Void {
    
    var synthesizeVoice = voice
    
    if synthesizeVoice.isEmpty {
      synthesizeVoice = "en-GB_KateVoice"
    }
    
    let failure = { (error: Error) in reject(nil, nil, error) }
    
    textToSpeech?.synthesize(text, voice: synthesizeVoice, failure: failure) { data in
      self.audioPlayer = try! AVAudioPlayer(data: data)
      self.audioPlayer.prepareToPlay()
      self.audioPlayer.play()
    }
  }
  
  //*/
  //public func getVoices(failure: ((Error) -> Swift.Void)? = default, success: @escaping ([TextToSpeechV1.Voice]) -> Swift.Void)
  
  @objc func getVoices(_ resolve: @escaping RCTPromiseResolveBlock,
                       rejecter reject: @escaping RCTPromiseRejectBlock ) -> Void {
    
    let failure = { (error: Error) in reject(nil, nil, error) }
    
    let success = { (voices: [Voice]) -> Void in
      var voicesArray = [[String: String]]()
      
      for voice in voices {
        voicesArray.append([
          "name": voice.name,
          "url": voice.url,
          "description": voice.description,
          "gender": voice.gender,
          "language": voice.language
        ])
      }
      
      enum VendingMachineError: Error {
        case invalidSelection
        case insufficientFunds(coinsNeeded: Int)
        case outOfStock
      }
      
      resolve(voicesArray)
    }
      
    
    textToSpeech?.getVoices(failure: failure, success: success )
    
  }
}

// SpeechToText
@objc(RNSpeechToText)
class RNSpeechToText: RCTEventEmitter {
  
  var speechToText: SpeechToText?
  var audioPlayer = AVAudioPlayer()
  var callback: RCTResponseSenderBlock?
  var hasListeners = false
  
  static let sharedInstance = RNSpeechToText()
  
  private override init() {}
  
  override func supportedEvents() -> [String]! {
    return ["StreamingText"]
  }
  
  @objc func initialize(_ username: String, password: String) -> Void {
    speechToText = SpeechToText(username: username, password: password)
  }
  
  @objc func startStreaming(_ errorCallback: @escaping RCTResponseSenderBlock) {
    
    var settings = RecognitionSettings(contentType: .opus)
    settings.interimResults = true
    
    let failure = { (error: Error) in errorCallback([error]) }
    
    speechToText?.recognizeMicrophone(settings: settings, failure: failure) { results in
      if(self.hasListeners)
      {
        self.sendEvent(withName: "StreamingText", body: results.bestTranscript)
      }
    }
  }
  
  @objc func stopStreaming() {
    speechToText?.stopRecognizeMicrophone()
  }
  
  override func startObserving()
  {
    hasListeners = true
  }
  
  override func stopObserving()
  {
    hasListeners = false
  }
}



