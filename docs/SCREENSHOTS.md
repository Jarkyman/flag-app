# Store screenshots

Store screenshots are captured with the dedicated Flutter entrypoint
`lib/main_screenshots.dart`. It keeps the normal release entrypoint untouched.

Screenshot mode:

- hides the status bar and bottom system navigation;
- does not initialize or load banner, interstitial, or rewarded ads;
- skips the ad-consent form;
- does not initialize Firebase Analytics, RevenueCat, Game Center, Play Games,
  or cloud save;
- keeps local emulator progress, language, and settings between launches, so a
  scene can be staged once and photographed in both store sizes.

Run it on a booted emulator or simulator:

```sh
flutter run --target lib/main_screenshots.dart --device-id <device-id>
```

Use a fresh emulator/simulator rather than a personal device. Screenshot mode
does not upload anything, but gameplay and settings still change that device's
local app data.

The completed English 2.0.0 sets are stored by store and device class:

- `docs/App Store/images/screenshots/iphone-6.9/` — 1320 × 2868 px;
- `docs/App Store/images/screenshots/ipad-13/` — 2064 × 2752 px;
- `docs/Play Store/images/screenshots/phone/` — 1440 × 3200 px;
- `docs/Play Store/images/screenshots/tablet/` — 1600 × 2650 px.

Each directory contains the same six scenes in store order:

1. Home
2. Word game
3. Completed word game with country information
4. Find the flag
5. Match flags
6. Which country

The current files are clean source captures in 8-bit RGBA PNG format. Flatten
the final store-marketing exports to RGB without transparency. Filenames are
lower-case and sortable, for example `01-home-en.png` and
`06-which-country-en.png`.
