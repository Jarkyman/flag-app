# Flag App - TODO & Refactoring Tasks

Her er en liste over ting, der bør opdateres, rettes eller forbedres i appen, formateret efter dine ToDoKanban-regler.

## 📦 Pakker & Dependencies
// DONE {M} [dependencies, pubspec] (H): Opdater alle forældede pakker baseret på din `pub upgrade` liste (f.eks. audioplayers, google_fonts, share_plus, purchases_flutter).
// DONE {S} [dependencies, sdk] (M): Opgrader Dart SDK constraint i `pubspec.yaml` til at understøtte Dart 3.0+ for at få adgang til nyere sprogfunktioner som records og pattern matching.

## 🎨 UI & Design
// DONE {M} [ui, design] (H): Opdater appens overordnede design til et mere moderne udtryk med bedre farvepaletter i stedet for standardfarver.
// DONE {M} [ui, theme] (M): Opdater `ThemeData` i `main.dart` til at bruge Material 3 (`useMaterial3: true`) og en moderne `ColorScheme`.
// DONE {S} [ui, animation] (H): Tilføj flere micro-animationer, f.eks. når man gætter rigtigt/forkert (shake-effekt, konfetti) og blødere side-overgange.
// DONE {C} [ui, splash] (M): Udskift den manuelle `splash_page.dart` med pakken `flutter_native_splash` for en mere flydende og lynhurtig opstart uden hardcodede ventetider.

## 🏗️ Arkitektur & Kodekvalitet
// DONE {M} [architecture, init] (H): Refaktorér indlæsningen af data i `splash_page.dart`. Lige nu bruger du sekventielle `await`, hvilket gør opstarten unødigt langsom. Brug `Future.wait` til at køre uafhængige requests parallelt.
// DONE {M} [architecture, getx] (M): Undgå at kalde `Get.find<Controller>()` direkte inde i `build`-metoden (som set i `PlayPage`). Det er bedre at bruge `GetView`, `GetBuilder` eller hente controlleren én gang.
// DONE {S} [logic, controllers] (M): I `CountryController.generateCountries` er der `while`/`for` loops til at finde forkerte svarmuligheder, som potentielt kan fejle eller køre i lang tid, hvis der ikke er nok lande i kontinentet. Optimer denne logik.
// DONE {S} [error_handling, repo] (M): Tilføj fejlhåndtering i `CountryRepo.readCountries`. Hvis en valgt oversættelse (f.eks. `assets/json/xx/countries.json`) ikke findes, bør koden have en automatisk fallback til engelsk (`en`).
// DONE {C} [code_quality, linting] (L): Aktiver strammere linting-regler via `analysis_options.yaml` (f.eks. `flutter_lints` 6.0.0) og ryd op i eventuelle warnings.


## App optimeringer
// DONE: updater alle dependencis til det nyese, se "flutter pub outdated" for at se hvilke der er forældede.
// DONE: fix 188 lint problemer i kodden, flutter analyze --fix og fix selv.

// DONE: vi har ny hjemmeside og "flagsgame.epizy" er nu "https://hartvigsolutions.com/#flags-game" og med "/download" til sidst, så får man download linket, som før var /app
Og så er kredits emailen også forkert flags@hartvigsolutions.com kan bruges.

// DONE: Se på animationen af navigering, hvor vi naviger op fra budnen, så går den adnen skærm ud til siden og det ser undelrigt ud i vores animation. Den nye side skal bare komme op fra budnen og lukke ned mod bunden igen. tror det er settings og store der gør det. 

// DONE: Popup design skal rænkes, det kan godt blive lidt pænere. Language popup design skal blive pænere. Hjælpe popup design skal blive pænere, med lidt padding.

## 🧪 Tests
// DONE {C} [test, hints, bomb] (H): Tilføj en udtømmende unit-testmatrix for bomben og korrekt-bogstav-hintet med 18/27/36 bogstaver, svar- og dubletkombinationer, linjeskift, bindestreg, persistence og kendte regressioner.
// DONE {C} [test, hints] (H): Lav automatiske tests af de resterende hint-flows. Dæk især korrekt svar/finish og 50/50 samt for få hints, gentagne tryk, disabled state, fratræk af hints, rewarded-ad-belønning præcis én gang og gemt state efter genåbning.


## Ekstra opgaver (ikke prioriteret endnu)

// DONE: Lav mulighed for at vælge kontinent i trænings spillene, så man kun ser lande fra det kontinent. Det kunne være en menu i top baren, eller andet?

// DONE: ryd lidt op i design på popups, så de ser pænere ud. F.eks. hjælpe popup, language popup, settings popup.

// DONE: Remove "X" button from wrong guess popup, it dosent do anything.

// DONE: Add achievements og leaderboards med Apple Game Center og Google Play Games Services, lokal/offline tracking, backfill og native overlays.

// DONE: Achievements er backwards compatible for gemte highscores og level-progress. Lifetime correct-answer tællere starter fra release-versionen.

// DONE: Opret de 23 achievements og tre leaderboards i Google Play Console, og indsæt Googles 26 genererede ID'er samt project ID.

// DONE: Opret de 23 achievements og tre leaderboards i App Store Connect med dansk/engelsk lokalisering, billeder, 915 point og tre skjulte achievements.

// DONE {M} [game] (H): Flyt Aserbajdsjan fra Europa til Asien i alle ni sprogassets.

// DONE {M} [game] (H): Fjern teksten i toppen af træningsspillene, så headeren kun viser navigation, kontinent og hints.

// DONE {M} [game] (H): Behold bannerreklamen i bunden af word-siden efter korrekt svar, og reservér bannerets højde før indlæsning, så bogstaverne ikke flytter sig, når reklamen vises.

// DONE {M} [game] (M): Giv det flyvende bogstav i word-animationens root-overlay en transparent Material-kontekst, så Flutters gule fallback-understregning ikke vises.

// DONE {M} [game] (M): Erstat swipe-pakkens fejlbehæftede positionsgenbrug på word-siden med en lokal vandret dragmåling og minimumsafstand, så tryk aldrig navigerer til næste eller forrige opgave.

// DONE {M} [game-services] (H): Implementér valgfrit Game Center-/Play Games-login, online All-highscores, achievement-sync fra level-progress og lifetime correct-answer tællere, backfill af gemte lokale scores/levels samt native achievement- og leaderboard-overlays.

// DONE {M} [game-services, cloud-save] (H): Tilføj remote-first launch-sync før Home, versionsstyret autosave med debounce og app-pause-flush samt read-only legacy-backup og to roterende autosave-slots. En tom førstegangsstate må aldrig uploades under launch eller vælges over reel progression. Settings viser status og bekræftet manuel restore. RevenueCat-køb gemmes ikke i backup'en.

// TODO {S} [ios, game-center, cloud-save, release] (H): Opret eller tilknyt iCloud-containeren `iCloud.com.Hartvig-Develop.flags` til appens App ID i Apple Developer, aktivér iCloud Documents og regenerér provisioning profiles. Kontrollér derefter, at release-signeringen indeholder de nye iCloud-entitlements.

// TODO {S} [android, play-games, cloud-save, release] (H): Aktivér Saved Games i Play Console og kontrollér, at funktionen er slået til for production.

// DONE {M} [ads, privacy, ump] (H): Tilføj en dynamisk "Ad privacy choices"-række i Settings, som kun er synlig og interaktiv, når Google UMP returnerer `PrivacyOptionsRequirementStatus.required`. Brug Googles native privacy-options-form, genberegn status efter formularen og brug det anbefalede consent-flow ved hver appstart.

// DONE {M} [game-services, localization] (H): Omtal konsekvent Find flag, Match flags og Which country som spil frem for training, practice eller træning i apptekster, Credits og Game Services-lokaliseringer. Bevar interne persistence- og platform-ID'er for kompatibilitet.

// DONE {M} [game-services, release] (H): Tilføj Game Center-komponenterne til næste iOS-version, publicér Play Games Services-projektet, upload release-builds og test begge platforme med sandbox/testere før release.

// TODO {M} [game-services, localization] (M): Oversæt og review achievement-/leaderboardteksterne til de resterende syv platformslokaliseringer efter dansk og engelsk.

// DONE {M} [analytics, firebase] (H): Implementér Firebase Analytics efter samme setup som i de andre apps. Track centrale, ikke-personhenførbare events for skærmvisninger, spilstart/-slut, korrekte/forkerte svar, streak/ny rekord, kontinentfilter, hintbrug og Game Center/Play Games-flow. Opdatér også privacy-/consent-konfiguration og test events på både Android og iOS.

// TODO {S} [analytics, privacy, release] (H): Opdatér App Store App Privacy og Google Play Data Safety før 2.0.0, så anonym Firebase Analytics deklareres som brugsdata/appinteraktion til analytics, ikke knyttet til brugerens identitet og ikke brugt til tracking.

// TODO {S} [analytics, reports] (M): Når de første events er synlige i Firebase, registrér de vigtigste parametre som GA4 Custom Definitions (mindst `game_mode`, `continent`, `hint_type`, `completion_method`, `reason`, `category`, `app_language` og `ads_removed`), så de kan bruges direkte i rapporter og Explorations.

// TODO {M} [release, version-2.0.0] (H): Klargør version 2.0.0, når iCloud/Saved Games-platformopsætningen er afsluttet, de resterende platformstekster er oversat/reviewet, Firebase Analytics er verificeret, og release-builds/store-metadata er gennemgået.
