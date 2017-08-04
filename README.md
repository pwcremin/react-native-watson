# react-native-bluemix
[![npm version](https://badge.fury.io/js/react-native-bluemix.svg)](https://badge.fury.io/js/react-native-bluemix)

## Overview
React Native module for using select Bluemix services.  Access to Watson services is provided by wrapping the [Watson Developer Cloud](https://github.com/watson-developer-cloud/swift-sdk)

### Services

* [Text to Speech](#text-to-speech)

## Install

```shell
npm install --save react-native-bluemix
```

## Manually link

### iOS

Open XCode, click on your project, and great a new group called RNBluemix. Copy all files from node_modules/react-native-bluemix/ios into this new group.

![Alt text](https://cdn.rawgit.com/pwcremin/assets/776546d8/Screen%20Shot%202017-08-04%20at%2010.25.08%20AM.png)


## Text To Speech

```javascript
let RNTextToSpeech = require('react-native-bluemix');
RNTextToSpeech.initialize("username", "password")
```

