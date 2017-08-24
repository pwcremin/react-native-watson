import { NativeEventEmitter, NativeModules } from 'react-native';

let {
    RNTextToSpeech,
    RNSpeechToText,
    RNToneAnalyzer
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
        },
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
                .then( toneAnalysis => typeof toneAnalysis === 'string' ? JSON.parse(toneAnalysis) : toneAnalysis)
        }
    }
}