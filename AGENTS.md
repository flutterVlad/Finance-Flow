# Finance Flow

## Commands

| Command                                                    | Purpose                                 |
| ---------------------------------------------------------- | --------------------------------------- |
| `dart pub get`                                             | Install deps                            |
| `dart run build_runner build --delete-conflicting-outputs` | Regenerate `*.g.dart`, `*.freezed.dart` |
| `flutter test`                                             | Run all tests                           |
| `dart format .`                                            | Format code                             |
| `dart analyze`                                             | Lint check (uses `flutter_lints`)       |

Run build, format, analyze, test commands only when explicitly asked.

Reference: Flutter 3.44.0, Dart 3.12.0

## Architecture

- **layers**: `lib/data/` (models, repos, services), `lib/domain/` (repository interfaces, use cases), `lib/presentation/` (BLoCs, screens)
- **DI**: `get_it` — all singletons wired in `lib/di.dart`, called from `main()` after `WidgetsFlutterBinding.ensureInitialized()` and `deferFirstFrame`
- **State**: BLoC via `bloc`/`flutter_bloc`; `TalkerBlocObserver` is active (state logging)
- **Router**: `go_router` with `StatefulShellRoute.indexedStack`; 4 bottom tabs (home, wallet, actions, statistics) + modal routes (add_transaction, settings, etc.)
- **Local storage**: Hive (`flutter_secure_storage` for encryption keys). Box names live in `lib/data/hive_boxes.dart`. Adapter IDs in `lib/data/models/hive_adapter_ids.dart`. Hive initialized in `DI._initServices()`.
- **Network**: Dio with `TalkerDioLogger` interceptor (logged but no real API endpoint wired — `api_storage.dart` is empty)
- **L10n**: Flutter ARB-based, output class `S` (configured in `l10n.yaml`). ARB files in `lib/l10n/`.

## Codegen

Model classes use `freezed` + `json_serializable` + `part` directives. Run `dart run build_runner build --delete-conflicting-outputs` after editing model files.

## Style conventions

- Follow https://dart.dev/effective-dart strictly
- Single quotes (`prefer_single_quotes` rule on)
- `const` constructors where possible
- `final` over `var` for locals and fields
- Avoid `print` (use `talker` via DI instead)
- `curly_braces_in_flow_control_structures` on
- 80 char line limit, trailing commas on multi-line calls
- `///` doc comments on all public APIs
- No `dynamic` — prefer explicit types or `Object?`
- No magic numbers — extract named constants
- No swallowed exceptions — every `catch` must handle or rethrow

## Assets

- SVGs in `assets/svg/` referenced via generated `Svgs` enum in `lib/utils/svgs/svg.dart`
- Font: Inter (only `Inter-Regular.ttf` is included)
- Theme: light only, glassmorphism UI, Cupertino page transitions on all platforms

## Generated files

`*.g.dart`, `*.freezed.dart`, `*.gr.dart` are gitignored and excluded from `dart analyze`. Do not edit manually.

## Tests

Only one placeholder test exists (`test/widget_test.dart`). Use `flutter_test` for new tests. Write business logic tests using Arrange-Act-Assert (AAA) pattern.

## Rules

- No code changes without user approval
- Keep functions <20 lines, nesting ≤3 levels
- Extract large widgets into separate methods or classes
- Prefer `const` widgets wherever possible
