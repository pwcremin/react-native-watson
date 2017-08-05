
package com.reactlibrary;

import android.media.AudioFormat;
import android.media.AudioManager;
import android.media.AudioTrack;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.ibm.watson.developer_cloud.text_to_speech.v1.TextToSpeech;
import com.ibm.watson.developer_cloud.text_to_speech.v1.model.Voice;

import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
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
        InputStream inputStream = service.synthesize(text, Voice.EN_ALLISON).execute();

        byte[] buf;
        int size = 1024;

        if (inputStream instanceof ByteArrayInputStream) {
            try {
                size = inputStream.available();
            } catch (IOException e) {
                promise.reject(null, e);
            }
        }

        buf = new byte[size];

        audioTrack.play();

        try {
            int k;
            while ((k = inputStream.read(buf)) != -1) {
                audioTrack.write(buf, 0, k);
            }
        } catch (IOException e) {
            promise.reject(null, e);
        }
    }

    @ReactMethod
    public void getVoices(Promise promise) {
        try {
            List<Voice> voices = service.getVoices().execute();
            promise.resolve(voices);
        } catch (Exception e) {
            promise.reject(null, e);
        }
    }
}