# WSRB App

A Flutter application for consuming anime and books with a focus on library management, history tracking, and an optimized media playback experience.

## Features

- **Media Playback**: Video player powered by `media_kit` with support for PiP (Picture-in-Picture), screenshots, and audio handling
- **Library Management**: Track and organize anime and books in your personal library
- **History Tracking**: Automatically records viewing/reading history
- **Content Discovery**: Browse content via AniList integration and better-scraper sources
- **Reading Mode**: Dedicated reading view for book content
- **Offline Support**: Download releases for offline consumption
- **Cross-Platform**: Android, iOS, and Windows support via Flutter

## Architecture

The app is organized into two main packages:

- **`app_wsrb_jsr`**: Main Flutter application containing UI, routing, and player logic
- **`content_library`**: Core data layer handling repositories, services, models, and AniList/graphql integration

### Key Dependencies

| Package | Purpose |
|---------|---------|
| `media_kit` | Video playback |
| `go_router` | Navigation & routing |
| `provider` | State management |
| `anilist_dart` | AniList API integration |
| `better_scraper` | Web scraping for content sources |
| `isar` | Local database (via `content_library`) |

### Directory Structure

```
lib/
├── app/
│   ├── routes/          # go_router configuration
│   ├── ui/              # UI screens and widgets
│   │   ├── home/        # Home screen with library/history
│   │   ├── player/      # Video player
│   │   ├── read/        # Book reader
│   │   ├── settings/    # App settings
│   │   └── shared/      # Reusable widgets
│   └── utils/           # Utilities and helpers
└── main.dart
```

## Getting Started

1. Clone the repository
2. Copy `.env.copy` to `.env` and configure environment variables
3. Run `flutter pub get`
4. Run `dart run build_runner build` to generate code
5. Run `flutter run`

## Configuration

Environment variables required in `.env`:
- `ANIME_SKIP_API_KEY` - Anime Skip API Key

## Version

Current version: **2.0.2**
