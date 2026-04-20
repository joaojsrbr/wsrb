# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

```bash
# Build APK (Production release, split per ABI)
flutter build apk --flavor Production --release --split-per-abi

# Clean and get dependencies
flutter clean && flutter pub get

# Run code generation (required after model changes)
flutter pub run build_runner build

# Watch mode for code generation
flutter pub run build_runner watch

# Code generation order: source_generator → isar_generator → dart_mappable_builder → combining_builder
```

## Architecture

### Package Structure

The project is organized as a monorepo with three packages:

- **`app_wsrb_jsr`**: Main Flutter app - UI, routing (go_router), player logic
- **`content_library`**: Core package - repositories, services, models, AniList GraphQL integration, Isar database
- **`better_scraper`**: Web scraping framework with headless WebView for dynamic content

### Content Source Pattern (RSource)

Content sources follow a plugin-like pattern via `RSource` and `SourceRegistry`:

```
ContentRepository → SourceRegistry → RSource (per Source type)
```

- `SourceContext` provides runtime dependencies to each source (DioClient, ScrapingSession, config)
- `SourceState` tracks pagination and refresh state shared across sources
- `Filter` system for refining queries (genre, year, status, etc.)
- Each `Source` variant (e.g., `Source.GOYABU`, `Source.TOP_ANIMES`) implements `RSource` with `loadData()`, `search()`, `getData()`, `getContent()`, `getReleases()`

### Content Model Hierarchy

`Content` is a sealed class with two variants:
- `Anime` - anime content
- `Book` - book/manga content

Uses `dart_mappable` for JSON serialization (`.mapper.dart` files) and `equatable` for value equality.

### Routing

Uses `go_router` with `go_router_builder` for type-safe routes:
- Routes defined in `lib/app/routes/routes.dart` using `@TypedGoRoute` annotations
- Navigation via `GoRouterEnumNavigation` extension (`context.goEnum(RouteName.HOME)`)
- Page transitions via `SharedAxisTransitionPageWrapper`

### State Management

Provider-based with `AppConfigController` and `LibraryController` in `content_library`.

### Database

Isar database in `content_library` for offline storage of content, library, and history.

## Code Generation

Two builders active:

1. **`source_gen|combining_builder`** → generates `*.g.dart` files (combining sources)
2. **`dart_mappable_builder`** → generates `*.mapper.dart` files (JSON serialization)

The `content_library` also has a custom `source_generator` builder that runs before `isar_generator`.

Generated files are excluded from analysis (see `analysis_options.yaml`).

## Environment Setup

```bash
cp assets/.env.copy .env
```

Required in `.env`:
- `ANIME_SKIP_API_KEY` - Anime Skip API Key

## Important Conventions

- Generated files: `*.g.dart`, `*.mapper.dart`, `build/**`, `.history/**`
- Environment config: `assets/.env.copy` → `.env`
- Strict Dart analysis enabled (`strict-casts`, `strict-inference`, `strict-raw-types`)
- Lint prefers `prefer_relative_imports`, `prefer_const_constructors`, `use_super_parameters`
- Portuguese locale only (`supportedLocales: [Locale('pt')]`)
- Color scheme seed: `#FF191724` (dark purple)
