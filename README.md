# Study Buddy

Simple convenience application built in Flutter where flash cards are used for revision.

## Environment

- Flutter 1.22.4
- Android Studio 4.0

## Packages

- path_provider ^1.6.14 (for file I/O)
- provider ^4.3.2+2 (state management)
- intl ^0.16.1 (date/time formatting and parsing)
- charts_flutter ^0.9.0 (native Dart-based data visualization library)
- shared_preferences (persistence storage for options)
- sqflite ^1.3.0 (persistence storage for cards/decks/results)
- animations ^1.1.2 (front-end animations/transitions)
- flutter_launcher_icons ^0.8.0 (app icon generation purposes)
- image: ^2.1.19 (launcher_icon dependency)
- flutter_markdown: ^0.5.1 (markdown parser for changelog)
- flutter_local_notifications: ^3.0.2 (local push notifications for reminder)
- rxdart: ^0.25.0 (dart streams - for local_notif)

## Features

- [x] Decks to collate cards for revision
- [x] Tagging for decks
- [x] Revision sessions for deck and card scoring
- [x] Performance measurement for cards
- [x] Performance measurement for decks
- [x] Allow users to set their own performance thresholds
- [x] Dark mode
- [x] Frontend design and animations
- [x] Standard/Input-style revision modes
- [x] Changelogs
- [x] Local push notifications for reminder

## In progress
- [ ] Alignment of all widgets across different screen sizes 

## Licensing

This project is licensed under the MIT License - see the LICENSE.txt file for details.