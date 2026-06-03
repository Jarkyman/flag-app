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

// FIXME: vi har ny hjemmeside og "flagsgame.epizy" er nu "https://hartvigsolutions.com/#flags-game" og med "/download" til sidst, så får man download linket, som før var /app
Og så er kredits emailen også forkert flags@hartvigsolutions.com kan bruges.

// TODO: Se på animationen af navigering, hvor vi naviger op fra budnen, så går den adnen skærm ud til siden og det ser undelrigt ud i vores animation. Den nye side skal bare komme op fra budnen og lukke ned mod bunden igen. tror det er settings og store der gør det. 

// TODO: Popup design skal rænkes, det kan godt blive lidt pænere. Language popup design skal blive pænere. Hjælpe popup design skal blive pænere, med lidt padding.