# Opsætning i App Store Connect og Google Play Console

App-koden er færdig, men platformkomponenterne skal eksistere i de to konsoller,
før login, achievements og leaderboards kan fungere på rigtige konti.

## Apple Game Center

### Allerede konfigureret (2026-07-11)

- Game Center-siden er aktiveret for App Store Connect-appen `6443707640`.
- De tre globale `All`-leaderboards er oprettet som klassiske leaderboards med
  heltal, Best Score og High to Low. `Find Flag — World` er standard.
- Alle tre leaderboards har dansk og engelsk lokalisering samt Apple-billeder.
- Alle 23 achievements er oprettet med de permanente `appleId`-værdier,
  katalogets point og `Achievable More Than Once = No`.
- Alle 23 achievements har dansk og engelsk titel, før-/efterbeskrivelse og
  Apple-billeder.
- De tre perfekte gennemløb er markeret `Hidden = Yes`; de øvrige 20 er synlige.
- App Store Connect viser `3` leaderboards og `23` achievements med status
  `Prepare for Submission`. Achievement-totalen er 915 af 1.000 point.
- Intet er tilføjet til review eller en appversion endnu. Det sker først efter
  sandbox-test og sammen med den næste release.
- App-koden har nu iCloud Documents-entitlements for containeren
  `iCloud.com.Hartvig-Develop.flags`. Containeren skal stadig oprettes/tilknyttes
  App ID'et i Apple Developer, og provisioning profiles skal regenereres.

1. Åbn appen med bundle-ID `com.Hartvig-Develop.flags` i App Store Connect.
2. Aktivér Game Center for appen. Xcode-projektets entitlement er allerede sat.
3. Opret de tre leaderboards fra `leaderboards/catalog.json`:
   - brug `appleId` præcist som skrevet;
   - classic, high-to-low, heltal og ingen reset;
   - brug navne/beskrivelser fra `localizations/`;
   - upload billeder fra `leaderboards/icons/apple/`.
4. Opret alle 23 achievements fra `achievements/catalog.json`:
   - brug `appleId`, `points`, `hidden` og `repeatable` præcist;
   - brug titel, før-beskrivelse og efter-beskrivelse fra `localizations/`;
   - upload det tilsvarende billede fra `achievements/icons/apple/`.
5. Tilføj komponenterne til den næste appversion og indsend dem til review.
6. Test med en Sandbox Apple Account på en rigtig enhed eller simulator med
   Game Center-login.
7. Aktivér iCloud capability med **iCloud Documents**, vælg containeren
   `iCloud.com.Hartvig-Develop.flags`, og kontrollér at den nye provisioning
   profile indeholder containeren. Spilleren skal også være logget ind på
   iCloud med iCloud Drive slået til.

Apple-ID'erne er permanente, når komponenterne er oprettet. Ret derfor ikke
`appleId` i kataloget bagefter.

## Google Play Games Services

### Allerede konfigureret (2026-07-11)

- Google Cloud-/Play Games-project: `flags-game-quiz`
- Numerisk project ID: `203533264391`
- OAuth support- og kontaktmail: `support@hartvigsolutions.com`
- OAuth audience: External, In production
- OAuth scopes: `games`, `games_lite` og `drive.appdata`
- Android package: `com.hartvig_develop.flags`
- Play App Signing SHA-1: `7E:D3:80:AA:2D:AE:A7:68:E7:DB:27:95:D1:BF:20:1B:8C:63:AC:E6`
- Play App Signing OAuth client ID:
  `203533264391-mrov90ddlh34s411f2l2h6485q5fo99u.apps.googleusercontent.com`
- Lokal debug SHA-1: `EC:79:24:FE:7E:7C:F3:2D:4C:2F:DB:2A:65:54:25:06:52:8B:6E:7A`
- Project ID'et er indsat i `android/app/src/main/res/values/games-ids.xml`.
- `games_services` 5.1.0 trækker
  `com.google.android.gms:play-services-games-v2:21.0.0` ind i Android-buildet.
  Play Console markerer først SDK-trinnet som færdigt, når en build med denne
  dependency er uploadet og registreret som en production APK/AAB.
- Production AAB er bygget og verificeret lokalt på
  `build/app/outputs/bundle/release/app-release.aab`; bundlen indeholder
  `base/root/play-services-games-v2.properties`.
- Alle 23 achievements er oprettet som drafts i Play Console med de engelske
  tekster, Google-ikonerne, korrekte steps/point og tre skjulte achievements.
  Play Console viser `1 - 23 of 23`, `915 of 2,000 points used` og
  `Ready to publish to everyone` for alle 23.
- Alle 23 genererede achievement-ID'er er skrevet tilbage til
  `achievements/catalog.json`.
- De tre globale `All`-leaderboards er oprettet som drafts med Number/0
  decimaler, Largest first, tamper protection og Google-ikoner. Play Console
  viser `1 - 3 of 3` og `Ready to publish to everyone` for alle tre.
- Alle tre leaderboard-ID'er er skrevet tilbage til
  `leaderboards/catalog.json`. Alle 26 Google-ID'er er dermed udfyldt.
- Cloud-save-koden bruger Google Saved Games/Snapshots og sender et coverbillede
  med hver automatisk backup. Saved Games skal stadig slås til for spillet.

1. Åbn Play Games Services for pakken `com.hartvig_develop.flags` i Play Console.
2. Opret/tilknyt Play Games-projektet og OAuth credentials for både debug- og
   release-signaturernes SHA-1 fingerprints.
3. Kopiér det numeriske project ID til
   `android/app/src/main/res/values/games-ids.xml` i stedet for
   `000000000000`.
4. Opret de tre leaderboards fra `leaderboards/catalog.json` som high-to-low,
   heltal og uden reset. Upload `leaderboards/icons/google/*.png`.
5. Opret alle 23 achievements fra `achievements/catalog.json`:
   - `standard` oprettes som standard; `incremental` med katalogets `steps`;
   - brug katalogets `points` og `hidden`;
   - upload `achievements/icons/google/*.png`;
   - brug `description` fra platformslokaliseringen. Google bruger ikke Apples
     separate earned description.
6. Kopiér hvert genereret achievement-/leaderboard-ID til det tilsvarende
   `googleId`-felt i katalogerne. Appen aktiverer først Android-integrationen,
   når alle 26 ID'er er udfyldt, så en halv konfiguration ikke kan ramme spillere.
7. Tilføj testkonti, publicér Play Games Services-konfigurationen og test med en
   build signeret med en SHA-1, der er registreret i credentials.
8. Gå til **Grow users > Play Games Services > Setup and management >
   Configuration**, vælg **Edit properties**, slå **Saved Games** til og gem.
   Google oplyser, at aktivering kan tage op til 24 timer.

Play Console kan eksportere en XML-fil via **Get resources**. Project ID'et kan
kopieres direkte til `games-ids.xml`; de øvrige værdier kopieres til katalogernes
`googleId`-felter, fordi Flutter-laget sender ID'erne ved runtime.

## Verifikation efter ID-opsætning

1. Kør `flutter analyze` og `flutter test`.
2. Åbn Game services fra Home og kontrollér status `Connected`.
3. Åbn begge native overlays.
4. Få ét korrekt træningssvar og kontrollér `First Flag`.
5. Sæt en ny `All`-rekord og kontrollér det rigtige leaderboard.
6. Vælg et kontinent og kontrollér, at scoren ikke rammer et online leaderboard.
7. Log ud/afvis login og kontrollér, at gameplay og lokal tracking fortsætter.
8. Ændr lokal progression, vent på autosave-statussen i Settings, og gendan
   derefter backup'en efter endnu en lokal ændring.
9. Gentag restore på en anden enhed med samme platformkonto, og kontrollér
   levels, hints, alle lokale rekorder og lifetime-tællere.

Officielle guides:

- [Flutter: achievements og leaderboards](https://docs.flutter.dev/cookbook/games/achievements-leaderboard)
- [Apple: Game Center-komponenter](https://developer.apple.com/help/app-store-connect/configure-game-center/overview-of-configuring-game-center/)
- [Apple: Gem spildata i iCloud](https://developer.apple.com/documentation/gamekit/saving-the-player-s-game-data-to-an-icloud-account)
- [Google: Play Games Services setup](https://developer.android.com/games/pgs/console/setup)
- [Google: Aktivér Saved Games](https://developer.android.com/games/pgs/console/enable-features)
