# Firebase Analytics

## Project

- Firebase/Google Cloud project: `flags-game-quiz`
- Project number: `203533264391`
- Android app: `com.hartvig_develop.flags`
- iOS app: `com.Hartvig-Develop.flags`
- Flutter configuration: `lib/firebase_options.dart`

The existing Google Cloud project is reused so Play Games Services and Firebase
remain under the same project.

## Privacy defaults

Analytics is anonymous and enabled by default. Players can disable it with the
`Anonymous analytics` switch in Settings. Disabling collection also revokes
analytics storage consent and resets the Firebase Analytics installation data.

The app deliberately does not:

- set a Firebase user ID;
- send a Game Center or Play Games player ID;
- send names, email addresses, phone numbers, typed answers or country names;
- collect the Android advertising ID for Analytics;
- allow Analytics ad-personalisation signals;
- collect iOS IDFV for Analytics.

The only user properties are the selected app language and whether ads have
been removed. Firebase still creates its own pseudonymous app-instance ID while
anonymous analytics is enabled.

## Custom events

| Event | Purpose | Important parameters |
|---|---|---|
| `screen_view` | Navigation usage | Firebase screen name |
| `game_started` | Starts of games/word categories | `game_mode`, `continent` |
| `answer_submitted` | Correctness and streak analysis | `game_mode`, `correct`, `streak`, `used_hint`, `new_record`, `continent` |
| `game_finished` | Completed/abandoned quick-game runs | `game_mode`, `score`, `new_record`, `reason`, `continent` |
| `continent_selected` | Continent-filter usage | `game_mode`, `continent` |
| `hint_used` | Hint balance and usefulness | `game_mode`, `hint_type`, `cost` |
| `level_completed` | Word-level progression | `category`, `level`, `completion_method`, `first_completion` |
| `rewarded_ad_completed` | Rewarded-ad value | `placement` |
| `purchase_completed` | Successful shop conversion | `product_id` |
| `purchase_failed` | Non-cancelled purchase failures | `product_id`, stable error reason |
| `game_services_auth` | Game Center/Play Games health | `platform`, `status`, `source` |
| `game_services_overlay` | Native overlay usage | `platform`, `overlay` |

Event parameters are limited to stable enums, booleans and numbers. The
analytics controller strips known personal-data parameter names, limits string
length and catches SDK errors so analytics can never interrupt gameplay.

## Verification

Unit tests use a fake analytics gateway:

```sh
flutter test test/controllers/analytics_controller_test.dart
```

Before a release, run the app with Firebase Analytics debug mode and verify the
events in Firebase Console > Analytics > DebugView. Normal aggregate reports can
take longer to appear than DebugView.

Android debug mode:

```sh
adb shell setprop debug.firebase.analytics.app com.hartvig_develop.flags
```

Disable it afterwards:

```sh
adb shell setprop debug.firebase.analytics.app .none.
```

For iOS, add `-FIRDebugEnabled` to the Runner scheme launch arguments while
testing and remove it again before release.

After the first production/debug events have populated the Analytics property,
register the important event parameters as GA4 Custom Definitions. Start with
`game_mode`, `continent`, `hint_type`, `completion_method`, `reason` and
`category`, plus the user properties `app_language` and `ads_removed`. This is
required for convenient use in GA4 reports and Explorations; the raw events are
still collected before those definitions exist.
