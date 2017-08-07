
package com.reactlibrary;

import android.media.AudioFormat;
import android.media.AudioManager;
import android.media.AudioTrack;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableNativeArray;
import com.facebook.react.bridge.WritableNativeMap;

import com.ibm.watson.developer_cloud.android.library.audio.StreamPlayer;

import com.ibm.watson.developer_cloud.dialog.v1.model.Message;
import com.ibm.watson.developer_cloud.text_to_speech.v1.TextToSpeech;
import com.ibm.watson.developer_cloud.text_to_speech.v1.model.Voice;

import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.List;

public class RNTextToSpeechModule extends ReactContextBaseJavaModule {

    private ReactApplicationContext reactContext;
    private TextToSpeech service = new TextToSpeech();
    private AudioTrack audioTrack;

    public RNTextToSpeechModule(ReactApplicationContext reactContext) {
        super(reactContext);

        this.reactContext = reactContext;

        int minBufferSize = AudioTrack.getMinBufferSize(
                22000,
                AudioFormat.CHANNEL_OUT_STEREO, AudioFormat.ENCODING_PCM_16BIT);

        audioTrack = new AudioTrack(AudioManager.STREAM_MUSIC, 22000
                , AudioFormat.CHANNEL_OUT_STEREO, AudioFormat.ENCODING_PCM_16BIT, minBufferSize,
                AudioTrack.MODE_STREAM);
    }

    @Override
    public String getName() {
        return "RNTextToSpeech";
    }

    @ReactMethod
    public void initialize(String username, String password) {
        service.setUsernameAndPassword(username, password);
    }

    @ReactMethod
    public void synthesize(String text, String voice, Promise promise) {

        try {

            StreamPlayer streamPlayer = new StreamPlayer();

            streamPlayer.playStream(service.synthesize(text, new Voice(voice, null, null)).execute());

        } catch (Exception e) {
            e.printStackTrace();
        }

    }

    @ReactMethod
    public void getVoices(Promise promise) {
        try {
            List<Voice> voices = service.getVoices().execute();

            WritableArray voicesArray = new WritableNativeArray();

            for(Voice voice : voices){
                WritableMap voiceMap = new WritableNativeMap();

                voiceMap.putString("name", voice.getName());
                voiceMap.putString("url", voice.getUrl());
                voiceMap.putString("description", voice.getDescription());
                voiceMap.putString("gender", voice.getGender());
                voiceMap.putString("language", voice.getLanguage());

                voicesArray.pushMap(voiceMap);
            }

            promise.resolve(voicesArray);
        } catch (Exception e) {
            promise.reject(null, e);
        }
    }
}