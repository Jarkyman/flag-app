# TODO

Kun aktive og fremtidige opgaver. Afsluttede opgaver arkiveres ikke her.

## Version 2.0.2

// TODO {S} [release, app-store, play-store, version-2.0.2] (H): Byg, signér og upload cloud-save-hotfixet `2.0.2+27` til App Store Connect og Play Console. Tilknyt korte release notes om den mere pålidelige automatiske backup og restore ved opstart, gennemgå platformenes sidste valideringer og udgiv til 100 % efter review.

## Toolchain og dependencies

// TODO {M} [android, flutter, kotlin, maintenance] (M): Migrér Android-projektet og kompatible plugins til Flutters Built-in Kotlin, fjern `android.builtInKotlin=false`, og aktivér den nye Gradle DSL, når plugin-økosystemet understøtter det. Verificér køb, annoncer, Firebase, e-mail, lyd og deling med release-build og fysiske enheder.

// TODO {M} [ios, flutter, spm, maintenance] (M): Migrér det resterende iOS-projekt fra CocoaPods til ren Swift Package Manager, når 2.0.0 er stabil. Bevar StoreKit-testscheme, Game Center, production-iCloud og cloud-save-entitlements, og verificér en eksporteret App Store-IPA efter migrationen.

// TODO {M} [dependencies, maintenance] (M): Lav en kontrolleret dependency-opgradering efter 2.0.0, især Firebase 4/Analytics 12, Google Mobile Ads 9 og Flutter Email Sender 10. Opgradér én SDK-gruppe ad gangen og kør analyzer, alle tests, køb/ads/cloud-smoketest samt begge release-builds mellem grupperne.

// TODO {S} [ci, github, quality] (M): Tilføj GitHub Actions, der på pull requests kører `flutter analyze`, hele testpakken, JSON-/lokaliseringsintegritet og mindst en Android release-build med den committed `pubspec.lock`. Signing-secrets må aldrig ligge i repositoryet.

## Kvalitet efter release

// TODO {M} [firebase, crashlytics, privacy] (M): Overvej Firebase Crashlytics til anonyme crash- og non-fatal-rapporter, så produktionsfejl som OOM, billeddecode og platform-login kan opdages. Opdatér Analytics-opt-out, App Privacy og Data Safety før aktivering.

// TODO {M} [performance, app-size, assets] (M): Brug Play Consoles faktiske device-downloadstørrelse og App Stores buildstørrelse efter 2.0.0 til at finde de største assetgrupper. Undersøg tabsfri WebP/bedre PNG-komprimering uden at forringe flag, våbenskjolde, offline-spil eller billedcache.

// TODO {M} [accessibility, ui, localization] (M): Lav en samlet accessibility-gennemgang med VoiceOver/TalkBack, stor tekst, kontrast, reduced motion og touch targets på Home, menuer, popups og alle seks spiltilstande.

// TODO {M} [integration-test, startup, cloud-save, purchases] (M): Tilføj få højværdifulde integration-smoketests for offline appstart, cloud-restore før autosave og købsgendannelse. Testene skal dække reelle regressionsrisici og ikke duplikere de eksisterende 485 unit-/widgettests.

// TODO {S} [analytics, product] (L): Gennemgå 2.0.0-data efter nogle ugers reel brug: frafald pr. skærm/spil, kontinentvalg, hintbrug, adfærd før køb og crashfri brug. Brug resultaterne til at prioritere 2.1 i stedet for at gætte.

## Idéer til senere versioner

// TODO {M} [game, retention] (L): Overvej en lille daglig udfordring med samme lande for alle, en lokal streak og en delbar resultattekst uden persondata.

// TODO {M} [game, learning] (L): Overvej et valgfrit “mine svære lande”-spil, der samler de lande, spilleren oftest svarer forkert på, uden at ændre eksisterende records og leaderboards.

// TODO {S} [sharing, growth] (L): Overvej et pænt, lokaliseret resultatkort til deling efter en ny rekord eller et achievement, så appen kan få organisk reach uden betalt markedsføring.
