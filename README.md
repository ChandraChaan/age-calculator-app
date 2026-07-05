# Agely

Agely is a lightweight Flutter app focused on one job: calculating age clearly and accurately.

## Product direction

- Material 3
- Minimal Google-utility style UI
- Light theme first
- No backend, auth, ads, or notifications
- Small, maintainable codebase

## Planned v1 features

- Date picker for date of birth
- Age summary in years, months, and days
- Total days, weeks, and months
- Next birthday
- Days until next birthday

## Project structure

```text
lib/
  core/
    constants/
    theme/
    utils/
  features/
    age_calculator/
      presentation/
        widgets/
      services/
  main.dart
```

## State management

`provider` is used for simple app state.

## Packages

- `provider`
- `intl`

## Getting started

1. Install the latest stable Flutter SDK.
2. Run `flutter pub get`.
3. Run `flutter analyze`.
4. Run `flutter run`.
