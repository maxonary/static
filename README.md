# AirPods Sound Quality Fixer And Battery Life Enhancer For MacOS

Fixes sound quality drops when using AirPods with Macs. 
It forces the default audio input to be the built-in microphone instead of AirPods' microphone so MacOS doesn't have to mix down the output. 
It also increases battery life because AirPods doesn't have to broadcast sound back.
If you have more input devices you can select which device you want to force over the AirPods microphone.

The app runs in the menu bar.

**Compatibility: Requires macOS 13.0 (Ventura) or later.**

## Download & Installation

1.  Download the latest compiled application (`AirPods Sound Quality Fixer.app.zip`) from the [releases page](https://github.com/maxonary/MacOS-audio-selector/releases/tag/1.1).
2.  Unzip the downloaded file.
3.  Drag the `AirPods Sound Quality Fixer.app` to your Applications folder.

**Note:** If you encounter a "developer cannot be verified" warning when launching the app, this is a standard Gatekeeper security measure. To open it, right-click (or Control-click) the app icon in Finder, then choose "Open." You'll see a dialog with an "Open" button. Clicking this will add an exception, and you won't be prompted again.

## Usage

Once launched, the app will appear as an icon in your macOS menu bar.

*   **Click the menu bar icon** to see a list of available audio input devices.
*   **Select a device** from the list to force it as the default audio input. This will ensure your AirPods are used for output only, improving sound quality and battery life.
*   The "Open at login" option (if selected) will automatically launch the app when your Mac starts up.

## Development

After cloning, set up git hooks:

```
git config core.hooksPath .githooks
```

This installs a pre-push hook that verifies version tags (`v*`) match the `CFBundleShortVersionString` in `Info.plist`. To release a new version:

1. Update `CFBundleShortVersionString` in `AirPods Sound Quality Fixer/Info.plist`
2. Commit and push to main
3. Tag and push: `git tag v1.2.0 && git push origin v1.2.0`

The CI workflow will build, sign, notarize, and publish a GitHub release automatically.

## Support & Contributing

If you encounter any issues or have suggestions for improvements, please open an issue on the [GitHub Issues page](https://github.com/milgra/airpodssoundqualityfixer/issues). Contributions via pull requests are also welcome!
