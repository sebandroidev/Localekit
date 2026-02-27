# LocaleKit — Contributor Roadmap

> **Current status:** Pre-MVP. The repository contains a Flutter desktop scaffold and a full [Product Requirements Document](LocaleKit_PRD.md). Everything below needs to be built.
>
> Pick any open item, comment on the corresponding GitHub issue, and send a PR. See [CONTRIBUTING.md](CONTRIBUTING.md) for setup and coding standards.

---

## How to read this document

- Items are grouped by **milestone** (MVP → v1.0 → v2.0).
- Each item has a **size hint**: `XS` (< 2 h) · `S` (half-day) · `M` (1–2 days) · `L` (3–5 days) · `XL` (week+).
- Each item has a **skill tag**: `flutter-ui` · `dart-core` · `parsing` · `ai` · `export` · `db` · `platform` · `dx` (developer experience) · `docs`.
- Items marked **🔑 critical path** must be completed before dependent items can start.
- Items marked **good first issue** are well-scoped and beginner-friendly.

---

## Milestone 0 — Foundation (pre-MVP scaffolding)

These are unblocked tasks anyone can start today.

| # | Task | Size | Skills | Notes |
|---|------|------|--------|-------|
| F-01 | **Add all planned dependencies to `pubspec.yaml`** — riverpod, go_router, drift, flutter_secure_storage, file_picker, path_provider, analyzer, http, freezed, yaml, crypto, re_highlight, window_manager, archive, intl | XS | `dx` | Good first issue. Use exact versions from PRD §9. Run `flutter pub get` to verify resolution. |
| F-02 | **Set up `build_runner` code generation pipeline** — configure `build.yaml`, verify `freezed` and `drift` generation work end-to-end | S | `dx` | Depends on F-01. |
| F-03 | **Configure `very_good_analysis` lint rules** — add `analysis_options.yaml` with strict ruleset; fix any violations in scaffolded code | XS | `dx` | Good first issue. |
| F-04 | **Set up folder structure** — create empty folders per `CONTRIBUTING.md §Project Structure`: `lib/features/{projects,extraction,translation,export}/`, `lib/core/{database,ai,theme}/`, `lib/shared/widgets/`, `test/` mirroring | XS | `dx` | Good first issue. Add `.gitkeep` files. |
| F-05 | **Replace counter demo with empty app shell** — `main.dart` boots a blank `MaterialApp` with dark/light theme toggle, title "LocaleKit", correct window size | S | `flutter-ui` | Good first issue. Use `window_manager` to set min size 900×600. |
| F-06 | **Define theme system** — `lib/core/theme/` with dark theme, light theme, shared color tokens, and a `ThemeProvider` (Riverpod) that persists preference to `shared_preferences` | M | `flutter-ui` · `dart-core` | Follow PRD §7 design principles: density-aware, dark default. |
| F-07 | **Set up GitHub Actions CI** — matrix build for `ubuntu-latest`, `windows-latest`, `macos-latest`; run `flutter analyze` and `flutter test` on every PR | M | `platform` · `dx` | See PRD §14-D for matrix config. |
| F-08 | **Drift database schema** — implement all four tables (`projects`, `strings`, `translations`, `translation_memory`) from PRD §8 with Drift DAOs and migrations | L | `db` · `dart-core` | 🔑 critical path — most features depend on this. |
| F-09 | **Set up go_router routing** — define named routes for: `/` (welcome), `/workspace` (main), `/settings`; shell route for tab bar | M | `dart-core` · `flutter-ui` | Depends on F-05. |

---

## Milestone 1 — MVP v0.1.0

**Goal:** A working tool for Flutter developers to extract strings, translate them, and export valid ARB files.

### 1-A · Project Management

| # | Task | Size | Skills | Notes |
|---|------|------|--------|-------|
| PM-01 | **Welcome screen** — centered empty state with LocaleKit logo, "Open Project Folder" button (`Cmd/Ctrl+O`), recent projects list (from SQLite) | M | `flutter-ui` | Good first issue after F-09. |
| PM-02 | **OS folder picker integration** — wire `file_picker` to open a directory; store absolute path in `projects` table | S | `dart-core` | Good first issue after F-08. |
| PM-03 | **Framework auto-detection** — inspect folder for `pubspec.yaml` → Flutter, `package.json` → React Native / JS | S | `dart-core` · `parsing` | Heuristics in PRD §8. Return enum `{flutter, reactNative, unknown}`. |
| PM-04 | **Manual framework selection fallback** — small dialog when auto-detection returns `unknown` | S | `flutter-ui` | Depends on PM-03. |
| PM-05 | **Project state provider** — Riverpod `AsyncNotifier` that loads/creates a `Project` record, exposes `openProject(path)`, `closeProject(id)` | M | `dart-core` | 🔑 critical path. |
| PM-06 | **Multi-project tab bar** — horizontal scrollable tab strip with per-project label, close button (`×`), and `+` button; state preserved on tab switch | L | `flutter-ui` · `dart-core` | PRD §5 Flow 5. |
| PM-07 | **Tab right-click context menu** — "Close", "Close others", "Show in Finder/Explorer" | S | `flutter-ui` | Depends on PM-06. |
| PM-08 | **Recent projects persistence** — load last 10 opened project paths from SQLite on app start | S | `db` | Good first issue after F-08. |

### 1-B · String Extraction Engine

| # | Task | Size | Skills | Notes |
|---|------|------|--------|-------|
| EX-01 | **Dart regex string extractor** — heuristic regex patterns for `Text(...)`, `hintText:`, `labelText:`, `tooltip:`, `title:` (see PRD §6.2 & §14-B) | L | `parsing` · `dart-core` | 🔑 critical path for MVP. Output: `List<ExtractedString>`. |
| EX-02 | **Non-translatable string filter** — apply exclusion regexes for URLs, hex colors, asset paths, format strings, single lowercase words (PRD §6.2 heuristics table) | M | `parsing` | Depends on EX-01. Unit tests with sample Dart files required. |
| EX-03 | **Auto-key generation** — derive i18n keys from extracted string values (`camelCase` / `snake_case` / `dot.notation`); detect and warn on key collisions | M | `dart-core` | Key naming conventions in PRD §14-C. |
| EX-04 | **Dart Isolate scanner** — run extraction in a background `Isolate` with progress stream; UI stays at 60fps during scan | M | `dart-core` | 🔑 critical path for performance. PRD §10. |
| EX-05 | **Scan progress UI** — progress bar or spinner in the string browser while scan is running; "Cancel" button | S | `flutter-ui` | Depends on EX-04. |
| EX-06 | **Persist extracted strings to SQLite** — upsert `strings` table rows; mark new strings `untranslated`, changed strings `modified`, unchanged strings `existing` | M | `db` · `dart-core` | Depends on EX-01 + F-08. |
| EX-07 | **Re-scan / incremental scan** — on "Scan" button press, re-extract and diff against stored strings; preserve existing translations | L | `parsing` · `db` | Depends on EX-06. |
| EX-08 | **Scan settings** — min string length, custom ignore glob patterns, custom regex patterns (stored in `projects.settings_json`) | M | `flutter-ui` · `dart-core` | PRD §7 Screen 3 "Extraction Rules" tab. |

### 1-C · String Browser UI

| # | Task | Size | Skills | Notes |
|---|------|------|--------|-------|
| SB-01 | **File tree widget** — collapsible tree: `project → directory → file → string`; color-coded status badges (green/red/yellow/gray) | XL | `flutter-ui` | Central UI component. PRD §7 left pane. |
| SB-02 | **Status badge legend** — bottom status bar showing counts: total, untranslated (🔴), modified (🟡), approved (✅), ignored (⬜) | S | `flutter-ui` | Good first issue after SB-01. |
| SB-03 | **Search / filter bar** — real-time text filter applied to tree; filter by status (radio/chip) | M | `flutter-ui` · `dart-core` | Good first issue after SB-01. |
| SB-04 | **String node context menu** — right-click: "Ignore string", "Assign custom key", "Copy value" | S | `flutter-ui` | Good first issue after SB-01. |
| SB-05 | **Keyboard navigation** — Arrow keys to navigate tree, `Enter` to open translation editor, `Escape` to collapse node | M | `flutter-ui` | PRD §10 Accessibility. |

### 1-D · Translation Editor UI

| # | Task | Size | Skills | Notes |
|---|------|------|--------|-------|
| TE-01 | **Translation editor panel** — source string header (with interpolation variables highlighted), locale table (Locale / Translation / Status), inline editable cells | XL | `flutter-ui` | 🔑 critical path. PRD §7 right pane. |
| TE-02 | **Add / remove target locale** — `+` button opens locale picker (language code list); stores in project settings | M | `flutter-ui` · `db` | Depends on TE-01. |
| TE-03 | **Inline cell editing** — click any translation cell to enter edit mode; `Tab` to advance to next locale; `Shift+Tab` to go back; `Escape` to cancel | M | `flutter-ui` | Good first issue after TE-01. |
| TE-04 | **Translation status icons** — ✅ approved, 🤖 auto-translated, ✏️ manual, 🔴 untranslated; clickable to cycle status | S | `flutter-ui` | Good first issue after TE-01. |
| TE-05 | **Persist translation edits to SQLite** — debounced auto-save (30 s) + immediate save on `Tab`/`Enter`; atomic writes | M | `db` · `dart-core` | PRD §10 Reliability. |
| TE-06 | **Source code context snippet** — below the table, show read-only syntax-highlighted code context (file + line); use `re_highlight` | M | `flutter-ui` | Depends on TE-01 + EX-01 (context_snippet field). |
| TE-07 | **"Approve all" action** — bulk-approves all auto-translated strings for the currently selected source string | S | `flutter-ui` · `db` | Good first issue after TE-01. |

### 1-E · AI Translation

| # | Task | Size | Skills | Notes |
|---|------|------|--------|-------|
| AI-01 | **`AITranslationAdapter` abstract class** — interface: `Future<List<String>> translateBatch(List<String> strings, String targetLocale, {String? systemHint})` | S | `dart-core` · `ai` | 🔑 critical path. PRD §9 architecture diagram. |
| AI-02 | **Gemini adapter** — implement `AITranslationAdapter` for `gemini-1.5-flash` / `gemini-1.5-pro`; use `http` package; parse JSON array response | L | `ai` · `dart-core` | PRD §6.4. Unit tests with mocked HTTP required. |
| AI-03 | **OpenAI adapter** — implement for `gpt-4o-mini` / `gpt-4o`; chat completions endpoint | L | `ai` · `dart-core` | Same interface as AI-02. |
| AI-04 | **Anthropic adapter** — implement for `claude-haiku-4-5` / `claude-sonnet-4-6`; messages endpoint | L | `ai` · `dart-core` | Same interface as AI-02. |
| AI-05 | **System prompt template** — implement prompt from PRD §6.4 with `{sourceLang}`, `{targetLang}`, `{jsonArrayOfStrings}` substitution; ensure placeholder preservation rules are included | M | `ai` · `dart-core` | Shared across all adapters. |
| AI-06 | **Batch chunking** — split string lists into batches of ≤50; send sequentially with configurable delay (default 500ms) | M | `dart-core` · `ai` | PRD §6.4 rate limiting. |
| AI-07 | **API key storage** — store per-provider keys in OS keychain via `flutter_secure_storage`; never write to SQLite or files | M | `dart-core` | PRD §6.4 + §10 Security. |
| AI-08 | **Settings panel — AI Providers tab** — per-provider: masked key input, model selector dropdown, "Test connection" button, rate limit slider | L | `flutter-ui` · `ai` | Depends on AI-07. |
| AI-09 | **Translation memory cache** — before calling AI, check `translation_memory` table by SHA-256 hash of `(source+sourceLang+targetLang)`; store new results after call | M | `db` · `dart-core` | PRD §6.4 offline cache. |
| AI-10 | **"Auto-translate" button** — triggers batched AI calls for selected locale rows; shows progress; handles errors gracefully | M | `flutter-ui` · `ai` | Depends on AI-02 through AI-09. |
| AI-11 | **AI error handling** — malformed JSON response retry (1x), rate limit backoff (exponential), provider down graceful degradation to manual mode | M | `ai` · `dart-core` | PRD §12 risk mitigation. |

### 1-F · Export

| # | Task | Size | Skills | Notes |
|---|------|------|--------|-------|
| EXP-01 | **`LocaleFileWriter` abstract class** — interface: `Future<void> write(Map<String, String> translations, String locale, File outputFile)` | XS | `dart-core` · `export` | Good first issue. |
| EXP-02 | **ARB writer** — outputs Flutter ARB format with `@@locale`, string entries, and `@key` metadata blocks (with placeholders if interpolation detected) | L | `export` · `dart-core` | PRD §8 Output Formats. Unit tests with fixture files. |
| EXP-03 | **Flat JSON writer** — outputs `{"key": "value"}` format | S | `export` | Good first issue after EXP-01. |
| EXP-04 | **Nested JSON writer** — outputs dot-notation keys as nested objects; e.g. `auth.signIn` → `{"auth": {"signIn": "..."}}` | M | `export` | Depends on EXP-01. |
| EXP-05 | **YAML writer** — outputs YAML locale files using `yaml` package | M | `export` | Depends on EXP-01. |
| EXP-06 | **Java `.properties` writer** — outputs `key=value` format | S | `export` | Good first issue after EXP-01. |
| EXP-07 | **Export dialog UI** — format selector, output directory picker, file preview tree, "Export" button with progress | L | `flutter-ui` · `export` | PRD §7 Screen 4. |
| EXP-08 | **Atomic file write** — write to temp file first, then rename; prevents partial files on crash | S | `dart-core` · `export` | PRD §10 Reliability. Good first issue after EXP-02. |
| EXP-09 | **Export validation** — warn if any locale has untranslated strings; warn on duplicate keys; show per-locale completion percentage | M | `dart-core` · `flutter-ui` | |

### 1-G · Settings Panel

| # | Task | Size | Skills | Notes |
|---|------|------|--------|-------|
| SET-01 | **Settings panel shell** — modal/side-sheet with tabs: General, AI Providers, Extraction Rules, Export Defaults, Keyboard Shortcuts | M | `flutter-ui` | PRD §7 Screen 3. |
| SET-02 | **General tab** — theme toggle (dark/light/system), telemetry opt-in checkbox with disclosure text | S | `flutter-ui` · `dart-core` | Good first issue after SET-01. |
| SET-03 | **Export Defaults tab** — default format per framework, output path template, key naming convention (camelCase / snake_case / dot.notation / SCREAMING_SNAKE) | M | `flutter-ui` · `dart-core` | |
| SET-04 | **Keyboard Shortcuts tab** — display shortcut map; allow rebinding (store in `shared_preferences`) | L | `flutter-ui` · `dart-core` | PRD §7. |

### 1-H · Platform & Distribution

| # | Task | Size | Skills | Notes |
|---|------|------|--------|-------|
| PL-01 | **macOS entitlements** — `com.apple.security.files.user-selected.read-write` for folder access outside sandbox; test on macOS 12, 13, 14 | M | `platform` | PRD §6.1. Required for file access outside sandbox. |
| PL-02 | **macOS DMG build** — GitHub Actions step to produce `.dmg` via `create-dmg` or `electron-builder`-equivalent for Flutter | M | `platform` · `dx` | PRD §14-D. |
| PL-03 | **Windows ZIP build** — GitHub Actions step to produce `.zip` of the release build | M | `platform` · `dx` | PRD §14-D. |
| PL-04 | **Linux tar.gz build** — GitHub Actions step to produce `.tar.gz`; test on Ubuntu 20.04 and 22.04 | M | `platform` · `dx` | PRD §14-D. |
| PL-05 | **Window size persistence** — save and restore window bounds using `window_manager` + `shared_preferences` | S | `flutter-ui` · `dart-core` | Good first issue. |

---

## Milestone 2 — v1.0

**Goal:** Production-quality tool with AST parsing, React Native support, and team-oriented workflow features.

| # | Task | Size | Skills | Notes |
|---|------|------|--------|-------|
| V1-01 | **Dart AST parser** — replace regex extractor with `package:analyzer` AST traversal; visit `StringLiteral` nodes in widget contexts; preserve context_snippet, line number | XL | `parsing` · `dart-core` | PRD §6.2. Major quality improvement over regex. |
| V1-02 | **React Native / i18next parser** — regex-based extraction of `t('key')`, `i18n.t('ns:key')`, `<Trans i18nKey="…" />` patterns | L | `parsing` | PRD §6.2 JS/TS patterns. |
| V1-03 | **Source code refactoring** — replace extracted hardcoded string literals in `.dart` source files with the generated i18n key (`AppLocalizations.of(context).keyName`) | XL | `parsing` · `dart-core` | PRD §4 P1. Requires careful AST-level rewriting. |
| V1-04 | **Import existing locale files** — ARB / flat JSON / YAML importer that merges existing translations into `translations` table; no data loss on conflict | L | `export` · `db` | PRD §4 P7. |
| V1-05 | **Plural & ICU interpolation detection** — detect `{count, plural, one{...} other{...}}` patterns; pass them correctly to AI with preservation rules | L | `parsing` · `ai` | PRD §4 P4 + `intl` package. |
| V1-06 | **Batch operations** — multi-select strings in tree; batch translate / approve / export selected set | M | `flutter-ui` · `dart-core` | PRD §4 P6. |
| V1-07 | **Search & filter (advanced)** — filter by status (untranslated / modified / approved), search by key name or source value, filter by locale completion | M | `flutter-ui` · `db` | PRD §4 P5. |
| V1-08 | **Git commit helper** — after export, stage locale files and optionally source files; pre-fill conventional commit message; show diff preview | L | `dart-core` · `platform` | PRD §4 P2. Uses `dart:io` Process to call `git`. |
| V1-09 | **Test corpus** — collect 3+ real-world open-source Flutter apps as extraction test fixtures; write golden-file tests for extraction accuracy; target ≥95% | L | `parsing` · `dx` | PRD §2 Quality Metrics. |
| V1-10 | **Incremental re-scan (file watcher)** — optionally watch project folder for changes; trigger partial re-scan on modified files | M | `dart-core` · `parsing` | PRD §12 performance risk mitigation. |
| V1-11 | **Opt-in telemetry** — integrate Sentry for crash reporting behind opt-in flag; crash rate target < 0.5% | M | `dart-core` · `platform` | PRD §2 Quality Metrics. |
| V1-12 | **Accessibility audit** — full keyboard navigation test, WCAG AA contrast check for both themes, Semantics labels on all interactive elements | M | `flutter-ui` | PRD §10 Accessibility. |

---

## Milestone 3 — v2.0

**Goal:** Ecosystem expansion — more frameworks, CLI support, QA tooling, plugin API.

| # | Task | Size | Skills | Notes |
|---|------|------|--------|-------|
| V2-01 | **Vue.js / Nuxt parser** — extract `$t('key')` and `t('key')` patterns from `.vue` and `.js`/`.ts` files | L | `parsing` | PRD §3 Framework Coverage. |
| V2-02 | **Next.js / React parser** — extract `t('key')` (next-i18next), `useTranslation` hook pattern | L | `parsing` | PRD §3 Framework Coverage. |
| V2-03 | **PO/Gettext exporter** — write `.po` / `.pot` files for web/Python/PHP projects | M | `export` | PRD §6.3. |
| V2-04 | **XLIFF exporter** — write `.xliff` format for Apple and enterprise workflows | M | `export` | PRD §6.3. |
| V2-05 | **CSV exporter** — export all strings + translations to `.csv` for human translators | S | `export` | Good first issue. PRD §6.3. |
| V2-06 | **`.lckit` bundle exporter** — ZIP archive containing string list + source metadata (no source code) for external translators; includes importer | L | `export` · `dart-core` | PRD §4 N3. Uses `archive` package. |
| V2-07 | **CLI mode** — `localekit extract --path ./myapp --export arb --output ./l10n` command-line interface | XL | `dart-core` · `platform` | PRD §4 N1. Separate entrypoint, same core logic. |
| V2-08 | **Translation QA checks** — detect missing interpolation variables in translations, string length violations, RTL language issues | L | `dart-core` · `ai` | PRD §4 N4. |
| V2-09 | **Plugin API** — allow custom framework parsers via Dart plugins loaded at runtime | XL | `dart-core` | PRD §4 N5. Requires careful API design. |
| V2-10 | **VS Code companion extension** — "Open in LocaleKit" context menu command in VS Code that deep-links to the correct string in LocaleKit | L | `platform` | PRD §4 N2. TypeScript extension + URL scheme handler in Flutter. |

---

## Cross-cutting concerns (any milestone)

These tasks are always welcome and can be picked up independently.

| # | Task | Size | Skills | Notes |
|---|------|------|--------|-------|
| CC-01 | **Improve README** — screenshots, GIF demo, installation badges, feature table | S | `docs` | Good first issue. |
| CC-02 | **Docs site** — simple GitHub Pages or Mintlify site with Getting Started guide, feature reference, FAQ | L | `docs` | |
| CC-03 | **LocaleKit i18n itself** — the app UI should use its own i18n system; add English ARB baseline, invite community locale PRs | M | `flutter-ui` · `docs` | "Eating our own cooking." |
| CC-04 | **App icon** — design and implement the LocaleKit app icon for macOS, Windows, Linux (all required sizes) | M | `platform` | Design contribution welcome. |
| CC-05 | **Unit test coverage** — add missing unit tests for any under-tested module; target > 80% line coverage | varies | `dart-core` | Always welcome. |
| CC-06 | **Performance profiling** — profile app on a 1000-file Flutter project; identify and fix any frame drops or slow queries | L | `dart-core` · `db` | PRD §10 Performance targets. |
| CC-07 | **Dark/light theme polish** — verify all custom widgets respect theme correctly; fix any hardcoded colors | M | `flutter-ui` | Good first issue. |
| CC-08 | **Localization of locale list** — the locale picker should show human-readable language names (English + native name) for all BCP-47 codes | S | `dart-core` | Good first issue. |

---

## Dependency map (critical path)

```
F-01 (deps) → F-02 (codegen) → F-08 (DB schema) ─┬─→ PM-02 → PM-05 → PM-06
                                                    ├─→ EX-01 → EX-02 → EX-06 → SB-01
                                                    └─→ TE-01 → TE-05

F-05 (app shell) → F-09 (routing) → PM-01

AI-01 (adapter interface) → AI-02 / AI-03 / AI-04 → AI-10

EXP-01 (writer interface) → EXP-02 / EXP-03 / EXP-04 / EXP-05 / EXP-06 → EXP-07
```

---

## How to claim a task

1. Find the task in the table above.
2. Open (or find) the corresponding **GitHub Issue** — use the task ID (e.g. `EX-01`) in the issue title.
3. **Comment on the issue** to signal you're working on it so others don't duplicate effort.
4. Branch: `feat/<task-id>-<short-description>` (e.g. `feat/ex-01-dart-regex-extractor`).
5. Submit a PR when ready; link the issue with `Closes #<number>`.

If no issue exists yet for the task you want, create one — that's a contribution too.

---

## Prioritization guidance for maintainers

When reviewing PRs, the priority order for MVP is:

1. **Foundation** (F-01 through F-09) — unblocks everything
2. **Database schema** (F-08) — most features depend on it
3. **String extraction engine** (EX-01, EX-04) — core value proposition
4. **String browser UI** (SB-01) — first visible result
5. **AI adapter interface + one provider** (AI-01, AI-02) — demo-able milestone
6. **ARB export** (EXP-01, EXP-02) — completes the full pipeline
7. **Translation editor** (TE-01) — ties everything together

---

*For questions about a task, open a GitHub Discussion or comment on the relevant issue.*
*For the full product specification, see [LocaleKit_PRD.md](LocaleKit_PRD.md).*
