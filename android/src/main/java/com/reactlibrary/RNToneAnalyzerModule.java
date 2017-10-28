
package com.reactlibrary;

import com.facebook.react.bridge.Arguments;
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

import com.ibm.watson.developer_cloud.tone_analyzer.v3.ToneAnalyzer;
import com.ibm.watson.developer_cloud.tone_analyzer.v3.model.ToneAnalysis;
import com.ibm.watson.developer_cloud.tone_analyzer.v3.model.ToneOptions;

import java.io.InputStream;


public class RNToneAnalyzerModule extends ReactContextBaseJavaModule {

    private ReactApplicationContext reactContext;
    private ToneAnalyzer service = new ToneAnalyzer("2017-08-22");

    public RNToneAnalyzerModule(ReactApplicationContext reactContext) {
        super(reactContext);

        this.reactContext = reactContext;
    }

    @Override
    public String getName() {
        return "RNToneAnalyzer";
    }

    @ReactMethod
    public void initialize(String username, String password) {
        service.setUsernameAndPassword(username, password);
        service.setEndPoint("https://gateway.watsonplatform.net/tone-analyzer/api");
    }

    @ReactMethod
    public void getTone(String text, Promise promise) {

        try {
            // TODO let them set tones and sentences
            // TODO needs to handle html and other options for getting tone
            ToneOptions options = new ToneOptions.Builder().text(text).build();

            ToneAnalysis toneAnalysis = service.tone(options).execute();

            promise.resolve(toneAnalysis.toString());
        }
        catch (Exception e) {
            promise.reject(null, e);
        }
    }
}