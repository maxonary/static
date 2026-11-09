# static — Keep your Mac's microphone input locked 🎙️

**static** is a tiny macOS menu bar app that *pins* your microphone input so macOS can't silently switch it on you. Pick the mic you want once, and static keeps it static — for every app.

## Why?

When you connect Bluetooth headphones (AirPods and friends), macOS often switches the **default audio input** to the headset's built-in microphone. That forces the Bluetooth link into the low-quality hands-free profile (HFP/SCO), so your **output** suddenly sounds muffled and tinny — and battery drains faster because the headset has to broadcast a mic stream back to your Mac.

static keeps your input locked to the device you choose (for example, the built-in microphone), so:

- 🎧 **Output stays high quality** — your headphones stay on the high-fidelity A2DP profile instead of dropping to call-quality audio.
- 🔋 **Better battery life** — the headset doesn't have to stream a microphone signal back.
- 🎚️ **Consistent mic everywhere** — your chosen input stays selected across every app, controlled from the menu bar.

## Features

- **Locked microphone selection.** Choose an input device once; static re-applies it whenever macOS tries to change it.
- **Mute and volume from the menu.** Mute your microphone with one click and set its input level with a slider, right in the menu bar dropdown. The menu bar glyph switches to a slashed mic while you're muted.
- **Locale-independent built-in mic detection.** static detects the built-in microphone using CoreAudio's transport type property (`kAudioDevicePropertyTransportType == kAudioDeviceTransportTypeBuiltIn`) instead of relying on localized device names, so it works in every language.
- **Menu bar control.** A microphone icon lives in your menu bar — click it to see and switch input devices, mute, adjust volume, pause locking, or hide the icon.
- **Tray icon visibility persistence.** static remembers whether its menu bar icon was hidden and restores that state on the next launch. To restore a hidden icon, simply launch the app again.
- **In-app updates.** “Check for updates” downloads, verifies, installs, and relaunches new versions using Sparkle. Checks are manual; archives and the update feed are signed.
- **Open at login.** Optionally launch static automatically when your Mac starts.

**Compatibility: Requires macOS 13.0 (Ventura) or later.**

## Download & Installation

1.  Download the latest compiled application (`Static.app.zip`) from the [releases page](https://github.com/maxonary/Static/releases).
2.  Unzip the downloaded file.
3.  Drag `Static.app` to your Applications folder.

**Note:** If you encounter a "developer cannot be verified" warning when launching the app, this is a standard Gatekeeper security measure. To open it, right-click (or Control-click) the app icon in Finder, then choose "Open." You'll see a dialog with an "Open" button. Clicking this will add an exception, and you won't be prompted again.

## Usage

Once launched, static appears as a microphone icon in your macOS menu bar.

*   **Click the menu bar icon** to see the list of available audio input devices.
*   **Select a device** to lock it as the default audio input. static keeps that device selected even if macOS tries to switch to a Bluetooth headset mic — so your headphones stay on high-quality output.
*   **Mute microphone** toggles the mute state of the locked input. The menu bar icon shows a slashed mic while muted.
*   **Input volume** sets the microphone's input level with the slider.
*   **Pause** temporarily stops static from re-applying your choice.
*   **Open at login** automatically launches static when your Mac starts up.

## Development

After cloning, set up git hooks:

```
git config core.hooksPath .githooks
```

This installs a pre-push hook that verifies version tags (`v*`) match the `CFBundleShortVersionString` in `Info.plist`. To release a new version:

1. Update `CFBundleShortVersionString` and increment `CFBundleVersion` in `Static/Info.plist`
2. Commit and merge the PR into master
3. Tag the merged release commit and push the matching version tag (for example, `git tag v1.11 && git push origin v1.11`).

The CI workflow archives and exports a Developer ID app, runs regression tests, notarizes and staples the app, and publishes `Static.app.zip` plus a signed `appcast.xml` to the GitHub release. Sparkle reads the feed from the latest release. Every future release must include both assets.

The release workflow requires the existing `APPLE_*` secrets and `SPARKLE_PRIVATE_KEY`, exported with Sparkle's `generate_keys`. Only the public key is checked into `Info.plist`; keep the private key in Keychain and GitHub Actions secrets. Sparkle is pinned to 2.10.1 through Swift Package Manager.

Versions up to 1.10 only open the releases website. Install 1.11 manually once to enable in-app updates.

Build and test locally:

```sh
xcodebuild -project Static.xcodeproj -scheme Static -configuration Debug -derivedDataPath build CODE_SIGNING_ALLOWED=NO build
Tests/run.sh
```

The tests exercise concurrent audio callbacks, repeated menu construction, and Sparkle menu wiring without changing microphone settings. To use another Sparkle distribution, set `SPARKLE_FRAMEWORK_DIR` to the directory containing `Sparkle.framework`.

## Support & Contributing

If you encounter any issues or have suggestions for improvements, please open an issue on the [GitHub Issues page](https://github.com/maxonary/Static/issues). Contributions via pull requests are also welcome!

## Credits

static is a rebrand and continuation of the original *AirPods Sound Quality Fixer* by [Milan Toth (milgra)](https://github.com/milgra/airpodssoundqualityfixer), licensed under the terms in [LICENSE](LICENSE).
