# King Crab App Store teaser — QA notes

Deterministic DEBUG trailer driven by the live `KingCrabArena`, `MemoryGame` and `KingCrabPlayfield`. Fake gameplay is not used.

## Exports

| Format | File | Pixels | Duration |
| --- | --- | --- | --- |
| iPhone | `promo/king-crab-app-store-teaser-886x1920.mp4` | 886 × 1920 | ~19.9 s |
| iPad | `promo/king-crab-app-store-teaser-1200x1600.mp4` | 1200 × 1600 | ~20.3 s |

Both validated H.264 + AAC, portrait, decode-tested via `promo/validate_mp4.py`.
Release build succeeds (`xcodebuild -configuration Release`).

Render both with:

```
bash promo/render_trailer.sh
```

## Production systems reused

- Answer crabs, four-corner entry, walk duration, rush-after-clear
- Real `tap` → claw throw → sand projectile → impact → smash
- Character rigs: crab, elephant, bear, penguin
- `ReefPalette` character colouring of water/sand/reef
- Shell HUD, flying shell rewards, lives
- 2× `CarrierCrab` crossing + fetch
- Streak threshold 5, gold wave, streak celebration sway + raised claws
- Level completion hop and run-out
- App icon source `crab-2-zonder-alpha.png` (1024)
- Music `music_background.m4a` and production CAF effects

## Scripted state

- Start cards = 2, start streak = 3 (so 15 → 4, 56 → 5)
- Q1 `9 + 6 = ?` / 15, wrong 16, 14, 24
- Q2 `7 × 8 = ?` / 56, wrong 48, 49, 63 (two lower, one top)
- Q3 `35 − 7 = ?` / 28, wrong 21, 29, 35, gold from real streak
- Lanes locked by answer text (see `PromoScript.entryAssignment`)
- After 28, `promoFinishesAfterLast` ends the board with no fourth wave

## Known production-faithful timings

- Sand does not delete a crab: the crab keeps walking until `sandImpactDelay`
- Scoring the round happens when the last wrong crab is smashed (`rushLoneCorrectCrab`), then the correct crab runs in
- Gold Q3 therefore begins about 0.44 s after the Q2 clear, while 56 is finishing its delivery and the streak celebration is playing
- 2× crab duration is lengthened to ~10.4 s so it stays on screen from Bear through the streak; motion still uses `CarrierCrab`

## Visual checkpoints

Inspect `promo/frames/iphone` and `promo/frames/ipad` plus the contact sheets.

Opening, character showcase (crabs must keep moving), 7×8 recovery, streak, gold 35−7, completion, app icon.
