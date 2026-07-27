# TODO

Kun aktive og fremtidige opgaver. Afsluttede opgaver arkiveres ikke her.

## Version 2.1.0

// TODO {S} [release, app-store, play-store, version-2.1.0] (H): Monitorér review og udgivelse af Android `2.1.0+29` og iOS `2.1.0+30`. Gennemfør stadig notification-smoketest på fysisk iPhone og Android som opfølgning; emulator-testen er grøn, men fysisk levering er ikke verificeret.

// TODO {S} [marketing, video, app-store, play-store] (M): Producer og upload en kort store-video, der viser Home, Daily Challenge, flag, landkort og våbenskjolde i den eksisterende 2.0-kampagnestil.

## Toolchain og dependencies

// TODO {S} [android, google-play, policy, release] (H): Opdatér appen til at targete Android 16 / API 36 eller højere og udgiv et nyt production-build senest 31. august 2026. Det nuværende højeste build targeter API 35; efter deadlinen blokerer Google Play nye appopdateringer. Verificér især notifikationer, Play Games, køb, annoncer og cloud save, og bekræft bagefter at [policy-sagen](https://play.google.com/console/u/0/developers/6988786543080092848/app/4972476568011111729/policy-center/issues/4987030206078622510/details) er ryddet.

// TODO {M} [android, flutter, kotlin, maintenance] (M): Migrér Android-projektet og kompatible plugins til Flutters Built-in Kotlin, fjern `android.builtInKotlin=false`, og aktivér den nye Gradle DSL, når plugin-økosystemet understøtter det. Verificér køb, annoncer, Firebase, e-mail, lyd og deling med release-build og fysiske enheder.

// TODO {M} [ios, flutter, spm, maintenance] (M): Migrér det resterende iOS-projekt fra CocoaPods til ren Swift Package Manager, når 2.0.0 er stabil. Bevar StoreKit-testscheme, Game Center, production-iCloud og cloud-save-entitlements, og verificér en eksporteret App Store-IPA efter migrationen.

// TODO {M} [dependencies, maintenance] (M): Lav en kontrolleret dependency-opgradering efter 2.0.0, især Firebase 4/Analytics 12, Google Mobile Ads 9 og Flutter Email Sender 10. Opgradér én SDK-gruppe ad gangen og kør analyzer, alle tests, køb/ads/cloud-smoketest samt begge release-builds mellem grupperne.

// TODO {S} [ci, github, quality] (M): Tilføj GitHub Actions, der på pull requests kører `flutter analyze`, hele testpakken, JSON-/lokaliseringsintegritet og mindst en Android release-build med den committed `pubspec.lock`. Signing-secrets må aldrig ligge i repositoryet.

## Kvalitet efter release

// TODO {M} [firebase, crashlytics, privacy] (M): Overvej Firebase Crashlytics til anonyme crash- og non-fatal-rapporter, så produktionsfejl som OOM, billeddecode og platform-login kan opdages. Opdatér Analytics-opt-out, App Privacy og Data Safety før aktivering.

// TODO {M} [performance, app-size, assets] (M): Sammenlign App Stores behandlede buildstørrelse for 2.1.0 med 2.0.2. Play Console viser allerede 82,3 MB device-download, 48,3 MB mindre end den forrige release, efter at 977 billed-assets er konverteret lossless til WebP.

// TODO {M} [accessibility, ui, localization] (M): Lav en samlet accessibility-gennemgang med VoiceOver/TalkBack, stor tekst, kontrast, reduced motion og touch targets på Home, menuer, popups og alle seks spiltilstande.

// TODO {M} [integration-test, startup, cloud-save, purchases] (M): Tilføj få højværdifulde integration-smoketests for offline appstart, cloud-restore før autosave og købsgendannelse. Testene skal dække reelle regressionsrisici og ikke duplikere de eksisterende 485 unit-/widgettests.

// TODO {S} [analytics, product] (L): Gennemgå 2.0.0-data efter nogle ugers reel brug: frafald pr. skærm/spil, kontinentvalg, hintbrug, adfærd før køb og crashfri brug. Brug resultaterne til at prioritere 2.1 i stedet for at gætte.

## Idéer til senere versioner

// TODO {M} [game, learning] (L): Overvej et valgfrit “mine svære lande”-spil, der samler de lande, spilleren oftest svarer forkert på, uden at ændre eksisterende records og leaderboards.

// TODO {S} [sharing, growth] (L): Overvej et pænt, lokaliseret resultatkort til deling efter en ny rekord eller et achievement, så appen kan få organisk reach uden betalt markedsføring.
