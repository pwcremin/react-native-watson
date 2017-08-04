var RNTextToSpeech = require( 'react-native' ).NativeModules.RNTextToSpeech;

module.exports = {
    initialize: function ( username, password )
    {
        return RNTextToSpeech.initialize( username, password );
    },

    synthesize: function ( text, voice )
    {
        return RNTextToSpeech.synthesize( text, voice );
    },

    getVoices: function ( )
    {
        return RNTextToSpeech.getVoices( );
    },

}