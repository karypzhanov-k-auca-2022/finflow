# Development commands

Flutter 3.41.2 is pinned by .fvmrc. Use FVM for deterministic repository verification:

    fvm flutter pub get
    fvm flutter devices
    fvm flutter run
    fvm flutter run -d <device-id>
    fvm flutter run --dart-define=API_BASE_URL=https://api.example.com

The README documents equivalent raw dart/flutter quality commands. Prefer these FVM-prefixed forms:

    fvm dart format .
    fvm flutter analyze
    fvm flutter test

Targeted tests:

    fvm flutter test test/bloc/transactions_bloc_test.dart
    fvm flutter test test/widget/transactions_widgets_test.dart --plain-name "form restores draft after state restoration"

Localization generation:

    fvm flutter gen-l10n

The project enables Flutter localization generation in pubspec.yaml and configures it in l10n.yaml. Generated lib/l10n/app_localizations*.dart files are committed.

Freezed/build_runner command inferred from pubspec dependencies and committed .freezed.dart outputs:

    fvm dart run build_runner build --delete-conflicting-outputs

That build_runner command is repository-derived inference, not an explicitly documented team command. No canonical clean, build, release, or deployment command is currently documented.

scripts/agent/verify.sh does not fall back to a system Flutter installation. If FVM is unavailable, install FVM and run fvm install for the SDK pinned in .fvmrc before verification. The README's raw flutter and dart commands are direct equivalents, not the deterministic agent-verification path.

For focused verification, see scripts/agent/verify.sh and docs/agent/testing.md.
