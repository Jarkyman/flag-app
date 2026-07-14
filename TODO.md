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
// DONE {S} [ui, safe-area, release] (H): Giv Home og de fælles menu-/spilheaders ekstra `Dimensions`-baseret luft under systemets øverste safe area, så settings-, tilbage-, hjælp- og hintknapper samt sidetitler ikke sidder for højt på notch-/Dynamic Island-enheder. Baggrunden forbliver edge-to-edge, og bundlayoutet ændres ikke.

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

// DONE {S} [ios, game-center, cloud-save, release] (H): iCloud-containeren `iCloud.com.Hartvig-Develop.flags` er tilknyttet appens App ID, iCloud Documents er aktiveret, og Xcode har genereret et nyt managed Store provisioning profile. En lokal App Store Connect-export bekræfter production-iCloud, `CloudDocuments` og den korrekte container i Release-signeringen.

// DONE {S} [android, play-games, cloud-save, release] (H): Saved Games er aktiveret og publiceret i Play Console. Play Games-konfigurationen viser `Published` og `Saved games enabled`, og Google Drive API er aktiveret.

// DONE {M} [ads, privacy, ump] (H): Tilføj en dynamisk "Ad privacy choices"-række i Settings, som kun er synlig og interaktiv, når Google UMP returnerer `PrivacyOptionsRequirementStatus.required`. Brug Googles native privacy-options-form, genberegn status efter formularen og brug det anbefalede consent-flow ved hver appstart.

// DONE {M} [game-services, localization] (H): Omtal konsekvent Find flag, Match flags og Which country som spil frem for training, practice eller træning i apptekster, Credits og Game Services-lokaliseringer. Bevar interne persistence- og platform-ID'er for kompatibilitet.

// DONE {M} [game-services, release] (H): Tilføj Game Center-komponenterne til næste iOS-version, publicér Play Games Services-projektet, upload release-builds og test begge platforme med sandbox/testere før release.

// DONE {M} [game-services, localization] (M): Oversæt og review achievement-/leaderboardteksterne til de resterende syv platformslokaliseringer efter dansk og engelsk. Alle ni sprog er gemt i både App Store Connect og Play Console; Apple-komponenterne er Ready for Review, og Google Play Games-projektets achievements, leaderboards samt lokaliserede navn og 2.0-beskrivelse er publiceret.

// DONE {M} [game-services, achievements, localization] (H): De seks komplette achievements er opdateret direkte fra 194 til 197 inden første Game Services-udgivelse: tre level-achievements og de tre skjulte perfekte All-streaks. Katalogets steps/triggers, alle ni platformstekster, tests samt værdierne i App Store Connect og Play Console er rettet. Der kræves ingen migration af eksisterende platformprogress, da achievements ikke er i produktion endnu.

// DONE {M} [analytics, firebase] (H): Implementér Firebase Analytics efter samme setup som i de andre apps. Track centrale, ikke-personhenførbare events for skærmvisninger, spilstart/-slut, korrekte/forkerte svar, streak/ny rekord, kontinentfilter, hintbrug og Game Center/Play Games-flow. Opdatér også privacy-/consent-konfiguration og test events på både Android og iOS.

// DONE {S} [analytics, privacy, settings] (H): Analytics er slået til som standard og kan slås fra permanent i Settings. Vis en lokaliseret bekræftelses-popup før opt-out, forklar kort at navn, e-mail og andre direkte identificerende oplysninger ikke indsamles, og at anonyme brugs- og spildata bruges til at forbedre appen. Opt-out stopper collection, tilbagekalder analytics-storage consent og nulstiller Firebase-installationsdata.

// DONE {S} [security, git, release] (H): Gennemgå alle ændrede og nye filer før det offentlige GitHub-commit. Bekræft at Firebase-mobilkonfigurationerne kun indeholder offentlige klientidentifikatorer, og at private nøgler, service accounts, client secrets, tokens, keystores, lokale stier og private mailadresser ikke committes. Udvid `.gitignore` med signing- og server-credential-formater.

// DONE {S} [analytics, privacy, release] (H): App Store App Privacy og Google Play Data Safety er opdateret før 2.0.0. Apple deklarerer Purchase History, Coarse Location, Device ID og Product Interaction til Analytics, ikke knyttet til brugerens identitet og ikke brugt til tracking. Google Play deklarerer App interactions som valgfrit indsamlet, ikke delt og kun brugt til Analytics; de eksisterende automatiske SDK-/appdeklarationer er bevaret. Apples label er publiceret, og Google Plays ændring er sendt til review.

// DONE {S} [analytics, reports] (M): De første app-events er synlige i Firebase/GA4, og alle otte vigtige parametre er registreret som GA4 Custom Definitions. `game_mode`, `continent`, `hint_type`, `completion_method`, `reason` og `category` er event-scoped; `app_language` og `ads_removed` er user-scoped. Dimensionerne kan bruges i rapporter og Explorations, når GA4's behandlingstid er gået.

// TODO {M} [release, version-2.0.0] (H): Klargør version 2.0.0, når iCloud/Saved Games-platformopsætningen er afsluttet, de resterende platformstekster er oversat/reviewet, Firebase Analytics er verificeret, og release-builds/store-metadata er gennemgået.

// DONE {M} [release, version-2.0.0] (H): Der er taget seks rene, engelske screenshots uden reklamer, statuslinje eller bundnavigation til hver af de fire store-enhedstyper: Android-telefon 1080×1920, Android-tablet 1600×2650, iPhone 6,9″ 1320×2868 og iPad 13″ 2064×2752. Alle 24 billeder er gemt som RGB-PNG uden alfa under de respektive `docs`-mapper.

// TODO {M} [release, play-store, version-2.0.0] (H): Lav et nyt feature graphic til Google Play for version 2.0.0.

// DONE {M} [android, play-points] (S): En etårig Play Points-kuponpromotion med 50% rabat på pointprisen og Tier 3-kuponværdi er oprettet og indsendt i Play Console.

// DONE {S} [assets, performance, release] (H): Alle 31 rasterassets over 1600 px er normaliseret til maks. 1600 px på længste side med bevaret aspect ratio og transparens: 10 flag, 20 våbenskjold og ét landekort. Unødvendig EXIF-/tekst-/tids-/DPI-metadata er fjernet fra hele rastersamlingen, mens farveinformation er bevaret; samlet fylder de 31 nedskalerede filer 155.404 bytes mindre end originalerne. Runtime-decodes har samme grænse, `Which country` og flag-bolden dekodes i visningsstørrelse, og Flutters LRU-billedcache beholder nyligt brugte billeder inden for et 48 MiB-budget uden at blive nulstillet ved navigation. Flutters standardgrænse på 1000 poster bevares kun som en praktisk irrelevant sikkerhedsgrænse. Regressionstests scanner alle rasterassets uden at dekode dem.

// DONE {S} [assets, performance, release] (H): Kør en afsluttende profile/release-stresstest på fysisk iPhone og Android: gennemse mange Guess/word-billeder i alle tre kategorier, skift sprog flere gange, spil alle tre quizmodes, forlad/genåbn levels og bekræft både hurtig cache-genvisning og stabil hukommelse uden OOM, manglende glyph-atlas eller synligt kvalitetstab.


// DONE {M} [debug, hints] (L): Den midlertidige debug-belønning på 9000 hints er fjernet. Rewarded-videoen og dens lokaliserede knaptekst giver igen 3 hints i både debug- og release-builds; en allerede optjent testsaldo ændres ikke.

// DONE {M} [game] (H): Fjern det animerede dotted world map fra de aktive spilleskærme, herunder de tre quizspil og Guess/word. Behold animationen på appens øvrige menu- og informationssider.

// DONE {M} [release, version-2.0.0] (H): Alle ni sprog i docs-mappen er opdateret til version 2.0.0 med ASO-optimerede App Store-beskrivelser, promotionstekster og keywords samt Play Store-beskrivelser. Teksterne dækker det nye design, 197 lande, de seks spiltilstande, kontinentfilter, hints, Game Center/Play Games Services, 23 achievements og tre globale leaderboards.

// DONE {M} [release, version-2.0.0] (H): `docs/changelog.txt` indeholder release notes til version 2.0.0 på alle ni sprog og holder sig under platformenes tekstgrænser.


// DONE {S} [android, purchases, release] (H): Opdatér RevenueCat før 2.0.0, så Google Plays SDK-advarsel for `com.revenuecat.purchases:purchases:10.6.1` ikke følger med i det nye build. `purchases_flutter` er opdateret fra 10.2.0 til 10.4.1, og Gradles `releaseRuntimeClasspath` er verificeret til native Android SDK 10.12.0. Den direkte non-subscription-produkt-test består, og `flutter analyze` er ren. Advarslen kan fortsat stå på den uforanderlige produktionsbuild `1.4.0+24`, men gælder ikke det kommende build.
