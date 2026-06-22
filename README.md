# DayProof

**Prove your day before it disappears.**

DayProof is a calm Android productivity app for choosing the few tasks that matter in the morning and reviewing them honestly at night. It is local-first, private by default, and built around a simple daily ritual: make a small promise, then close the loop.

## Screenshots

| Today | Plan | Review |
| --- | --- | --- |
| ![Today screen](docs/images/dayproof-today.png) | ![Morning planning screen](docs/images/dayproof-plan.png) | ![Night review screen](docs/images/dayproof-review.png) |

| Stats | Settings |
| --- | --- |
| ![Stats screen](docs/images/dayproof-stats.png) | ![Settings screen](docs/images/dayproof-settings.png) |

## What It Does

- Morning onboarding with reminder time and night review time.
- A focused planning flow with a recommended 3 to 5 task rhythm and a hard 7 task limit.
- Carry-over tasks for work that was marked not done the night before.
- A three-day carry warning that nudges the user to break a recurring task smaller.
- Night review with Done, Not Done, and Remove outcomes.
- Local history, weekly stats, streaks, completion rates, and most-carried task insight.
- Settings for notifications, strong reminder mode, max tasks, JSON export, onboarding reset, and clearing data.
- Hidden developer test mode unlocked by tapping the app version seven times.

## Tech Stack

- Flutter 3.44.2
- Hive and Hive Flutter for local storage
- flutter_local_notifications with timezone scheduling
- permission_handler for Android notification permission
- google_fonts, flutter_animate, and confetti for the polished ritual feel

There is no backend, login, Firebase, cloud sync, ads, or social layer.

## Run Locally

```powershell
flutter pub get
flutter run
```

## Build The APK

```powershell
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

Flutter writes the release APK here:

```text
build/app/outputs/flutter-apk/app-release.apk
```

This repo also keeps a copied release artifact here:

```text
release/dayproof-release.apk
```

## Android Reminder Notes

DayProof uses scheduled local notifications. Android does not allow apps to force-open themselves in the background, so reminders open the right screen when the user taps the notification.

On Android 13 and newer, notification permission is requested. If permission is denied, DayProof still works manually and shows a non-blocking reminder-off message.

Strong reminder mode can request exact alarm permission. The app explains it in plain language:

> DayProof needs reminder permission so it can remind you exactly when you choose. Without it, reminders may arrive a little late depending on your phone settings.

If exact alarm permission is unavailable or declined, the app falls back to normal scheduled reminders instead of crashing.

## Folder Structure

```text
lib/
  app.dart
  main.dart
  core/
    theme/
    utils/
  data/
    models/
    storage/
  services/
  features/
    onboarding/
    today/
    stats/
    history/
    settings/
  shared/
    widgets/
```

## License

Private project unless a license is added later.
