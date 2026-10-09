# Nova Music

A modern, cross-platform music player built with Flutter, designed to deliver a clean interface, customizable appearance, and a smooth music-listening experience.

## Features

- **Modern UI** — A clean, dark-themed interface with a contemporary design.
- **Customizable Appearance** — Configure the theme, accent color, UI scaling, and other appearance settings.
- **Playback Controls** — Play, pause, skip, and navigate through your music.
- **Crossfade** — Smooth transitions between consecutive tracks with a configurable duration.
- **Shuffle & Repeat** — Customize playback order and repeat behavior.
- **Playback Queue** — Manage the songs you want to listen to.
- **Mini-player** — Control playback without leaving your current screen.
- **Offline Music Library** — Scan and manage music stored in local folders.
- **Recently Played** — Keep track of recently played songs.
- **Search** — Find music in your library.
- **Persistent Settings** — Save preferences between app sessions.

## Tech Stack

- **Framework:** Flutter
- **Language:** Dart
- **Platform:** Cross-platform architecture, with Windows desktop support

## Getting Started

### Prerequisites

Install the following before running the project:

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Dart SDK](https://dart.dev/get-dart) (included with Flutter)
- [Git](https://git-scm.com/downloads)
- [Visual Studio](https://visualstudio.microsoft.com/) with the **Desktop development with C++** workload for Windows desktop development

Verify your Flutter installation:

```bash
flutter doctor
```

### Clone the Repository

```bash
git clone https://github.com/abhinavrejio/Nova-Music.git
cd Nova-Music
```

The Flutter application is located in `apps/player`.

### Install Dependencies

```bash
cd apps/player
flutter pub get
```

### Run the Application

To run on Windows:

```bash
flutter run -d windows
```

To list available devices:

```bash
flutter devices
```

Then use the appropriate device identifier to run the application on a supported target.

## Development

### Analyze the Code

```bash
flutter analyze
```

### Run Tests

```bash
flutter test
```

### Build for Windows

```bash
flutter build windows
```

## Project Structure

The repository uses a monorepo-style layout, with the music player application under `apps/player`.

```text
Nova-Music/
└── apps/
    └── player/
        ├── lib/
        │   ├── app/
        │   ├── controllers/
        │   ├── core/
        │   ├── features/
        │   ├── models/
        │   ├── providers/
        │   ├── repositories/
        │   ├── services/
        │   └── widgets/
        ├── test/
        └── pubspec.yaml
```

*The exact files and directories may vary as development continues.*

## Contributing

Contributions, bug reports, and feature suggestions are welcome.

1. Fork the repository.
2. Create a branch for your changes.
3. Make and test your changes.
4. Submit a pull request describing your improvements.

Please run `flutter analyze` and relevant tests before submitting changes.

## Roadmap

Potential areas for continued development include:

- Further playback and crossfade refinements
- Improved lyrics support and synchronization
- Search and library usability improvements
- Additional personalization options
- Performance, accessibility, and responsive UI improvements

## License

No license has been specified here. Until a license is added to the repository, please contact the repository owner regarding permissions to use, modify, or redistribute the project.

## Author

**Abhinav R**

GitHub: [@abhinavrejio](https://github.com/abhinavrejio)

---

*Nova Music — Your music, your experience.*
