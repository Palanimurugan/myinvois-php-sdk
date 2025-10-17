# Star Shooter Flutter Demo

This is a lightweight Flutter prototype that satisfies the requested mechanics:

* Stars spawn on the playfield at a configurable interval that begins at 10 seconds.
* Each level shortens the spawn interval by 20% down to a minimum of two seconds and requires more hits.
* New colors are introduced every level (up to six distinct colors) to increase challenge.
* Players select a color from the palette and tap stars of the matching color to "shoot" them.
* Between levels, a placeholder interstitial ad dialog appears to indicate where ad revenue-sharing logic can be implemented.

## Getting started

1. Ensure the Flutter SDK is installed locally.
2. From this folder, run `flutter pub get` to install dependencies.
3. Launch the game with `flutter run`.

The interstitial ad is represented by a modal dialog so the game can be demonstrated without bundling a specific ad network SDK. Replace `_showInterstitialAd` in `lib/main.dart` with your ad provider implementation when ready to integrate a production ad flow.
