# Daily Challenge leaderboard setup

The app code submits the Daily Challenge result only when a leaderboard with
the key `leaderboard.daily_challenge` exists in
`game_services/leaderboards/catalog.json`.

The challenge occurrence changes every day at **07:00 UTC**. This matches
Google Play Games' fixed daily reset at UTC-7 and should also be used as the
start time for the Game Center recurring leaderboard.

## App Store Connect / Game Center

- Reference name: `Daily Challenge`
- Leaderboard ID: `flags.leaderboard.daily_challenge`
- Type: Recurring
- Start time: 07:00 UTC
- Duration: 24 hours
- Restart interval: 24 hours
- Score submission: Best score
- Sort order: Low to High
- Formatter: Elapsed Time (centisecond)

## Google Play Console / Play Games

- Name: `Daily Challenge`
- Ordering: Smaller is better
- Score format: Time duration
- Tamper protection: Enabled

Play Games automatically provides daily, weekly and all-time views. Its daily
view resets at 07:00 UTC. The app submits milliseconds to Google and converts
the same value to centiseconds for Game Center.

## Catalog entry

Both platform leaderboards were created on 2026-07-27. The production catalog
entry is:

```json
{
  "key": "leaderboard.daily_challenge",
  "appleId": "flags.leaderboard.daily_challenge",
  "googleId": "CgkIh8ycnPYFEAIQHA",
  "game": "daily_challenge",
  "appleScoreDivisor": 10,
  "icon": "daily_challenge.png"
}
```

The Google Play Games configuration is published. The Game Center leaderboard
is configured as recurring and localized in every supported app language; it
must be included with the 2.1.0 App Store review submission.

## Fairness scope

All players receive the same country codes, question order, answer order and
question types for a given occurrence. A wrong answer adds three seconds, and
the official attempt continues across app restarts. Platform tamper protection
should be enabled, but fully authoritative anti-cheat would require a server
that validates attempts.
