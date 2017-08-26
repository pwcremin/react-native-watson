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
import ToneAnalyzerV3
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

// ToneAnalyzer
@objc(RNToneAnalyzer)
class RNToneAnalyzer: NSObject {
  
  var toneAnalyzer: ToneAnalyzer?
  
  static let sharedInstance = RNToneAnalyzer()
  
  private override init() {}
  
  @objc func initialize(_ username: String, password: String) -> Void {
    toneAnalyzer = ToneAnalyzer(username: username, password: password, version: "2017-08-22")
  }
  
  //tones: [String], sentences: Bool,
  @objc func getTone(_ ofText: String,
                     resolver resolve: @escaping RCTPromiseResolveBlock,
                     rejecter reject: @escaping RCTPromiseRejectBlock) {
    
    let failure = { (error: Error) in reject(nil, nil, error) }
    
    toneAnalyzer?.getTone(ofText: ofText, failure: failure){ tones in
      
        resolve(tones.toDictionary())
    }
  }
}

// Mappings
// TODO may be better to use Codable instead

extension ToneAnalyzerV3.ToneAnalysis : Serializable {
  var properties: Array<String> {
    return ["documentTone", "sentencesTones"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "documentTone":
      return documentTone
    case "sentencesTones":
      return sentencesTones
    default:
      return nil
    }
  }
}

extension ToneAnalyzerV3.ToneCategory : Serializable {
  var properties: Array<String> {
    return ["name", "categoryID", "tones"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "name":
      return name
    case "categoryID":
      return categoryID
    case "tones":
      return tones
    default:
      return nil
    }
  }
}

extension ToneAnalyzerV3.ToneScore : Serializable {
  var properties: Array<String> {
    return ["id", "name", "score"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "id":
      return id
    case "name":
      return name
    case "score":
      return score
    default:
      return nil
    }
  }
}

extension ToneAnalyzerV3.SentenceAnalysis : Serializable {
  var properties: Array<String> {
    return ["sentenceID", "inputFrom", "inputTo", "text", "toneCategories"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "sentenceID":
      return sentenceID
    case "inputFrom":
      return inputFrom
    case "inputTo":
      return inputTo
    case "text":
      return text
    case "toneCategories":
      return toneCategories
    default:
      return nil
    }
  }
}

protocol Serializable {
  var properties:Array<String> { get }
  func valueForKey(key: String) -> Any?
  func toDictionary() -> [String:Any]
}

extension Serializable {
  func toDictionary() -> [String:Any] {
    var dict:[String:Any] = [:]
    
    for prop in self.properties {
      if let val = self.valueForKey(key: prop) as? String {
        dict[prop] = val
      } else if let val = self.valueForKey(key: prop) as? Int {
        dict[prop] = val
      } else if let val = self.valueForKey(key: prop) as? Double {
        dict[prop] = val
      } else if let val = self.valueForKey(key: prop) as? Array<String> {
        dict[prop] = val
      } else if let val = self.valueForKey(key: prop) as? Serializable {
        dict[prop] = val.toDictionary()
      } else if let val = self.valueForKey(key: prop) as? Array<Serializable> {
        var arr = Array<[String:Any]>()
        
        for item in (val as Array<Serializable>) {
          arr.append(item.toDictionary())
        }
        
        dict[prop] = arr
      }
    }
    
    return dict
  }
}




