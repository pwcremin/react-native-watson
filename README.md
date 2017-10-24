# react-native-bluemix
[![npm version](https://badge.fury.io/js/react-native-bluemix.svg)](https://badge.fury.io/js/react-native-bluemix)


## Overview
React Native module (ios and android) for using select Bluemix services.  Access to Watson services is provided by wrapping the [Watson Developer Cloud](https://github.com/watson-developer-cloud/swift-sdk)

There is example code for all services in the [rn-bluemix-boilerplate](https://github.com/pwcremin/rn-bluemix-boilerplate) repo.  This is also a great repo to get you up and running quickly with a new React Native project that uses the most popular modules.

### Services

* [Text to Speech](#text-to-speech)
* [Speech to Text](#speech-to-text)
* [Tone Analyzer](#tone-analyzer)

## Install

```shell
npm install --save react-native-bluemix

```
## Android
Android installation is done with ```react-native link react-native-bluemix```

## iOS

### Manually link

Copy RNBluemix.m and RNBluemix.swift from node_modules/react-native-bluemix/ios into your project.  You will be prompted to create a bridging header.  Accept and place the below into the header:

```obj-c
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
```

#### Dependency Management

We recommend using [Carthage](https://github.com/Carthage/Carthage) to manage dependencies and build the Swift SDK for your application.

You can install Carthage with [Homebrew](http://brew.sh/):

```bash
$ brew update
$ brew install carthage
```

Then, navigate to the root directory of your project (where your .xcodeproj file is located) and create an empty `Cartfile` there:

```bash
$ touch Cartfile
```

To use the Watson Developer Cloud Swift SDK in your application, specify it in your `Cartfile`:

```
github "watson-developer-cloud/swift-sdk"
```

In a production app, you may also want to specify a [version requirement](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#version-requirement).

Then run the following command to build the dependencies and frameworks:

```bash
$ carthage update --platform iOS
```

##### Add the Frameworks to your project

Drag-and-drop the built frameworks into your Xcode project (put them in a Frameworks group for better management).  You will also need to click on your project in Xcode and go to the General section.  Add all of the frameworks to Embedded Binaries.

Note, before you can upload to itunesconnect your will need to strip unwanted architectures from the frameworks.  This is done easily with a build script.  See the following link for instructions: http://ikennd.ac/blog/2015/02/stripping-unwanted-architectures-from-dynamic-libraries-in-xcode/

## Service Instances

Services are instantiated using the [IBM Bluemix](http://www.ibm.com/cloud-computing/bluemix/) cloud platform.

Follow these steps to create a service instance and obtain its credentials:

1. Log in to Bluemix at [https://bluemix.net](https://bluemix.net).
2. Create a service instance:
    1. From the Dashboard, select "Use Services or APIs".
    2. Select the service you want to use.
    3. Click "Create".
3. Copy your service credentials:
    1. Click "Service Credentials" on the left side of the page.
    2. Copy the service's `username` and `password` (or `api_key` for Alchemy).

You will need to provide these service credentials in your application. For example:

```javascript
TextToSpeech.initialize("your-username-here", "your-password-here")
```

Note that service credentials are different from your Bluemix username and password.

See [Getting Started](https://www.ibm.com/watson/developercloud/doc/common/index.html) for more information on getting started with the Watson Developer Cloud and Bluemix.

## Text to Speech

The IBM Watson Text to Speech service synthesizes natural-sounding speech from input text in a variety of languages and voices that speak with appropriate cadence and intonation.

```javascript
import {TextToSpeech} from 'react-native-bluemix';
TextToSpeech.initialize("username", "password")
TextToSpeech.synthesize( "Text to speech, easy" )
```

Change the voice

```javascript
TextToSpeech.synthesize( "Text to speech, easy", "en-US_AllisonVoice" )
```

Get all voices that you can use

```javascript
TextToSpeech.getVoices()
            .then( voices =>  voices.forEach( voice => console.log(voice.name) ) )
```

## Speech to Text

The IBM Watson Speech to Text service enables you to add speech transcription capabilities to your application. It uses machine intelligence to combine information about grammar and language structure to generate an accurate transcription. 

```javascript
import {SpeechToText} from 'react-native-bluemix';

SpeechToText.initialize("username", "password")

// will transcribe microphone audio
SpeechToText.startStreaming((error, text) =>
        {
            console.log(text)
        })

SpeechToText.stopStreaming()   
```

## Tone Analyzer

The IBM Watson Tone Analyzer service can be used to discover, understand, and revise the language tones in text. The service uses linguistic analysis to detect three types of tones from written text: emotions, social tendencies, and writing style.

Emotions identified include things like anger, fear, joy, sadness, and disgust. Identified social tendencies include things from the Big Five personality traits used by some psychologists. These include openness, conscientiousness, extraversion, agreeableness, and emotional range. Identified writing styles include confident, analytical, and tentative.

```javascript
import {ToneAnalyzer} from 'react-native-bluemix';

ToneAnalyzer.initialize("username", "password")

ToneAnalyzer.getTone( text )
    .then( toneAnalysis => console.log(JSON.stringify(toneAnalysis) )
```

## Natural Language Understanding
Use [Natural Language Understanding](https://console.bluemix.net/docs/services/natural-language-understanding/index.html#about) to analyze various features of text content at scale. Provide text, raw HTML, or a public URL, and IBM Watson Natural Language Understanding will give you results for the features you request. The service cleans HTML content before analysis by default, so the results can ignore most advertisements and other unwanted content.

```javascript
import { NaturalLanguageUnderstanding } from 'react-native-bluemix'

NaturalLanguageUnderstanding.initialize( "username", "password" )

let contentToAnalyze = {
            text: "In 2009, Elliot Turner launched AlchemyAPI to process the written word, with all of its quirks and nuances, and got immediate traction."
}

let features = {
    concepts: {
        limit: 5
    },
    categories: true
}

NaturalLanguageUnderstanding.analyzeContent( contentToAnalyze, features )
    .then( results =>
    {
        console.log( JSON.stringify( results, null, "   " )  )
    } )
    .catch( error => {
        console.log( "Error: " + error.message )
    })
```
