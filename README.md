# react-native-bluemix
[![npm version](https://badge.fury.io/js/react-native-bluemix.svg)](https://badge.fury.io/js/react-native-bluemix)

## Overview
React Native module for using select Bluemix services.  Access to Watson services is provided by wrapping the [Watson Developer Cloud](https://github.com/watson-developer-cloud/swift-sdk)

There is example code for all services in the [rn-bluemix-boilerplace](https://github.com/pwcremin/rn-bluemix-boilerplate) repo.  This is also a great repo to get you up and running quickly with a new React Native project that uses the most popular modules.

### Services

* [Text to Speech](#text-to-speech)
* [Speech to Text](#speech-to-text)

## Install

```shell
npm install --save react-native-bluemix
```
### Android

```react-native link react-native-bluemix```

Add repository to your project Gradle file

```
allprojects {
    repositories {
        maven { url "https://oss.sonatype.org/content/repositories/snapshots" }
    }
}
```

### iOS

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

Finally, drag-and-drop the built frameworks into your Xcode project.

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
