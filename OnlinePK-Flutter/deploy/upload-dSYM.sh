#!/bin/bash

ios/Pods/FirebaseCrashlytics/upload-symbols \
    -gsp ios/GoogleService-Info.plist \
    -p ios \
    build/ios/Release-iphoneos/Runner.app.dSYM \
    build/ios/Release-iphoneos/MeetingBroadcaster.appex.dSYM