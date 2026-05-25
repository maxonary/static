# Static — Keep your Mac's microphone input locked 🎙️

**Static** is a tiny macOS menu bar app that *pins* your microphone input so macOS can't silently switch it on you. Pick the mic you want once, and Static keeps it static — for every app.

## Why?

When you connect Bluetooth headphones (AirPods and friends), macOS often switches the **default audio input** to the headset's built-in microphone. That forces the Bluetooth link into the low-quality hands-free profile (HFP/SCO), so your **output** suddenly sounds muffled and tinny — and battery drains faster because the headset has to broadcast a mic stream back to your Mac.

Static keeps your input locked to the device you choose (for example, the built-in microphone), so:

- 🎧 **Output stays high quality** — your headphones stay on the high-fidelity A2DP profile instead of dropping to call-quality audio.
- 🔋 **Better battery life** — the headset doesn't have to stream a microphone signal back.
- 🎚️ **Consistent mic everywhere** — your chosen input stays selected across every app, controlled from the menu bar.

## Features

- **Locked microphone selection.** Choose an input device once; Static re-applies it whenever macOS tries to change it.
- **Locale-independent built-in mic detection.** Static detects the built-in microphone using CoreAudio's transport type property (`kAudioDevicePropertyTransportType == kAudioDeviceTransportTypeBuiltIn`) instead of relying on localized device names, so it works in every language.
- **Menu bar control.** A microphone icon (`mic.fill`) lives in your menu bar — click it to see and switch input devices, pause locking, or hide the icon.
- **Tray icon visibility persistence.** Static remembers whether its menu bar icon was hidden and restores that state on the next launch. To restore a hidden icon, simply launch the app again.
- **Open at login.** Optionally launch Static automatically when your Mac starts.

**Compatibility: Requires macOS 13.0 (Ventura) or later.**

## Download & Installation

1.  Download the latest compiled application (`Static.app.zip`) from the [releases page](https://github.com/maxonary/Static/releases).
2.  Unzip the downloaded file.
3.  Drag `Static.app` to your Applications folder.

**Note:** If you encounter a "developer cannot be verified" warning when launching the app, this is a standard Gatekeeper security measure. To open it, right-click (or Control-click) the app icon in Finder, then choose "Open." You'll see a dialog with an "Open" button. Clicking this will add an exception, and you won't be prompted again.

## Usage

Once launched, Static appears as a microphone icon in your macOS menu bar.

*   **Click the menu bar icon** to see the list of available audio input devices.
*   **Select a device** to lock it as the default audio input. Static keeps that device selected even if macOS tries to switch to a Bluetooth headset mic — so your headphones stay on high-quality output.
*   **Pause** temporarily stops Static from re-applying your choice.
*   **Open at login** automatically launches Static when your Mac starts up.

## Development

After cloning, set up git hooks:

```
git config core.hooksPath .githooks
```

This installs a pre-push hook that verifies version tags (`v*`) match the `CFBundleShortVersionString` in `Info.plist`. To release a new version:

1. Update `CFBundleShortVersionString` in `Static/Info.plist`
2. Commit and push to main
3. Tag and push: `git tag v1.6.0 && git push origin v1.6.0`

The CI workflow will build, sign, notarize, and publish a GitHub release automatically.

## Support & Contributing

If you encounter any issues or have suggestions for improvements, please open an issue on the [GitHub Issues page](https://github.com/maxonary/Static/issues). Contributions via pull requests are also welcome!

## Credits

Static is a rebrand and continuation of the original *AirPods Sound Quality Fixer* by [Milan Toth (milgra)](https://github.com/milgra/airpodssoundqualityfixer), licensed under the terms in [LICENSE](LICENSE).
