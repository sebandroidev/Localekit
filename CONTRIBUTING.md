# Contributing to LocaleKit

Thank you for your interest in contributing! LocaleKit is a community project and every contribution matters — from fixing a typo to building a new parser.

---

## Table of Contents

1. [Code of Conduct](#code-of-conduct)
2. [Getting Started](#getting-started)
3. [Ways to Contribute](#ways-to-contribute)
4. [Development Setup](#development-setup)
5. [Project Structure](#project-structure)
6. [Workflow](#workflow)
7. [Coding Standards](#coding-standards)
8. [Testing](#testing)
9. [Commit Messages](#commit-messages)
10. [Pull Request Process](#pull-request-process)
11. [Issue Labels](#issue-labels)

---

## Code of Conduct

This project follows the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md). By participating, you agree to uphold it. Report unacceptable behavior to the maintainers via GitHub Issues (mark as confidential) or by emailing the project owner directly.

---

## Getting Started

1. **Browse open issues** — look for ones tagged [`good first issue`](https://github.com/sebandroidev/Localekit/labels/good%20first%20issue) or [`help wanted`](https://github.com/sebandroidev/Localekit/labels/help%20wanted)
2. **Comment on the issue** to let others know you're working on it
3. **Fork the repo**, make your changes, and open a pull request
4. A maintainer will review your PR within a few days

If you want to work on something not listed, open an issue first to discuss the approach before investing time in an implementation.

---

## Ways to Contribute

### Code

- **String extraction engine** — Dart AST traversal using the `analyzer` package, regex parsers for JS/TS
- **UI components** — String browser tree, translation editor, settings panel
- **AI provider adapters** — Gemini, OpenAI, Anthropic integrations
- **Export formatters** — ARB, JSON, YAML, .properties writers
- **Desktop platform work** — macOS entitlements, Windows installer, Linux packaging
- **Performance** — Isolate-based scanning, SQLite query optimization

### Non-code

- **Bug reports** — Detailed reports with reproduction steps are extremely valuable
- **Feature requests** — Open a Discussion before filing an issue for large features
- **Documentation** — README improvements, wiki pages, in-code doc comments
- **Testing** — Manual testing on your platform and filing precise bug reports
- **Design** — UI/UX proposals, icon design, accessibility review
- **Translations** — Translating the LocaleKit UI itself

---

## Development Setup

### Prerequisites

| Requirement | Version |
|---|---|
| Flutter SDK | 3.19+ (stable channel) |
| Dart SDK | 3.3+ |
| macOS | 12+ (for macOS builds) |
| Windows | 10+ (for Windows builds) |
| Ubuntu | 20.04+ (for Linux builds) |

### Setup

```bash
# 1. Fork and clone
git clone https://github.com/<your-username>/Localekit.git
cd Localekit

# 2. Install dependencies
flutter pub get

# 3. Run code generation (once dependencies are added)
dart run build_runner build --delete-conflicting-outputs

# 4. Run the app
flutter run -d macos      # or: windows, linux

# 5. Run tests
flutter test
```

### Recommended IDE Setup

- **VS Code** with the [Flutter extension](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter)
- **Android Studio / IntelliJ** with the Flutter and Dart plugins
- Enable format-on-save with `dart format`

---

## Project Structure

```
localekit/
├── lib/
│   ├── main.dart                  # App entry point
│   ├── features/
│   │   ├── projects/              # Project management (open, detect, tabs)
│   │   ├── extraction/            # String scanning and AST parsing
│   │   ├── translation/           # Translation editor and AI integration
│   │   └── export/                # Locale file writers (ARB, JSON, YAML…)
│   ├── core/
│   │   ├── database/              # Drift schema, DAOs, migrations
│   │   ├── ai/                    # AI provider adapters
│   │   └── theme/                 # Dark/light theme definitions
│   └── shared/
│       └── widgets/               # Reusable UI components
├── test/                          # Unit and widget tests
├── LocaleKit_PRD.md               # Full product requirements document
├── CONTRIBUTING.md                # This file
└── CODE_OF_CONDUCT.md
```

> The folder structure above is the target architecture. If you're adding a new feature, follow this layout.

---

## Workflow

### Branching

- `main` — stable, always buildable
- `feat/<short-description>` — new features (e.g., `feat/arb-exporter`)
- `fix/<short-description>` — bug fixes (e.g., `fix/crash-on-empty-project`)
- `docs/<short-description>` — documentation only

### Step-by-step

```bash
# Start from an up-to-date main
git checkout main
git pull upstream main

# Create your branch
git checkout -b feat/my-feature

# Make changes, then commit
git add <specific files>
git commit -m "feat: add ARB export for Flutter projects"

# Push and open a PR
git push origin feat/my-feature
```

---

## Coding Standards

### General

- Follow the [official Dart style guide](https://dart.dev/effective-dart/style)
- Run `dart format .` before committing — CI will reject unformatted code
- Run `dart analyze` — zero warnings policy for new code
- Use `very_good_analysis` lint rules (configured in `analysis_options.yaml`)

### Dart specifics

- Prefer `final` for all local variables that don't reassign
- Use `const` constructors wherever possible
- Prefer named parameters for functions with more than 2 arguments
- Use `sealed` classes and pattern matching for state variants (Dart 3.3+)
- Never use `dynamic` unless interfacing with external JSON — always parse into typed models

### Flutter specifics

- Keep widgets small and focused — extract any widget exceeding ~80 lines
- Use `ConsumerWidget` / `ConsumerStatefulWidget` (Riverpod) instead of plain `StatefulWidget` for anything touching state
- All user-facing strings must go through the i18n system (LocaleKit eats its own cooking)
- Add `Semantics` labels to all interactive elements

### File naming

- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables/functions: `camelCase`
- Constants: `camelCase` (Dart convention, not `SCREAMING_SNAKE`)

---

## Testing

All new code should include tests. The bar is:

| Code type | Required coverage |
|---|---|
| Parser/extraction logic | Unit tests with sample input files |
| AI adapters | Unit tests with mocked HTTP responses |
| Export formatters | Unit tests comparing output against known-good fixtures |
| UI components | Widget tests for key interactions |
| Business logic (providers) | Unit tests via `ProviderContainer` |

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html

# Run a single file
flutter test test/extraction/dart_parser_test.dart
```

Place test files in `test/` mirroring the `lib/` structure.

---

## Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <short description>

[optional body]

[optional footer]
```

**Types:**

| Type | When to use |
|---|---|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `test` | Adding or fixing tests |
| `refactor` | Code change that's not a feature or fix |
| `perf` | Performance improvement |
| `chore` | Build scripts, dependency updates, tooling |

**Examples:**

```
feat(extraction): add regex fallback parser for Flutter string literals
fix(export): handle empty locale list without crashing
docs(readme): add installation instructions for Linux
test(ai): add mock tests for Gemini adapter rate limiting
```

---

## Pull Request Process

1. **Fill out the PR template** — describe what changed and why
2. **Link the related issue** — `Closes #42` in the PR description
3. **Keep PRs focused** — one logical change per PR; split large changes into smaller ones
4. **Pass CI** — all tests must pass, no format errors, no analyzer warnings
5. **Request a review** — tag `@sebandroidev` or wait for auto-assignment
6. **Address review comments** — push additional commits (don't force-push during review)
7. **Squash on merge** — maintainers will squash commits when merging

### PR checklist

Before marking your PR as ready for review:

- [ ] `dart format .` passes
- [ ] `dart analyze` passes with zero warnings
- [ ] Tests added for new logic
- [ ] `flutter test` passes locally
- [ ] PR description explains *why* the change is needed, not just *what* it does

---

## Issue Labels

| Label | Meaning |
|---|---|
| `good first issue` | Suitable for newcomers — limited scope, well-defined |
| `help wanted` | Maintainer needs community help |
| `bug` | Confirmed bug with reproduction steps |
| `enhancement` | New feature or improvement |
| `parser` | Related to string extraction / AST parsing |
| `ui` | UI/UX changes |
| `ai` | AI translation integration |
| `export` | Locale file export formatters |
| `platform: macos` / `windows` / `linux` | Platform-specific issues |
| `docs` | Documentation |
| `question` | Needs clarification before work begins |
| `wontfix` | Out of scope or intentionally not addressed |

---

## Recognition

All contributors are listed in the [GitHub Contributors graph](https://github.com/sebandroidev/Localekit/graphs/contributors). Significant contributors may be invited as co-maintainers.

---

Thank you for making LocaleKit better for everyone.
