---
slug: push-notifications-with-swift-server-side
title: Sending push notifications using server side Swift in 2023
description: Learn how to send push notifications with Swift on the server side using the Google FCM API and the APN Swift library.
coverImage: ./push-notifications-with-swift-server-side/cover.jpg
publication: 2023-05-18 17:36:12
tags:
  - swift
  - push-notification
authors:
  - gabor-lengyel
---

## Prerequisites

There are prerequisites due to the nature of push notification functionality being behind Apple's and Firebase’s paid tiers.

- Apple developer license (paid)
- a Firebase account with a project set up using Blaze Plan. For testing, you are good with a Spark Plan too.
- Amazon AWS account
- Xcode

## Firebase

Firebase Cloud Messaging (FCM) is a cross-platform messaging solution provided by Google to send push notifications to mobile devices and web applications. It enables developers to send notifications containing text, images, and links directly to user devices using a console to manage notifications and target specific users.

### Step 1, Firebase project

The very first step is to setup a Firebase project and download the service account JSON file for authorization. This JSON file is used on the server side.

### Step 2, Firebase add Android application

For Android applications, you need to add a new [app](https://firebase.google.com/docs/android/setup) to the firebase project, download Google-Services.json, and add this JSON to your Android project. Set up your project so you can receive push notifications.

### Step 3, Firebase add iOS application

For iOS applications, you need to add a new [app](https://firebase.google.com/docs/ios/setup) to the firebase project, download GoogleService-Info.plist, and add this file to your Xcode project. Set up your project so you can receive push notifications.

### Step 4, Firebase extra setup for iOS application

For iOS applications, you have two options to setup your application with [APNS](https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/sending_notification_requests_to_apns):

- [Token-based connection](https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/establishing_a_token-based_connection_to_apns), after successful setup, you need to add these to the Firebase project in **Project Settings / Cloud Messaging**:
- APNs Auth Key (p8 file)
- Key ID
- Team ID

- [Certificate-based connection](https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/establishing_a_certificate-based_connection_to_apns), after successful setup, you need to add the certificate to the Firebase project **Project Settings / Cloud Messaging**:
- APNs Auth Key (p12 file)

### Step 5, Server side

Google has server environments called [Firebase Admin SDK](https://firebase.google.com/docs/cloud-messaging/server), but sadly not for Swift. There are several [protocols](https://firebase.google.com/docs/cloud-messaging/server#choose) we can use; we cover briefly the [FCM HTTP v1 API](https://firebase.google.com/docs/reference/fcm/rest/v1/projects.messages) protocol, where we send JSON messages as HTTP POST.
A good starting point is the [Google library](https://github.com/googleapis/google-auth-library-swift), which we can use, but you can implement your own solution too, depending on what you prefer.

```swift
import Foundation
import Dispatch
import OAuth2

let scopes = ["https://www.googleapis.com/auth/cloud-platform"]

if let provider = DefaultTokenProvider(scopes: scopes) {
  let sem = DispatchSemaphore(value: 0)
  try provider.withToken() {(token, error) -> Void in
    if let token = token {
      let encoder = JSONEncoder()
      if let token = try? encoder.encode(token) {
        print("\(String(data:token, encoding:.utf8)!)")
        // send message(s) with auth token
      }
    }
    if let error = error {
      print("ERROR \(error)")
    }
    sem.signal()
  }
  _ = sem.wait(timeout: DispatchTime.distantFuture)
} else {
  print("Unable to obtain an auth token.\nTry pointing GOOGLE_APPLICATION_CREDENTIALS to your service account credentials.")
}
```

### Step 6, Send messages

There are options for how you want to [send messages](https://firebase.google.com/docs/cloud-messaging/send-message) with Firebase.

#### Send messages to specific devices:

A good practice is to save device tokens into a database on the server side so they are easily accessible. Register/unregister logic needs to be implemented for both client app instances.

```http
POST https://fcm.googleapis.com/v1/projects/myproject-b5ae1/messages:send HTTP/1.1

Content-Type: application/json
Authorization: Bearer ya29.ElqKBGN2Ri_Uz...HnS_uNreA

{
   "message":{
      "token":"bk3RNwTe...",
      "notification":{
        "body":"This is an FCM notification message!",
        "title":"FCM Message"
      }
   }
}
```

#### Send messages to multiple devices

We have a send limit here; you can specify up to 500 device registration tokens per invocation. You will need to add extra logic to your server-side logic here to handle the 500 limit. Construct an HTTP batch request and send it:

```http
--subrequest_boundary
Content-Type: application/http
Content-Transfer-Encoding: binary

POST /v1/projects/myproject-b5ae1/messages:send
Content-Type: application/json
accept: application/json

{
  "message":{
     "token":"bk3RNwTe3H0:CI2k_HHwgIpoDKCIZvvDMExUdFQ3P1...",
     "notification":{
       "title":"FCM Message",
       "body":"This is an FCM notification message!"
     }
  }
}

...

--subrequest_boundary
Content-Type: application/http
Content-Transfer-Encoding: binary

POST /v1/projects/myproject-b5ae1/messages:send
Content-Type: application/json
accept: application/json

{
  "message":{
     "token":"cR1rjyj4_Kc:APA91bGusqbypSuMdsh7jSNrW4nzsM...",
     "notification":{
       "title":"FCM Message",
       "body":"This is an FCM notification message!"
     }
  }
}
--subrequest_boundary--

send byte data to https://fcm.googleapis.com/batch
```

#### Send messages to topics

After you have created a topic by subscribing client app instances to the topic on the client side (you need to implement this register/unregister logic into your mobile applications), you can send messages to the topic. In this case, no device tokens are needed to send out push messages, so you don't need to store device tokens on the server side.

```http
POST https://fcm.googleapis.com/v1/projects/myproject-b5ae1/messages:send HTTP/1.1

Content-Type: application/json
Authorization: Bearer ya29.ElqKBGN2Ri_Uz...HnS_uNreA
{
  "message":{
    "topic" : "foo-bar",
    "notification" : {
      "body" : "This is a Firebase Cloud Messaging Topic Message!",
      "title" : "FCM Message"
      }
   }
}
```

### Step 7, Choose message type

Firebase Cloud Messaging (FCM) offers two main [messaging options](https://firebase.google.com/docs/cloud-messaging/concept-options) and capabilities.

#### Notification messages

Notification messages, sometimes thought of as "display messages." These are handled by the FCM SDK automatically.

```http
{
  "message":{
    "token":"bk3RNwTe3H0:CI2k_HHwgIpoDKCIZvvDMExUdFQ3P1...",
    "notification":{
      "title" : "Notification title",
      "body" : "Notification body"
    }
  }
}
```

#### Data messages

Set the appropriate key with your custom key-value pairs to send a data payload to the client app. Data messages need to be handled by the client app.

```http
{
  "message":{
    "token":"bk3RNwTe3H0:CI2k_HHwgIpoDKCIZvvDMExUdFQ3P1...",
    "data":{
      "title" : "Notification title",
      "body" : "Notification body",
      "otherParam" : "Other dara"
    }
  }
}
```

## Apple APNs

Apple Push Notification Service (APNS) is a messaging service provided by Apple that enables remote notifications for iOS, macOS, and watchOS devices. It allows developers to send push notifications directly to users, even when the device is not running the app. You can even send push notifications to iPhone emulators.

### Step 1, Setup p8 or p12 file

For iOS applications you have two options to setup your application with [APNS](https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/sending_notification_requests_to_apns):

- [Token-based connection](https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/establishing_a_token-based_connection_to_apns), after successful setup, you will have these to use:
- APNs Auth Key (p8 file)
- Key ID
- Team ID

- [Certificate-based connection](https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/establishing_a_certificate-based_connection_to_apns), after successful setup, you will have an APNs Auth Key (p12 file), which you can use.

### Step 2, Server side

There is an official, detailed [article](https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server) to gather information, and there is also an [APNS library](https://github.com/swift-server-community/APNSwift) to start implementing server-side.

```swift
import Foundation
import APNSCore
import APNS
import Foundation
import Logging

let deviceToken = "A_DEVICE_TOKEN"
let appBundleID = "your.bundle.id"
let privateP8Key = """
-----BEGIN PRIVATE KEY-----
YOUR_PRIVATE_KEY
-----END PRIVATE KEY-----
"""
let keyIdentifier = "KEY_IDENTIFIER"
let teamIdentifier = "TEAM_IDENTIFIER"

var logger = Logger(label: "apns-logger")

let client = APNSClient(
    configuration: .init(
        authenticationMethod: .jwt(
            privateKey: try .init(pemRepresentation: privateP8Key),
            keyIdentifier: keyIdentifier,
            teamIdentifier: teamIdentifier
        ),
        environment: .sandbox
    ),
    eventLoopGroupProvider: .createNew,
    responseDecoder: JSONDecoder(),
    requestEncoder: JSONEncoder(),
    byteBufferAllocator: .init()
)
defer {
    client.shutdown { _ in
        logger.error("Failed to shutdown APNSClient")
    }
}

struct Payload: Codable {}

try await client.sendAlertNotification(
    .init(
        alert: .init(
            title: .raw("Title from APNS"),
            subtitle: .raw("SubTitle from APNS"),
            body: .raw("Body from APNS"),
            launchImage: nil
        ),
        expiration: .immediately,
        priority: .immediately,
        topic: appBundleID,
        payload: EmptyPayload()
    ),
    deviceToken: deviceToken
)
```

You can send notifications to the user’s device with [JSON payloads](https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/generating_a_remote_notification). There are multiple types and options; we mostly used alert.

## Amazon SNS

[Amazon SNS](https://aws.amazon.com/sns/) Simple Notification Service (SNS) is a fully managed messaging service provided by Amazon Web Services (AWS) for the delivery of messages to mobile devices, email addresses, and other distributed services. It supports multiple messaging protocols, such as HTTP, HTTPS, email, SMS, and Amazon SQS. Amazon SNS is highly scalable, reliable, and cost-effective, making it ideal for use cases such as mobile application push notifications, distributed system notifications, and workflow orchestration. In our case, we are just **briefly focusing** on mobile application push notifications.

### Step 1, Setup a Topics

Amazon SNS topic is a [channel](https://docs.aws.amazon.com/sns/latest/dg/sns-create-topic.html) for sending messages to multiple recipients or endpoints subscribed to the topic. It allows publishers to send a single message to multiple subscribers, eliminating the need for publishers to manage multiple endpoint registers. Subscribers can be added or removed dynamically, making it flexible and scalable.

### Step 2, Setup Platform applications

Amazon SNS [Platform application](https://docs.aws.amazon.com/sns/latest/dg/mobile-push-send-register.html) is a messaging service to send push notifications to mobile devices using Amazon SNS. It allows publishers to send notifications directly to mobile devices for multiple platforms such as iOS, Android, Windows, and Fire OS.

#### Setup Platform Application for iOS

1. Create an Apple Push Notification service (APNs) certificate or token credentials using Apple Developer Account.
2. Create an Amazon SNS Platform Application in the AWS Management Console and configure it with the APNs certificate or token credentials.
3. Create an Amazon SNS Platform Endpoint for each unique device token or registration ID.
4. Send a push notification message using Amazon SNS to the Platform endpoint ARN.

#### Setup Platform Application for Android

1. Create an API Key and a Project ID in your Firebase project and enable Firebase Cloud Messaging (FCM) service.
2. Create an Amazon SNS Platform Application in the AWS Management Console and configure it with Cloud Messaging API (Legacy) server key.
3. Create an Amazon SNS Platform Endpoint for each unique FCM registration token.
4. Send a push notification message using Amazon SNS to the Platform endpoint ARN.

At this point, if you add a valid **Endpoint** to both **Platform applications**,  you are able to send out test push notifications.

You can use the [AWS Mobile SDK](https://docs.aws.amazon.com/AmazonS3/latest/userguide/using-mobile-sdks.html)s for [Android](https://docs.amplify.aws/lib/push-notifications/getting-started/q/platform/android/) and [iOS](https://docs.amplify.aws/lib/push-notifications/getting-started/q/platform/ios/) to configure and use features like push notifications in mobile platforms, but you also implements your own business logic.

### Step 3, Server side

There is an official, detailed [API reference](https://docs.aws.amazon.com/sns/latest/api/actions-list.html) to start implementing server-side.
Sample Publish Request

```https
https://sns.us-west-2.amazonaws.com/?Action=Publish
&TargetArn=arn%3Aaws%3Asns%3Aus-west-2%3A803981987763%3Aendpoint%2FAPNS_SANDBOX%2Fpushapp%2F98e9ced9-f136-3893-9d60-776547eafebb
&Message=%7B%22default%22%3A%22This+is+the+default+Message%22%2C%22APNS_SANDBOX%22%3A%22%7B+%5C%22aps%5C%22+%3A+%7B+%5C%22alert%5C%22+%3A+%5C%22You+have+got+email.%5C%22%2C+%5C%22badge%5C%22+%3A+9%2C%5C%22sound%5C%22+%3A%5C%22default%5C%22%7D%7D%22%7D
&Version=2010-03-31
&AUTHPARAMS
```

## Summary

We have a couple options when we want to implement push notifications into server-side Swift. Which one should we choose? In most cases, it's your own preference, but let us help you choose with a couple simple questions:

- You need push notifications for only Apple devices?

**Use only APNS.**

- You need push notifications for Android and Apple devices too? Firebase Cloud Messaging (FCM) is mandatory for Android, FCM handles APNS too.

**Use FCM.**

- You need push notifications for Android and Apple devices, and you need other services like SMS messages too?

**Use Amazon SNS.**

We hope you find this article helpful. Happy coding!
