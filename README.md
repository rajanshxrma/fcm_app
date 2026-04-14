# fcm app

flutter app that integrates firebase cloud messaging to receive push notifications and update the ui based on message payloads.

## features
- requests notification permissions on launch
- displays the fcm device token (with copy button)
- handles messages in foreground, background, and terminated app states
- ui updates (status text + image) based on payload data
- keeps a log of all received messages

## how it works
when a message comes in through firebase console, the app reads the `asset` key from the payload data and swaps the displayed image. it also updates the status text with the notification title.

## handlers used
- `onMessage` — app is open and active
- `onMessageOpenedApp` — user tapped notification while app was backgrounded
- `getInitialMessage()` — app was terminated, launched from notification tap
- `firebaseMessagingBackgroundHandler` — processes messages while app is in background

## how to run
1. clone the repo
2. run `flutter pub get`
3. make sure firebase project has cloud messaging enabled
4. run `flutterfire configure` to update `firebase_options.dart` for your setup
5. run `flutter run` on a physical device or emulator with google play services

## testing
- get the token from the app
- go to firebase console → messaging → send test message
- paste your token and add custom data: `asset = promo`, `action = show_animation`
- test in all three app states (foreground, background, terminated)
