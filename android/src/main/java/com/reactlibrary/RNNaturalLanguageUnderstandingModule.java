package com.reactlibrary;

import android.support.annotation.RequiresPermission;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.ReadableMapKeySetIterator;
import com.ibm.watson.developer_cloud.natural_language_understanding.v1.NaturalLanguageUnderstanding;
import com.ibm.watson.developer_cloud.natural_language_understanding.v1.model.AnalysisResults;
import com.ibm.watson.developer_cloud.natural_language_understanding.v1.model.AnalyzeOptions;
import com.ibm.watson.developer_cloud.natural_language_understanding.v1.model.CategoriesOptions;
import com.ibm.watson.developer_cloud.natural_language_understanding.v1.model.ConceptsOptions;
import com.ibm.watson.developer_cloud.natural_language_understanding.v1.model.EmotionOptions;
import com.ibm.watson.developer_cloud.natural_language_understanding.v1.model.EntitiesOptions;
import com.ibm.watson.developer_cloud.natural_language_understanding.v1.model.Features;
import com.ibm.watson.developer_cloud.natural_language_understanding.v1.model.KeywordsOptions;
import com.ibm.watson.developer_cloud.natural_language_understanding.v1.model.MetadataOptions;
import com.ibm.watson.developer_cloud.natural_language_understanding.v1.model.RelationsOptions;
import com.ibm.watson.developer_cloud.natural_language_understanding.v1.model.SemanticRolesOptions;
import com.ibm.watson.developer_cloud.natural_language_understanding.v1.model.SentimentOptions;
import com.ibm.watson.developer_cloud.service.model.GenericModel;

import java.util.List;
import java.util.Map;


/**
 * Created by patrickcremin on 10/19/17.
 */

public class RNNaturalLanguageUnderstandingModule extends ReactContextBaseJavaModule {

    private NaturalLanguageUnderstanding service = new NaturalLanguageUnderstanding("2017-08-22");

    public RNNaturalLanguageUnderstandingModule(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    public String getName() {
        return "RNNaturalLanguageUnderstanding";
    }

    @ReactMethod
    public void initialize(String username, String password) {
        service.setUsernameAndPassword(username, password);
        service.setEndPoint("https://gateway.watsonplatform.net/natural-language-understanding/api");
    }

    @ReactMethod
    public void analyzeContent(ReadableMap contentToAnalyze, ReadableMap featuresMap, Promise promise) {

        Features features = this.getFeatures( featuresMap );

        AnalyzeOptions parameters = this.getParameters(contentToAnalyze, features);

        try {
            promise.resolve(
                    service.analyze(parameters).execute().toString()
            );
        } catch (Exception e) {
            promise.reject(null, e);
        }
    }

    private AnalyzeOptions getParameters( ReadableMap contentToAnalyze, Features features )
    {
        AnalyzeOptions.Builder analyzeBuilder = new AnalyzeOptions.Builder();

        if (contentToAnalyze.hasKey("url")) {
            analyzeBuilder.url(contentToAnalyze.getString("url"));
        }

        if (contentToAnalyze.hasKey("html")) {
            analyzeBuilder.html(contentToAnalyze.getString("html"));
        }

        if (contentToAnalyze.hasKey("text")) {
            analyzeBuilder.text(contentToAnalyze.getString("text"));
        }
        
        return analyzeBuilder.features(features).build();
    }

    private Features getFeatures(ReadableMap featuresMap)
    {
        Features.Builder featuresBuilder = new Features.Builder();//.entities(entities).build();

        ReadableMapKeySetIterator iterator = featuresMap.keySetIterator();

        while (iterator.hasNextKey()) {
            String key = iterator.nextKey();

            switch (key) {
                case "concepts":
                    int limit = featuresMap.getMap("concepts").getInt("limit");
                    ConceptsOptions conceptsOptions = new ConceptsOptions.Builder().limit(limit).build();
                    featuresBuilder.concepts(conceptsOptions);
                    break;
                case "categories":
                    CategoriesOptions categoriesOptions = new CategoriesOptions();
                    featuresBuilder.categories(categoriesOptions);
                    break;
                case "metadata":
                    MetadataOptions metadataOptions = new MetadataOptions();
                    featuresBuilder.metadata(metadataOptions);
                    break;
                case "semanticRoles": {
                    ReadableMap map = featuresMap.getMap("semanticRoles");
                    SemanticRolesOptions.Builder semanticRolesBuilder = new SemanticRolesOptions.Builder();

                    if (map.hasKey("keywords")) {
                        semanticRolesBuilder.keywords(map.getBoolean("keywords"));
                    }

                    if (map.hasKey("limit")) {
                        semanticRolesBuilder.limit(map.getInt("limit"));
                    }

                    if (map.hasKey("entities")) {
                        semanticRolesBuilder.entities(map.getBoolean("entities"));
                    }

                    featuresBuilder.semanticRoles(semanticRolesBuilder.build());
                    break;
                }
                case "relations":
                    RelationsOptions relationsOptions = new RelationsOptions.Builder().build();
                    featuresBuilder.relations(relationsOptions);
                    break;
                case "sentiment": {
                    ReadableMap map = featuresMap.getMap("sentiment");

                    SentimentOptions.Builder sentimentOptions = new SentimentOptions.Builder();

                    if (map.hasKey("document")) {
                        sentimentOptions.document(map.getBoolean("document"));
                    }

                    if (map.hasKey("targets")) {
                        List<String> targets = (List<String>) (List<?>) map.getArray("targets").toArrayList();
                        sentimentOptions.targets(targets);
                    }

                    featuresBuilder.sentiment(sentimentOptions.build());
                    break;
                }
                case "keywords": {
                    ReadableMap map = featuresMap.getMap("keywords");
                    KeywordsOptions.Builder keywordsBuilder = new KeywordsOptions.Builder();

                    if (map.hasKey("emotion")) {
                        keywordsBuilder.emotion(map.getBoolean("emotion"));
                    }

                    if (map.hasKey("limit")) {
                        keywordsBuilder.limit(map.getInt("limit"));
                    }

                    if (map.hasKey("sentiment")) {
                        keywordsBuilder.sentiment(map.getBoolean("sentiment"));
                    }

                    featuresBuilder.keywords(keywordsBuilder.build());
                    break;
                }
                case "entities": {
                    ReadableMap map = featuresMap.getMap("entities");
                    EntitiesOptions.Builder entitiesBuilder = new EntitiesOptions.Builder();

                    if (map.hasKey("emotion")) {
                        entitiesBuilder.emotion(map.getBoolean("emotion"));
                    }

                    if (map.hasKey("limit")) {
                        entitiesBuilder.limit(map.getInt("limit"));
                    }

                    if (map.hasKey("sentiment")) {
                        entitiesBuilder.sentiment(map.getBoolean("sentiment"));
                    }

                    featuresBuilder.entities(entitiesBuilder.build());
                    break;
                }
                case "emotion": {
                    ReadableMap map = featuresMap.getMap("emotion");

                    EmotionOptions.Builder emotionBuilder = new EmotionOptions.Builder();

                    if (map.hasKey("document")) {
                        emotionBuilder.document(map.getBoolean("document"));
                    }

                    if (map.hasKey("targets")) {
                        List<String> targets = (List<String>) (List<?>) map.getArray("targets").toArrayList();
                        emotionBuilder.targets(targets);
                    }

                    featuresBuilder.emotion(emotionBuilder.build());
                    break;
                }
            }
        }

        Features features = featuresBuilder.build();

        return features;
    }
}
