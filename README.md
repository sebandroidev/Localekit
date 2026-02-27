# LocaleKit

**The open-source desktop i18n toolkit for Flutter, React Native, and beyond.**

LocaleKit is a free, offline-first desktop application that brings the entire internationalization workflow under one roof — from string extraction to AI-assisted translation to locale file export — without SaaS pricing or cloud lock-in.

> **Status:** Pre-MVP · Active Development · Contributions Welcome

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.19%2B-02569B?logo=flutter)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Windows%20%7C%20Linux-lightgrey)](#installation)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

---

## Why LocaleKit?

Internationalizing an app is tedious. You hunt for hardcoded strings across hundreds of files, assign them keys, create ARB/JSON/YAML files, then copy-paste content into browser tabs to translate. No standalone desktop tool handles the full pipeline — until now.

| Feature | LocaleKit | Web SaaS tools |
|---|---|---|
| Works offline | ✅ | ❌ |
| Source code stays local | ✅ | ❌ |
| AI translation (your own key) | ✅ | Paid add-on |
| Flutter-native ARB support | ✅ | Plugin required |
| Free & open source | ✅ MIT | Freemium |

---

## Features

### MVP (in progress)

- **Auto framework detection** — Identifies Flutter, React Native, and JS/TS projects automatically
- **String extraction engine** — Scans your codebase and surfaces every hardcoded string
- **String browser** — Tree view organized by file and class for easy navigation
- **Translation editor** — Spreadsheet-like editor with inline editing and status tracking
- **AI-assisted translation** — One-click batch translation via Gemini, OpenAI, or Anthropic (bring your own key)
- **Export to locale files** — ARB, flat JSON, nested JSON, YAML, and Java Properties
- **Multi-project tabs** — Switch between projects without losing state
- **Offline-first** — All scanning, editing, and export works without internet

### Planned

- Source code refactoring (replace hardcoded strings with i18n keys)
- Translation memory (SQLite cache to avoid re-translating identical strings)
- Import existing locale files (merge mode)
- Plural and interpolation support
- CLI mode for CI/CD pipelines
- VS Code companion extension

See the full [Product Requirements Document](LocaleKit_PRD.md) for the complete roadmap.

---

## Installation

> Pre-built binaries will be available once v0.1.0 ships. Until then, build from source.

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.19 or later (stable channel)
- Dart SDK 3.3+
- macOS 12+, Windows 10+, or Ubuntu 20.04+

### Build from source

```bash
git clone https://github.com/sebandroidev/Localekit.git
cd Localekit
flutter pub get
flutter run -d macos      # or windows / linux
```

---

## Tech Stack

| Layer | Technology |
|---|---|
| UI Framework | Flutter Desktop 3.19+ |
| Language | Dart 3.3+ |
| State Management | Riverpod |
| Navigation | go_router |
| Local Database | Drift (SQLite) |
| String Parsing | Dart `analyzer` package (AST) + regex fallback |
| AI Translation | Gemini / OpenAI / Anthropic REST APIs |
| Secure Storage | flutter_secure_storage (OS keychain) |

---

## Contributing

LocaleKit is community-driven. All skill levels are welcome — whether you're fixing a typo, writing a parser, or designing UI components.

See [CONTRIBUTING.md](CONTRIBUTING.md) to get started.

Key areas where help is most needed:

- **Dart/Flutter**: string extraction engine, UI components, desktop platform integration
- **Testing**: unit tests for parsers, widget tests for the editor
- **Translations**: translating the app UI itself
- **Documentation**: guides, tutorials, wiki pages

---

## Community & Support

- **Bug reports & feature requests:** [GitHub Issues](https://github.com/sebandroidev/Localekit/issues)
- **Discussions:** [GitHub Discussions](https://github.com/sebandroidev/Localekit/discussions)
- **Code of Conduct:** [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)

---

## Sponsorship

LocaleKit will always be free. If it saves you time, consider supporting development:

- [GitHub Sponsors](https://github.com/sponsors/sebandroidev)
- [Open Collective](https://opencollective.com/localekit) *(coming soon)*

Sponsors get a logo in this README and early access to new features.

---

## License

MIT — free to use, modify, and distribute. See [LICENSE](LICENSE) for details.

---

*Built with Flutter. Designed for developers who ship globally.*
