# LocalPins

LocalPins is a fully local iPhone photo board app built with SwiftUI, SwiftData, FileManager, and PhotosUI.

## What is included

- Pinterest-style masonry grid for saved photos
- Multi-photo import from the iPhone photo library
- Optional camera capture with local storage
- Full-screen swipeable photo viewer
- Board and collection management
- Offline-only persistence with no server or cloud
- iOS 17+ target

## Project path

- Xcode project: `C:\PAPKA\LocalPins\LocalPins.xcodeproj`

## Important note about IPA

This workspace was created on Windows, so the project files are ready, but the final signed `.ipa` still needs:

- macOS
- Xcode
- an Apple signing identity

## GitHub Actions build

The repo now includes a remote macOS build workflow:

- Workflow file: `.github/workflows/ios-build.yml`
- Export options template: `.github/exportOptions/ExportOptions.template.plist`

This workflow can:

- build an `.xcarchive` on `macos-latest`
- export an `.ipa` if signing secrets are configured

### Important limitation

For automated `.ipa` export in GitHub Actions, you normally need an Apple Developer certificate and provisioning profile that can be imported into CI.

In practice that means:

- best path: paid Apple Developer account
- weak path: free Apple ID may work locally in Xcode, but is usually not suitable for GitHub Actions signing automation

### Required GitHub Secrets

Add these secrets in your GitHub repository settings:

- `APPLE_CERTIFICATE_P12_BASE64`
- `APPLE_CERTIFICATE_PASSWORD`
- `APPLE_PROVISION_PROFILE_BASE64`
- `PROVISIONING_PROFILE_NAME`
- `KEYCHAIN_PASSWORD`

### What each secret is

- `APPLE_CERTIFICATE_P12_BASE64`: your signing certificate exported as `.p12`, then converted to base64
- `APPLE_CERTIFICATE_PASSWORD`: password you set when exporting the `.p12`
- `APPLE_PROVISION_PROFILE_BASE64`: your provisioning profile file converted to base64
- `PROVISIONING_PROFILE_NAME`: the exact profile name shown in Apple Developer portal / Xcode
- `KEYCHAIN_PASSWORD`: any temporary password for the CI keychain

### How to generate base64 values on Windows

For a `.p12` file:

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("C:\path\to\certificate.p12")) | Set-Clipboard
```

For a `.mobileprovision` file:

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("C:\path\to\profile.mobileprovision")) | Set-Clipboard
```

### How to run the workflow

1. Push `LocalPins` to a GitHub repository.
2. Open the `Actions` tab.
3. Run `Build LocalPins IPA`.
4. Fill:
   - `bundle_id`: your real bundle id
   - `team_id`: your Apple Team ID
   - `export_method`: usually `development` or `ad-hoc`
5. Wait for the macOS runner to finish.
6. Download:
   - `LocalPins-xcarchive`
   - `LocalPins-ipa` if signing was configured correctly

## Build on Mac

1. Copy the `LocalPins` folder to a Mac with Xcode 16+.
2. Open `LocalPins.xcodeproj`.
3. In the Signing & Capabilities tab, set your own team.
4. If `com.localpins.app` conflicts, change the bundle identifier to your unique value.
5. Build and run on a real iPhone.
6. Archive the app and export an `.ipa`.

## Install with Sideloadly

1. Get the `.ipa` from Xcode or from the GitHub Actions artifact.
2. Open Sideloadly on Windows.
3. Connect the iPhone by cable.
4. Select the `.ipa`.
5. Sign in with your Apple ID inside Sideloadly if needed.
6. Start sideloading.
