# Ember Fall

iPhone wallpaper app. An AI photo of a burning asteroid over Earth, split into two depth layers, tilts up to 10 degrees by drag or by moving the phone. Runs offline in a SwiftUI WKWebView.

## One time setup for TestFlight
1. In App Store Connect create a new iOS app with a bundle ID you own.
2. In App Store Connect create an API key under Users and Access, Integrations, with App Manager access. Download the .p8 file once.
3. In this repo on GitHub add Settings, Secrets and variables, Actions
   Variables BUNDLE_ID (your bundle ID) and TEAM_ID (your 10 character Apple team ID)
   Secrets ASC_KEY_ID, ASC_ISSUER_ID, ASC_KEY_P8 (the full contents of the .p8 file)
4. Push to main or run the TestFlight workflow by hand. The build lands in TestFlight in a few minutes.
5. In TestFlight add yourself as an internal tester.

## Local build on a Mac
brew install xcodegen, then BUNDLE_ID=com.you.emberfall TEAM_ID=XXXXXXXXXX xcodegen generate, then open EmberFall.xcodeproj.
