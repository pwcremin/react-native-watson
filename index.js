import { NativeEventEmitter, NativeModules, Platform } from "react-native";

const { RNSpeechToText } = NativeModules;

module.exports = {
  SpeechToText: {
    speechToTextEmitter: new NativeEventEmitter(RNSpeechToText),

    initialize: function(apiKey) {
      RNSpeechToText.initialize(apiKey);
    },

    startStreaming(callback) {
      this.subscription = this.speechToTextEmitter.addListener(
        "StreamingText",
        text => callback(null, text)
      );

      RNSpeechToText.startStreaming(callback);
    },

    stopStreaming() {
      this.subscription.remove();

      RNSpeechToText.stopStreaming();
    }
  }
};
