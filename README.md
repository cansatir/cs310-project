# SpendWise — CS310 Group 2

A Flutter expense tracker with a monthly dashboard, editable expense cards,
category charts and currency preferences. This repository contains the Step 2.2
UI implementation based on the submitted Step 2.1 design.

## Run

Tested with **Flutter 3.47.6 (stable), Dart 3.13.5** on 22 November 2026.
The Dart SDK constraint is `^3.13.2`; use the tested Flutter version to reproduce
the checks. Install Flutter and the Android SDK, or Xcode for an iOS simulator.

```bash
git clone https://github.com/cansatir/cs310-project.git
cd cs310-project
flutter --version
flutter pub get
flutter devices
flutter run -d <device-id>
```

Start an Android emulator or iOS simulator before choosing its ID. The verified
Android target was `emulator-5554` (Medium Phone API 37.0, arm64):

```bash
flutter run -d emulator-5554
```

The Android debug build installed and launched successfully. iOS was not tested
on the verification machine. A browser preview is also available:

```bash
flutter run -d chrome
```

## Demo flow

1. Log in with any valid email and a nonempty password, or open Sign up.
   Sign up requires a name, valid email, at least eight password characters and
   matching confirmation. For a demo use `demo@example.com` / `password123`.
2. Select USD, TRY or EUR in Settings **before** creating expenses.
3. Add an expense with a title, positive finite amount, date and category.
   The note is optional. Invalid fields show inline errors. A successful save
   opens a confirmation dialog; OK returns to Dashboard.
4. Use the card menu or swipe right to edit. The menu or swipe left opens a
   delete confirmation. Cancel preserves the record; Delete removes it.
5. Change the month to inspect its newest-first expense list and total. Summary
   shows the same monthly total and all seven category totals with relative bars.

Login and Sign up are **UI-only**: they do not contact a server, create accounts
or store passwords. Firebase/authentication belongs to Step 3. All demo logins
share the same local expense list. Expenses and currency preferences use the
existing SharedPreferences storage; there is no account-specific storage,
currency conversion or cloud sync. Currency is locked while expenses exist.
The only network-dependent UI element is the Settings illustration; it has a
loading state and an error fallback. The core expense flow works offline.

## Structure

| Location | Responsibility |
| --- | --- |
| `lib/main.dart` | Startup, currency loading, Provider and application theme |
| `lib/screens/auth/` | Login, Sign up, validators and password field |
| `lib/screens/main_shell.dart` | Dashboard / Summary / Settings navigation |
| `lib/widgets/expenses.dart` | Monthly dashboard and form integration |
| `lib/widgets/expenses_list/` | Expense Cards, edit and confirmed removal |
| `lib/widgets/new_expense.dart` | Shared add/edit form and submission feedback |
| `lib/screens/summary_screen.dart` | Monthly totals and category chart |
| `lib/utils/monthly_summary.dart` | Shared month filtering, ordering and totals |
| `lib/screens/setting_screen.dart`, `lib/settings/` | Currency and About screen |
| `lib/theme/`, `lib/widgets/shared/` | Colors, typography, spacing and shared UI |
| `lib/models/`, `lib/providers/` | Expense model and local state/storage |
| `test/` | Calculation, validation, navigation and integration tests |
| `docs/screenshots/` | Real UI captures for the submission document |

## Verification

```bash
flutter analyze
flutter test
dart format --output=none --set-exit-if-changed lib test
```

The integration suite covers add/edit/delete, cancellation, month/year filtering,
shared totals, currency propagation/locking, and valid signup navigation.
Portrait widget tests cover 320×568 and 430×932, keyboard-open forms, and main
screens with 130% text scaling. Actual browser inspection also covered those
portrait sizes. Browser screenshots are labeled as browser captures, not Android
screenshots. See [verification and submission notes](docs/STEP_2_2_DELIVERY_TR.md)
for actual results, remaining submission actions and known limitations.

## Team contributions

| Member | Step 2.2 contribution |
| --- | --- |
| Khalil Khalilli | Login/Sign-up, auth form validation and navigation |
| Akif Şentürk | Add/edit validation, success dialog and responsive form tests |
| Atilla Mammadzada | Monthly summary calculation and category charts |
| Harun Can Yurdagül | Settings, currency preferences, theme, font and images |
| Berat Can Satır | Dashboard, confirmed removal, shared UI/currency integration, tests and submission preparation |

Individual implementation commits remain in Git history. Integration does not
replace teammates' authorship.

## Assets

- Local SpendWise mark: `assets/images/spendwise_mark.png`.
- Roboto Mono Medium: bundled under `assets/fonts/` with its license.
- Settings chart illustration: [Twemoji](https://github.com/twitter/twemoji),
  © Twitter, Inc. and contributors, [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/),
  loaded from a version-pinned jsDelivr URL.

Step 2.1 is already submitted. The final Step 2.2 PDF must be named
`CS310_Group2_Step2.2.pdf` and include the public repository link, final submitted
commit SHA, labeled core screenshots and Member Contributions. A draft with a
pending SHA must not be uploaded as the final submission.
