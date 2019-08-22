# react-native-watson

This is a fork from [react-native-watson](https://github.com/pwcremin/react-native-watson)


## Overview
React Native module (ios and ~~android~~) for using select Watson ~~services~~ Speech-To-Text.  Access to Watson services is provided by wrapping the [Watson Developer Cloud](https://github.com/watson-developer-cloud/swift-sdk)

### Services

* [Speech to Text](#speech-to-text)

If you would like to see more services implemented please create an issue for it.

## Install

```shell
npm install --save RollioForce/react-native-watson

```
## iOS

### Manually link

Copy RNWatson.m and RNWatson.swift from node_modules/react-native-watson/ios into your project.  You will be prompted to create a bridging header.  Accept and place the below into the header:

```obj-c
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
```

#### Dependency Management

You can install Cocoapods with [RubyGems](https://rubygems.org/):

```bash
$ sudo gem install cocoapods
```

If your project does not yet have a Podfile, use the `pod init` command in the root directory of your project. To install the Swift SDK using Cocoapods, add the services you will be using to your Podfile as demonstrated below (substituting `MyApp` with the name of your app). The example below shows all of the currently available services; your Podfile should only include the services that your app will use.

```ruby
use_frameworks!

target 'MyApp' do
    pod 'IBMWatsonSpeechToTextV1', '~> 2.2.0'
end
```

Run the `pod install` command, and open the generated `.xcworkspace` file. To update to newer releases, use `pod update`.

## Service Instances

Services are instantiated using the [IBM Cloud](https://www.ibm.com/cloud/).

Follow these steps to create a service instance and obtain its credentials:

1. Log in to IBM Cloud at [https://www.ibm.com/cloud/](https://www.ibm.com/cloud/).
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

Note that service credentials are different from your IBM Cloud username and password.

See [Getting Started](https://www.ibm.com/watson/developercloud/doc/common/index.html) for more information on getting started with the Watson Developer Cloud and IBM Cloud.

## Speech to Text

The IBM Watson Speech to Text service enables you to add speech transcription capabilities to your application. It uses machine intelligence to combine information about grammar and language structure to generate an accurate transcription. 

```javascript
import {SpeechToText} from 'react-native-watson';

SpeechToText.initialize("API_KEY")

// will transcribe microphone audio
SpeechToText.startStreaming((error, text) =>
        {
            console.log(text)
        })

SpeechToText.stopStreaming()   
```
