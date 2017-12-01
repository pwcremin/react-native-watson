
package com.reactlibrary;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableNativeArray;
import com.facebook.react.bridge.WritableNativeMap;

import com.ibm.watson.developer_cloud.conversation.v1.Conversation;
import com.ibm.watson.developer_cloud.conversation.v1.model.Context;
import com.ibm.watson.developer_cloud.conversation.v1.model.InputData;
import com.ibm.watson.developer_cloud.conversation.v1.model.MessageOptions;
import com.ibm.watson.developer_cloud.conversation.v1.model.MessageResponse;
import com.ibm.watson.developer_cloud.conversation.v1.model.SystemResponse;
import com.ibm.watson.developer_cloud.service.model.DynamicModel;

import java.io.InputStream;
import java.util.HashMap;

import okhttp3.Response;


public class RNConversationModule extends ReactContextBaseJavaModule {

    private Conversation service = new Conversation("2017-08-22");

    public RNConversationModule(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    public String getName() {
        return "RNConversation";
    }

    @ReactMethod
    public void initialize(String username, String password) {
        service.setUsernameAndPassword(username, password);
        service.setEndPoint("https://gateway.watsonplatform.net/conversation/api");
    }

    @ReactMethod
    public void message( String workspaceId, ReadableMap input, Promise promise) {

        MessageOptions.Builder optionsBuilder = new MessageOptions.Builder(workspaceId);

        optionsBuilder.workspaceId(workspaceId);

        try {
            Context context = new Context();

            if (input.hasKey("text")) {
                InputData inputData = new InputData.Builder().text(input.getString("text")).build();

                optionsBuilder.input(inputData);
            }

            if (input.hasKey("context")) {
                HashMap<String, Object> hm = input.getMap("context").getMap("system").toHashMap();

                SystemResponse sr = new SystemResponse();
                sr.putAll(hm);

                context.setConversationId(workspaceId);
                context.setSystem(sr);

                optionsBuilder.context(context);
            }

            MessageResponse response = service.message(optionsBuilder.build()).execute();

            promise.resolve(response.toString());
        }
        catch (Exception e) {
            promise.reject(null, e);
        }
    }
}