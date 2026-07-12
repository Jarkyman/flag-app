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

// FIXME {M} [game] (H): Aserbajdsjan står til at ligge i Eruopa, det deltvis rigtigt, men det er mest i asien, så vi skal have flyttet det til asien.

// FIXME {M} [game] (H): Fjern teksten i toppen af "trænings" spillene. Så der ikke står noget (fx "find flages")

// FIXME {M} [game] (H): på word siden, så skal vi have en reklame i bunden også efter man har gættet rigtigt. Og inden man har gættet skal vi have en usynlig boks som fylder reklamen, så bogstaverne ikke rykker sig nor reklamne popper ind og det ser pænere ud de er løftet lidt op. 

// FIXME {M} [game] (M): på word siden, når bogstaverne animerer op og ned, så kommer der en lille gul steg under, ved ikke om det kun er på debug, men tænker vi skal fixe det.

// TODO {M} [game-services] (H): Implementer Game Center og Play Games Services, for at "gemme" highscores, level-progress og lifetime correct-answer tællere, samt achievements og leaderboards. Implementér også backfill af scores og native overlays.

// TODO {M} [game-services, localization] (H): fjern ord som training, da jeg ikke syntes at de 3 spille modes på startskærmen skal hede trænings baner, find på noget andet så det bare lyder som et spil og ikke en træning.

// DONE {M} [game-services, release] (H): Tilføj Game Center-komponenterne til næste iOS-version, publicér Play Games Services-projektet, upload release-builds og test begge platforme med sandbox/testere før release.

// TODO {M} [game-services, localization] (M): Oversæt og review achievement-/leaderboardteksterne til de resterende syv platformslokaliseringer efter dansk og engelsk.

// TODO {M} [analytics, firebase] (H): Implementér Firebase Analytics efter samme setup som i de andre apps. Track centrale, ikke-personhenførbare events for skærmvisninger, spilstart/-slut, korrekte/forkerte svar, streak/ny rekord, kontinentfilter, hintbrug og Game Center/Play Games-flow. Opdatér også privacy-/consent-konfiguration og test events på både Android og iOS.

// TODO {M} [release, version-2.0.0] (H): Klargør version 2.0.0, når Android/iOS game-services er testet, de resterende platformstekster er oversat/reviewet, Firebase Analytics er verificeret, og release-builds/store-metadata er gennemgået.
