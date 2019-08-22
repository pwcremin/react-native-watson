//
//  Created by Patrick cremin on 8/2/17.
//

import Foundation
import SpeechToText
import AVFoundation
import RestKit


// SpeechToText
@objc(RNSpeechToText)
class RNSpeechToText: RCTEventEmitter {
  
  var accumulator = SpeechRecognitionResultsAccumulator()
  var speechToText: SpeechToText?
  var audioPlayer = AVAudioPlayer()
  var callback: RCTResponseSenderBlock?
  var hasListeners = false
  
  static let sharedInstance = RNSpeechToText()
  
  private override init() {}
  
  override func supportedEvents() -> [String]! {
    return ["StreamingText"]
  }
  
  @objc func initialize(_ apiKey: String) -> Void {
    speechToText = SpeechToText(apiKey: apiKey)
    speechToText.defaultHeaders = ["X-Watson-Learning-Opt-Out": "true"]
  }
  
  @objc func startStreaming(_ errorCallback: @escaping RCTResponseSenderBlock) {
    
    var settings = RecognitionSettings(contentType: "audio/ogg;codecs=opus")
    settings.interimResults = true
    settings.smartFormatting = true
    var callback = RecognizeCallback()
    
    callback.onResults = { results  in
      if(self.hasListeners)
      {
        self.accumulator.add(results: results)
        self.sendEvent(withName: "StreamingText", body: self.accumulator.bestTranscript)
      }
    }
    
    callback.onError = { (error: Error) in
      errorCallback([error])
    }

    speechToText?.recognizeMicrophone(settings: settings, callback: callback)
  }
  
  @objc func stopStreaming() {
    self.accumulator = SpeechRecognitionResultsAccumulator()
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

