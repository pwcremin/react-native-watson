import { NativeEventEmitter, NativeModules, Platform } from 'react-native';

let {
    RNTextToSpeech,
    RNSpeechToText,
    RNToneAnalyzer,
    RNNaturalLanguageUnderstanding,
    RNConversation
} = NativeModules

module.exports = {
    TextToSpeech: {
        initialize: function ( username, password )
        {
            RNTextToSpeech.initialize( username, password );
        },

        synthesize: function ( text, voice )
        {
            return RNTextToSpeech.synthesize( text, voice );
        },

        getVoices: function ()
        {
            return RNTextToSpeech.getVoices();
        }
    },

    Conversation: {
        initialize: function ( username, password )
        {
            RNConversation.initialize( username, password );
        },

        message: function ( workspaceId, input )
        {
            input = input || {}

            return RNConversation.message( workspaceId, input )
                .then(response =>
                {
                    if(Platform.OS === "android")
                    {
                        response = JSON.parse(response)
                    }
                    else if(Platform.OS === "ios" && response.context)
                    {
                        // need to correct key names
                        response.context.conversation_id = response.context.conversationID
                        delete response.context.conversationID
                        response.context.system.dialog_turn_counter = response.context.system.dialogTurnCounter
                        delete response.context.system.dialogTurnCounter
                        response.context.system.dialog_stack = response.context.system.dialogStack
                        delete response.context.system.dialogStack
                        response.context.system.dialog_request_counter = response.context.system.dialogRequestCounter
                        delete response.context.system.dialogRequestCounter
                    }

                    return response
                });

        }
    },

    SpeechToText: {
        speechToTextEmitter: new NativeEventEmitter( RNSpeechToText ),

        initialize: function ( username, password )
        {
            RNSpeechToText.initialize( username, password );
        },

        startStreaming( callback )
        {
            this.subscription = this.speechToTextEmitter.addListener(
                'StreamingText',
                ( text ) => callback( null, text )
            );

            RNSpeechToText.startStreaming( callback )
        },

        stopStreaming()
        {
            this.subscription.remove()

            RNSpeechToText.stopStreaming()
        }
    },

    ToneAnalyzer: {
        tones: {
            emotion: 'emotion',
            language: 'language',
            social: 'social'
        },

        initialize: function ( username, password )
        {
            RNToneAnalyzer.initialize( username, password );
        },

        getTone: function ( ofText, tones = ['emotion', 'language', 'social'], sentences = true, callback )
        {
            return RNToneAnalyzer.getTone( ofText )
                //.then( toneAnalysis => typeof toneAnalysis === 'string' ? JSON.parse(toneAnalysis) : toneAnalysis)
        }
    },

    NaturalLanguageUnderstanding: {

        initialize: function ( username, password )
        {
            RNNaturalLanguageUnderstanding.initialize( username, password );
        },

        /**
         * @param {Object}  contentToAnalyze Choose text, url or html
         * @param {string}  contentToAnalyze.text The plain text to analyze
         * @param {string}  contentToAnalyze.url Specific features to analyze the document for
         * @param {string}  contentToAnalyze.html The web page to analyze
         *
         * @param {Object}  features.concepts
         * @param {number}  features.concepts.limit Maximum number of concepts to return
         *
         * @param {bool}    features.categories The hierarchical 5-level taxonomy the content is categorized into
         * @param {bool}    features.metadata The Authors, Publication Date, and Title of the document. Supports URL and HTML input types
         * @param {bool}    features.relations An option specifying if the relationships found between entities in the analyzed content should be returned
         *
         * @param {bool}    features.emotion.document Set this to false to hide document-level emotion results
         * @param {string[]}   features.emotion.targets Emotion results will be returned for each target string that is found in the document
         *
         * @param {bool}    features.sentiment.document Set this to false to hide document-level emotion results
         * @param {string[]}   features.sentiment.targets Sentiment results will be returned for each target string that is found in the document
         *
         * @param {bool}    features.entities.emotion Set this to true to analyze emotion for detected keywords
         * @param {bool}    features.entities.sentiment Set this to true to return sentiment information for detected entities
         * @param {number}  features.entities.limit Maximum number of entities to return
         *
         * @param {bool}    features.keywords.emotion Set this to true to analyze emotion for detected keywords
         * @param {bool}    features.keywords.sentiment Set this to true to return sentiment information for detected keywords
         * @param {number}  features.keywords.limit Maximum number of keywords to return
         *
         * @param {bool}    features.semanticRoles.keywords Set this to true to return keyword information for subjects and objects
         * @param {bool}    features.semanticRoles.entities Set this to true to return entity information for subjects and objects
         * @param {number}  features.semanticRoles.limit Maximum number of keywords to return
         *
         * @returns {Promise}
         */
        analyzeContent: function ( contentToAnalyze, features )
        {
            return RNNaturalLanguageUnderstanding.analyzeContent(contentToAnalyze, features )
                .then( results => Platform.OS === "android" ? JSON.parse(results) : results )
        }
    },

    //
    // VisualRecognition: {
    //     initialize: function ( apiKey )
    //     {
    //         RNVisualRecognition.initialize( apiKey );
    //     },
    //
    //     /** Upload and classify an image or multiple images
    //      * @param {array} imageFiles file paths of images to be classified.  The total number of images is limited to 20, with a max .zip size of 5 MB.
    //      * @param {object} [config]
    //      * @param {string[]} config.owners A list of the classifiers to run. Acceptable values are "IBM" and "me".
    //      * @param {string[]} config.classifierIDs A list of the classifier ids to use. "default" is the id of the built-in classifier.
    //      * @param {number} config.threshold The minimum score a class must have to be displayed in the response.
    //      * @param {string} config.language The language of the output class names. Can be "en" (English), "es" (Spanish), "ar" (Arabic), or "ja" (Japanese). Classes for which no translation is available are omitted.
    //      * @returns {Promise}
    //      */
    //     classify(imageFiles, config = {})
    //     {
    //         return RNVisualRecognition.classify(imageFiles, config)
    //     }
    // }
}