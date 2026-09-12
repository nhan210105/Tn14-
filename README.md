# TnCheats — Crash-Fixed iOS Source / Unsigned Codemagic Build

This project is a reconstructed SwiftUI source based on the supplied `Reg Mod Cache 2.0.3` IPA.

## Current branding/build identity

- App name: **TnCheats**
- Bundle identifier: **com.tncheats.app**
- Version: **2.0.3 (3)**
- Minimum iOS: **15.0**
- Xcode project: `RegMod.xcodeproj`
- Shared scheme: `RegMod`
- Product: `TnCheats.app`

## Crash-focused changes

- Tolerant API JSON decoding for missing/wrong field types.
- HTTP and malformed/non-JSON responses are handled as errors instead of unsafe casts.
- File importer callbacks use explicit `Result` handling.
- Saved session decoding is optional; corrupt saved data does not terminate startup.
- UI state mutations from API callbacks are returned to the main actor/thread.
- Compatibility classes are safe stubs.

## Codemagic / ESign workflow

This repository intentionally **does not use Codemagic iOS signing**.

`codemagic.yaml`:

1. Builds a Release iOS app with code signing disabled:
   - `CODE_SIGNING_ALLOWED=NO`
   - `CODE_SIGNING_REQUIRED=NO`
   - `CODE_SIGN_IDENTITY=""`
2. Does not request an Apple provisioning profile.
3. Packages the generated `.app` into:
   `build/ESign/TnCheats-unsigned.ipa`
4. The resulting IPA can then be downloaded and signed/installed separately with ESign.

There is intentionally no `ios_signing` / `distribution_type: app_store` block and no `xcodebuild -exportArchive` step.

## Important

The reconstructed source is not byte-for-byte equivalent to the original Swift source. The compatibility layer contains safe placeholders where the original binary's behavior could not be recovered reliably.
