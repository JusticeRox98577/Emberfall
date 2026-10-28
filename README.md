# Ember Fall

iPhone wallpaper app. An AI photo of a burning asteroid over Earth, split into two depth layers, tilts up to 10 degrees by drag or by moving the phone. Runs offline in a SwiftUI WKWebView.

## One time setup for TestFlight
1. In App Store Connect create a new iOS app named Ember Fall with a bundle ID you own.
2. In App Store Connect create an API key under Users and Access, Integrations, with App Manager access. Download the .p8 file once.
3. In this repo on GitHub add three Actions secrets under Settings, Secrets and variables, Actions
   ASC_KEY_ID, ASC_ISSUER_ID, ASC_KEY_P8 (the full contents of the .p8 file)
4. Run the TestFlight workflow once, or push to main. It finds the app and team from the key, builds, and uploads to TestFlight.
5. In TestFlight add yourself as an internal tester.

BUNDLE_ID and TEAM_ID can optionally be set as Actions variables to override what the workflow finds.

## Local build on a Mac
brew install xcodegen, then BUNDLE_ID=com.you.emberfall TEAM_ID=XXXXXXXXXX xcodegen generate, then open EmberFall.xcodeproj.
