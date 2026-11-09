# Cogni — Short Focus Games

**"Calm surface, loud stimulus."**

Everything outside the game is quiet: warm off-white surfaces, one accent colour, soft borders instead of heavy shadows, generous whitespace. Inside the game, the stimulus is the only loud thing on screen — big type, four saturated buttons, nothing else.

---

## Architecture & Technology Stack

- **Framework**: Flutter 3.44+ (Dart 3.12+)
- **Typography**: Inter (Google Fonts) with `FontFeature.tabularFigures()` on all numeric displays, Reaction Times, and scores.
- **State Management**: `Provider` (`AuthProvider`, `GameProvider`)
- **Data & Storage**: `StorageService` using `shared_preferences` with JSON serialization, session history (up to 50 sessions), user profile, preferences, and offline queue.
- **Charts**: `fl_chart` for score over time progression.
- **Platforms**: Android, iOS, Windows Desktop, Web (Chrome / Edge).

---

## Design Tokens Implemented

### Light Theme
- `bg`: `#FAFAF8`
- `surface`: `#FFFFFF`
- `surfaceAlt`: `#F4F4F2`
- `border`: `#E8E8E4`
- `textPrimary`: `#14161A`
- `textSecondary`: `#6B7280`
- `accent`: `#4F46E5`
- `accentSoft`: `#EEF0FF`

### Dark Theme
- `bg`: `#0D0F12`
- `surface`: `#16191E`
- `surfaceAlt`: `#1E222A`
- `border`: `#262B33`
- `textPrimary`: `#F5F6F7`
- `textSecondary`: `#9AA1AC`
- `accent`: `#8B93FF`
- `accentSoft`: `#1B1F3A`

### The Four Colourblind-Safe Stroop Colours (`StroopColors`)
Kept isolated in a dedicated `StroopColors` class to prevent accidental reuse for UI states:
- **Red**: `#E5484D` (●)
- **Green**: `#12A594` (▲, teal-leaning, colorblind-safe against red)
- **Blue**: `#3E63DD` (■)
- **Yellow**: `#FFC53D` (★, paired with `#14161A` text for high contrast)

### Feedback Colours
- **Correct**: Accent (`#4F46E5`) + `✓` overlay
- **Miss / Timeout**: Amber (`#F5A623`) + `✕` + "Miss" overlay

---

## Component Library (`lib/widgets/`)

1. `PrimaryButton`: 56 dp tall, radius 12, accent, single per screen.
2. `SecondaryButton`: 56 dp tall, border only, textPrimary.
3. `CogniCard`: Surface background, radius 20, 1 px border, single soft shadow (`0 2 8 rgba(20,22,26,0.04)`).
4. `LevelBadge`: Pill container, `accentSoft` background, `accent` tabular text.
5. `StatTile`: Caption label in uppercase (+0.2 tracking) + tabular figure value.
6. `ColourButton`: At least 88 dp tall, filled with Stroop color, name label, and optional colour-blind symbols (`● ▲ ■ ★`).
7. `TimerBar`: Accent fill on `surfaceAlt` track, linear progress without easing.
8. `FeedbackFlash`: 220 ms maximum transient overlay.
9. `EmptyState`: Centered icon card + title + description + action button.

---

## Screen Map & Features (`lib/screens/`)

1. **Splash**: Brand logo, 28/700 title, dot loader, 800ms minimum display, session check routing.
2. **Onboarding**: 3 swipeable slides with dot indicator, Skip action, Continue / Get Started.
3. **Consent & Disclaimer**: "Before you start" screen with 3 cards (*What this app does*, *What it does not do*, *Your data*), required checkbox with timestamp tracking.
4. **Auth (Sign up / Log in / Guest)**: Email & password validation, Google Sign-in simulation, Guest mode (`isGuest: true`).
5. **Main Navigation**: 4 persistent tabs (`Home`, `Games`, `Progress`, `Me`).
6. **Home**: User greeting, level badge, guest strip, offline warning strip, Colour Stroop card, "More games — coming soon" grid, disclaimer footer.
7. **Game Intro**: 30 trials explanation (10 practice no timer, 20 scored), rules, mini visual sample, quitting notice.
8. **Stroop Play Screen**:
   - 30 trials (1–10 warm-up with "Practice — no timer" chip; 11–30 scored with countdown timer).
   - 84 pt stimulus word with color ink (congruent & incongruent interference trials scaled by level).
   - 2x2 grid of colour buttons (≥88 dp).
   - 220 ms feedback flash overlay.
   - Quit confirmation dialog ("Quit this block? Your score won't be saved.").
   - No pause mid-block to protect reaction time accuracy.
9. **Block Result**:
   - Hero score (56 / 700 tabular) out of 100.
   - 2x2 breakdown: Speed, Accuracy, Median RT, Level.
   - Level change pill with 400 ms spring animation: Level up (`+1`), Level held (`0`), or Level down (`-1`).
   - Sync status.
   - Play again & Home actions.
10. **Progress**:
    - Line chart of score over time (`fl_chart`, accent color, 2px, dot markers).
    - Current level, Blocks played, Best score.
    - Recent sessions list with tap-to-inspect.
    - Zero-state empty view when no sessions exist.
    - Strictly no percentiles, brain age, or invented norm comparisons.
11. **Session Detail**: Date/time, hero score, speed bar, accuracy bar, median RT, trials count, correct count, timeouts, and notes.
12. **Games Library**: Active Colour Stroop card + coming soon cards (Memory, Attention, Speed, Reasoning).
13. **Profile & Settings ("Me")**:
    - Avatar initial, user email, level, block count.
    - Account: Edit name, Change password, Sign out.
    - Play: Sound toggle, Haptics toggle, Colour-blind mode toggle (● ▲ ■ ★), Offline simulation toggle.
    - Data: Export my data (JSON), Delete my account.
    - About: How to play, Disclaimer, Privacy policy, Version.
14. **Delete Account**: Required Play Store hygiene, confirmation via typing `DELETE`, permanent data wipe.
15. **How to Play**: Rules, visual congruent/incongruent samples, trial structure explanation.
16. **Legal & Medical Disclaimer**: Explicit declaration as educational self-tracking tool, not a diagnostic medical device.
17. **Privacy Policy**: Full declaration of local and account data handling, zero data monetization.

---

## How to Run

From this directory:

```bash
# Run on Google Chrome
flutter run -d chrome
# or run the batch script:
run_chrome.bat

# Run on Windows Desktop
flutter run -d windows
# or run the batch script:
run_windows.bat

# Run test suite
flutter test

# Run analyzer
flutter analyze
```
