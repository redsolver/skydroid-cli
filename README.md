# SkyDroid CLI

Command-line tool for SkyDroid app distribution.
[SkyDroid](https://skydroid.app) is a decentralized domain-based App Store for Android.

## Install

1. Download the binary for your operating system: https://github.com/redsolver/skydroid-cli/releases/
2. Move it to a folder in your PATH
3. Make it executable with `chmod +x`

## Initialize SkyDroid for your app

1. Make sure your terminal is in the root directory of the app you want to publish
2. Run `skydroid init`
3. Edit all values in `skydroid-app.yaml` to match your app
4. Put your app's domain name in `skydroid-dev.yaml`

## Publish your app

Run `skydroid publish` and follow the instructions.

## Credits

Used some code from https://github.com/angel-dart/angel/tree/master/packages/cli
