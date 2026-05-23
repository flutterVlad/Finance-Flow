# Finance Flow

A personal finance tracking app built with Flutter. Glassmorphism UI, multi-currency support, expense analytics, and bank card management — all stored locally.

## Features

- **Dashboard** — daily expenses, monthly analytics, wallet balance overview
- **Transactions** — add, edit, categorize expenses and incomes
- **Wallet** — link bank cards, track weekly spending per card
- **Statistics** — spending breakdown by category with charts
- **Multi-currency** — BYN, USD, EUR, TRY with exchange rate support
- **Localization** — English and Russian
- **Offline-first** — all data stored locally via Hive + secure storage

## Tech Stack

| Concern         | Choice                                     |
| --------------- | ------------------------------------------ |
| State           | BLoC (flutter_bloc)                        |
| DI              | get_it                                     |
| Routing         | go_router (StatefulShellRoute)             |
| Local storage   | Hive + flutter_secure_storage              |
| Code generation | freezed + json_serializable + build_runner |
| Networking      | Dio (Talker logger)                        |
| Charts          | fl_chart                                   |
| L10n            | Flutter ARB                                |

## Screens

| Tab        | Screen                                                           |
| ---------- | ---------------------------------------------------------------- |
| Home       | Dashboard with balance, today's expenses, analytics, recent list |
| Wallet     | Bank card list, weekly expense chart per card                    |
| Actions    | Quick action hub (add transaction)                               |
| Statistics | Spending/incomes breakdown by category                           |

Modal routes: add/edit transaction, view all expenses, settings, edit account.

## Getting started

```sh
dart pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
```

Run on device or emulator:

```sh
flutter run
```
