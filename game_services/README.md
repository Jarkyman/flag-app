# Game Center og Google Play Games Services

Denne mappe er projektets source of truth for leaderboards, achievements,
lokaliseringer og platformenes billedaktiver. Platformkomponenterne skal oprettes
ud fra katalogerne her; genererede ID'er fra Google Play Console skrives derefter
tilbage i katalogerne.

## Besluttet scope

- Tre klassiske high-to-low leaderboards, ét for hvert af spillene på Home,
  samt et dagligt low-to-high tidsleaderboard til Daily Challenge.
- Kun spil med kontinentfilteret `All` må indsende scores online.
- 23 achievements: 20 synlige og tre skjulte perfekte gennemløb.
- Den aktuelle app-pulje er 197 lande: 193 FN-medlemmer, Vatikanstaten,
  Palæstina, Taiwan og Kosovo. Rådata har 250 land/territorieposter, mens
  `CountryController.removeUnUsed()` beholder landene i `continents.json`.
- De seks komplette achievements er konfigureret med 197 trin i kataloget,
  alle ni platformstekster samt de endnu ikke udgivne komponenter i App Store
  Connect og Play Console. Der kræves ingen migration af live
  achievement-progress.
- Apple-point i alt: 915 af de tilladte 1.000.
- Gameplay virker normalt uden login eller netværk; lokal tracking fortsætter,
  og gemt progress synkroniseres ved næste succesfulde login.
- Appen har versionsstyret cloud-autosave med beskyttet backup-historik. Ændringer
  samles med debounce og flushes, når appen går i baggrunden. Ved opstart hentes
  cloud-save færdigt på splash-skærmen, før Home kan åbnes. Manglende remote-data
  udløser aldrig en tom upload under launch, og før første autosave foretages en
  ny remote-check.
- Den oprindelige `flags-game-cloud-save-v1` er nu read-only. Nye saves skifter
  mellem to v2-slots, så den aktive og den forrige backup ikke overskrives på
  samme tid. En tom backup vælges aldrig over en backup med reel progression.
  Settings viser status og tilbyder en bekræftet restore.
  Backup'en indeholder levels, alle lokale rekorder, hints og lifetime-tællere,
  men ikke køb; RevenueCat er fortsat source of truth for entitlements.

## Mapper

- `achievements/catalog.json`: stabile nøgler, platform-ID'er, kriterier,
  progression, point, backfill og ikonfil.
- `leaderboards/catalog.json`: de tre online high scores, Daily Challenge og
  regler for submit.
- `localizations/`: platformstekster til alle ni understøttede sprog. Status og
  platformenes locale-forskelle er beskrevet i `status.json`.
- `*/icons/master/`: 1024 x 1024 masterbilleder.
- `*/icons/apple/`: Apple-eksporter i 1024 x 1024.
- `*/icons/google/`: Google-eksporter i 512 x 512.
- `icon_briefs.md`: motiv og farver for hvert billede.

## Implementerede regler

1. Login er valgfrit og må aldrig blokere spillet.
2. En leaderboard-score indsendes kun, når spilleren spiller med `All`.
3. Ved login indsendes alle tre gemte `All`-rekorder, så offline rekorder syncer.
   Daily Challenge indsendes separat som dagens afsluttede tid.
4. Best-streak- og level-achievements backfilles fra gemt data.
5. Lifetime-tællere kan ikke udledes sikkert fra den nuværende app og begynder
   derfor ved den version, der introducerer tællerne.
6. Progression må kun bevæge sig fremad. En lavere rapporteret værdi må aldrig
   overskrive tidligere achievement-progress.
7. Google-ID'er genereres i Play Console og skrives tilbage i katalogerne.
   Alle 23 achievement-ID'er og fire leaderboard-ID'er er udfyldt.
   Apple-ID'erne i kataloget behandles som permanente.

## Platformkrav

- Apple achievement-billeder: 1024 x 1024, JPG eller PNG, RGB.
- Google achievement- og leaderboard-ikoner: 512 x 512, JPG eller PNG.
- Ikonerne er tekstfrie, så samme billede kan bruges på alle sprog.
- Google kræver samme achievement-ikon på tværs af lokaliseringer.
- Apple leaderboard-billeder er valgfrie, men medtages for et ensartet udtryk.

Officiel dokumentation:

- [Apple achievements](https://developer.apple.com/help/app-store-connect/reference/game-center/achievements/)
- [Apple leaderboards](https://developer.apple.com/help/app-store-connect/reference/game-center/leaderboards/)
- [Google achievements](https://developer.android.com/games/pgs/achievements)
- [Google leaderboards](https://developer.android.com/games/pgs/leaderboards)

## Status

App-integrationen bruger `games_services` 5.1.0 og er implementeret med:

- valgfrit login efter splash-load;
- automatisk backfill af eksisterende rekorder og level-progress;
- permanente lifetime-tællere fra denne version og frem;
- absolut achievement-progress på iOS og delta-sync mod Googles remote steps;
- leaderboard-submit udelukkende fra kontinentfilteret `All`;
- native achievement- og leaderboard-overlays fra den nye Game services-side;
- Game Center-entitlement og Play Games-manifestkonfiguration;
- unit tests af katalog, alle 23 regler, offline tracking og `All`-afgrænsning.
- remote-first autosave og launch-sync via Google Saved Games og GameKit/iCloud samt
  eksplicit bekræftelse før en manuel restore overskriver lokal progression;
- schema-validering før restore og automatisk backfill til achievements og
  leaderboards efter en succesfuld restore.

De 23 achievements, tre `All`-leaderboards og Daily Challenge-leaderboardet er
oprettet i både App Store Connect og Play Console. Alle komponenter har nu
platformstekster på dansk,
engelsk, tysk, spansk, fransk, norsk, brasiliansk portugisisk, europæisk
portugisisk og svensk. Apple viser alle 26 komponenter som `Ready for Review` i
den eksisterende draft, og Google-lokaliseringerne er gemt som drafts. Intet blev
indsendt eller udgivet som en del af lokaliseringsarbejdet. Alle billeder og 26
genererede Google-ID'er er fortsat koblet til katalogerne. Se `CONSOLE_SETUP.md`.

Cloud-save-koden og iOS-entitlements er implementeret. Før enhedstest skal
Saved Games aktiveres i Play Console, og iCloud-containeren skal registreres hos
Apple samt indgå i appens provisioning profile. Se `CONSOLE_SETUP.md`.
