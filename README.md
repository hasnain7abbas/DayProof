# DayProof

**Prove your day before it disappears.**

[![CI](https://github.com/hasnain7abbas/DayProof/actions/workflows/ci.yml/badge.svg)](https://github.com/hasnain7abbas/DayProof/actions/workflows/ci.yml)
[![Latest release](https://img.shields.io/github/v/release/hasnain7abbas/DayProof?label=release)](https://github.com/hasnain7abbas/DayProof/releases/latest)
[![Android](https://img.shields.io/badge/platform-Android-34D399)](https://github.com/hasnain7abbas/DayProof/releases/latest)

DayProof is a small Android app for two honest moments: deciding what matters in the morning, then returning at night to record what actually happened. It is intentionally narrower than a normal task manager. The list stays short, unfinished work stays visible, and every day leaves a local record.

**[Download the latest Android APK](https://github.com/hasnain7abbas/DayProof/releases/latest)**

Choose the `android-arm64` APK for nearly every current Android phone. The `android-armv7` build is there for older 32-bit devices. Published APKs are release-signed, versioned, and accompanied by SHA-256 checksums.

## The App

<p align="center">
  <img src="docs/images/dayproof-today.png" width="31%" alt="DayProof today screen" />
  <img src="docs/images/dayproof-plan.png" width="31%" alt="DayProof morning planning screen" />
  <img src="docs/images/dayproof-review.png" width="31%" alt="DayProof night review screen" />
</p>

<p align="center">
  <img src="docs/images/dayproof-stats.png" width="31%" alt="DayProof stats screen" />
  <img src="docs/images/dayproof-settings.png" width="31%" alt="DayProof settings screen" />
</p>

Morning planning asks for only the tasks that would make the day count. Once the plan is locked, DayProof keeps it stable while still allowing clearly marked late additions.

At night, each task is recorded as Done, Not Done, or Removed. Not Done work can be carried into a fresh task on the next day without rewriting the previous day's history. If the same item survives for three days, the app asks whether it should be made smaller or dropped.

## What It Keeps

- A short daily plan with a configurable limit of 3 to 7 tasks
- Morning and night reminders, including an optional exact-alarm mode
- Carry-over history that preserves the original day and each retry
- Daily review records and completion stats
- A seven-day rhythm, current review streak, and carry signals
- JSON export for the data stored on the device

There is no account, backend, cloud sync, advertising, or analytics. Tasks, settings, and history are stored locally with Hive. The Plus Jakarta Sans font is bundled in the APK, so the interface does not need a runtime font download.

## Build It

DayProof currently targets Flutter `3.44.2` and Java `17`.

```powershell
flutter pub get
flutter analyze
flutter test
flutter run
```

A debug APK can be built without signing configuration:

```powershell
flutter build apk --debug --target-platform android-arm64
```

Release builds require a private keystore. Copy `android/key.properties.example` to `android/key.properties`, replace the example values, then run:

```powershell
flutter build apk --release --split-per-abi
```

`android/key.properties`, keystores, and generated APK folders are ignored by Git. The tag workflow in [release.yml](.github/workflows/release.yml) reads the signing material from GitHub Actions secrets and publishes the arm64 and armv7 APKs to GitHub Releases.

## Checks And Screenshots

Every push and pull request runs analysis, tests, and an Android arm64 packaging check through [ci.yml](.github/workflows/ci.yml).

The README images are rendered from the real Flutter widgets rather than maintained as mockups. Regenerate them after a UI change with:

```powershell
flutter test tool/readme_screenshots_test.dart --update-goldens
```

## Project Layout

```text
lib/
  core/       theme and date helpers
  data/       local models and Hive storage
  features/   onboarding, today, history, stats, settings
  services/   notifications, permissions, scheduling
  shared/     reusable controls and cards
```

## License

Copyright (c) 2026 Hasnain Abbas. All rights reserved.
