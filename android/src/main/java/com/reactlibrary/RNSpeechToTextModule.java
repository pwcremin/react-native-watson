
package com.reactlibrary;

import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableNativeArray;
import com.facebook.react.bridge.WritableNativeMap;

import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.ibm.watson.developer_cloud.android.library.audio.MicrophoneInputStream;

import com.ibm.watson.developer_cloud.android.library.audio.utils.ContentType;
import com.ibm.watson.developer_cloud.speech_to_text.v1.SpeechToText;
import com.ibm.watson.developer_cloud.speech_to_text.v1.model.RecognizeOptions;
import com.ibm.watson.developer_cloud.speech_to_text.v1.model.SpeechResults;
import com.ibm.watson.developer_cloud.speech_to_text.v1.websocket.BaseRecognizeCallback;

import java.io.InputStream;


public class RNSpeechToTextModule extends ReactContextBaseJavaModule {

    private ReactApplicationContext reactContext;
    private SpeechToText service = new SpeechToText();
    private MicrophoneInputStream capture;
    private Callback errorCallback;

    public RNSpeechToTextModule(ReactApplicationContext reactContext) {
        super(reactContext);

        this.reactContext = reactContext;
    }

    @Override
    public String getName() {
        return "RNSpeechToText";
    }

    @ReactMethod
    public void initialize(String username, String password) {
        service.setUsernameAndPassword(username, password);
        service.setEndPoint("https://stream.watsonplatform.net/speech-to-text/api");
    }

    @ReactMethod
    public void startStreaming(Callback errorCallback) {

        this.errorCallback = errorCallback;
        capture = new MicrophoneInputStream(true);

        try {
            service.recognizeUsingWebSocket(capture, getRecognizeOptions(), new MicrophoneRecognizeDelegate(reactContext, errorCallback));
        } catch (Exception e) {
            errorCallback.invoke(e.getMessage());
        }
    }

    @ReactMethod
    public void stopStreaming() {
        try {
            capture.close();
        }
        catch (Exception e) {
            errorCallback.invoke(e.getMessage());
        }
    }

    private RecognizeOptions getRecognizeOptions() {
        return new RecognizeOptions.Builder()
                .contentType(ContentType.OPUS.toString())
                .model("en-US_BroadbandModel")
                .interimResults(true)
                .inactivityTimeout(2000)
                .build();
    }

    private class MicrophoneRecognizeDelegate extends BaseRecognizeCallback {

        private ReactApplicationContext reactContext;
        private Callback errorCallback;

        public MicrophoneRecognizeDelegate(ReactApplicationContext reactContext, Callback errorCallback) {
            this.reactContext = reactContext;
            this.errorCallback = errorCallback;
        }

        @Override
        public void onTranscription(SpeechResults speechResults) {
            if(speechResults.getResults() != null && !speechResults.getResults().isEmpty()) {
                String text = speechResults.getResults().get(0).getAlternatives().get(0).getTranscript();

                reactContext
                        .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                        .emit("StreamingText", text);
            }
        }

        @Override public void onError(Exception e) {
            errorCallback.invoke(e.getMessage());
        }

        @Override public void onDisconnected() {

        }
    }
}