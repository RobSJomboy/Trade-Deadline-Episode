# Trade Reaction — Talkin' Baseball Overlay (Deadline Day)

Same bones as the Trade Draft Show system — two static files synced live over Firebase Realtime Database, MLB Stats API for headshots/logos — built for live reaction to real trades as they break on deadline day.

> **Transport changed (2026-07-29):** this was originally built on [ntfy.sh](https://ntfy.sh), which became unreachable and took the whole overlay down — control published into the void, display never updated. It now uses the same Firebase RTDB transport as the other Jomboy overlays (shared `pinpoint-abf21` project, path `tradedeadline/<topic>/state`). The Firebase SDK handles its own reconnects, so the old SSE watchdog and 4-second polling fallback are gone. The connection pill in Control now reflects the **real** connection state instead of always claiming "connected".

## Files
- **`display.html`** — the on-air graphic. OBS Browser Source → **1920×1080**, transparent background.
  `display.html?topic=your-topic`
- **`control.html`** — the control panel. Open on any device (phone, second laptop, whatever), same topic, drives the display live.

## What's new vs. the Trade Draft Show build
1. **Single reveal, not a draft board** — search a player, search a team, hit Show on each. Same 750ms ease, headshot → red arrow → team logo layout, sitting low on the frame just above the ticker.
2. **Trade Tracker ticker** — white bar **55px tall** floating **100px off the bottom, inset 10px each side**, with a 3px `#173a56` rule along the top and bottom only (the left and right ends stay unstroked). Halved from 110px on 2026-07-30; the rules stayed at 3px rather than dropping to 1.5px, which would read as a hairline on air. `#173a56` text, continuous auto-scrolling crawl. Always renders **ALL CAPS** no matter how you type it, with the Talkin' Baseball mark between every item as the separator.
   - Type any line and hit **Add**, or click **"Add Currently Displayed Player/Team to Ticker"** to pull straight from whatever you've got staged/on-air.
   - **Fade Ticker In / Fade Ticker Out** button does a 750ms opacity ease — the ticker itself keeps scrolling underneath even while faded out, so there's no restart hitch when you bring it back.
   - Adding or removing a line **cross-fades** the crawl (260ms out → swap → back in) rather than hard-cutting. A repaint restarts the scroll from the left edge; the fade is what hides that jump.
3. **Deadline countdown** — sits inside the ticker's navy block on the left, directly under "TRADE TRACKER", counting down to **Monday 3 August 2026, 6:00pm ET**. Toggle it with **Show / Hide Countdown** in Control.
   - The ticker has to be faded in for it to be visible — it lives inside the bar.
   - The target instant is hardcoded in `display.html` with an explicit `-04:00` offset, so it's correct regardless of the timezone on the machine running OBS. **If the deadline date ever moves, edit `DEADLINE_MS` in `display.html`** — it's the only place it's defined.
   - The clock ticks locally in each display off that fixed target; only the show/hide flag travels over Firebase, so there's no per-second network traffic. It recomputes from the target every tick rather than decrementing, so a throttled interval skips a frame instead of drifting behind.
   - Reads `4D 04:12:33` while days remain, drops to `04:12:33` inside the last day, and shows `PASSED` once the deadline is by.
4. **Trade count** — a "how many trades have there been" badge above the ticker on the left, flush with the bar's left edge and bottom-aligned to the same line as the name tags. Toggle with **Show / Hide Trade Count**.
   - The number is **set manually**, not derived from your ticker lines — league-wide trade counts usually run ahead of however many lines you've typed. Use **−1 / +1**, or type straight into the field.
   - **Match Ticker** snaps it to the current ticker item count if you do want the two in sync.
   - Every path funnels through one setter that clamps to a non-negative integer, so a stray keystroke can't put `-3`, `4.7`, or `NaN` on air. `display.html` re-coerces on receipt too, since RTDB can hand a number back as a string.
5. **Passan Alert** — the big red button. Every click plays an audio cue *through the OBS display source itself* (the sound is baked into `display.html`, no extra files to host), so add that browser source to your audio mixer and it'll cue Jake & Trevor the moment a trade drops. Also flashes a quick on-screen "TRADE ALERT" banner as a visual backup.

## Setup
1. Host both files somewhere static — either a new GitHub repo (recommended: keep it separate from `MLB-Trade-Draft` and `Snub-Draft`, same pattern) or add a subfolder to an existing Pages site.
2. Pick a long, unguessable topic name, e.g. `jomboy-trade-reaction-6q1p3`. (The database is open, so the topic name is the only thing keeping the show private — treat it like a password.)
3. Point your OBS Browser Source at:
   `https://<your-pages-url>/display.html?topic=jomboy-trade-reaction-6q1p3`
4. Open `control.html` anywhere, type the same topic into the connect bar, hit **Connect**.
5. **Test before you're live**: search a player, Show. Search a team, Show. Add a couple ticker lines and Fade it in. Hit Passan Alert once and confirm you can hear it (check the OBS audio mixer — the Browser Source needs its audio unmuted and routed wherever Jake/Trevor's monitor mix lives).

## Notes
- Player/team images load live from MLB's official Stats API/CDN — nothing to re-download each season.
- The Passan alert sound and the Talkin' Baseball mark are embedded directly in `display.html` (base64), so there's no separate audio or image file to keep track of or accidentally leave out of a repo push.
- **The corner logo bug is gone** (2026-07-29) — the mark now lives between ticker items instead, and the Show/Hide Logo Bug buttons were removed from Control. `display.html` ignores a `showLogoBug` key if an older control panel still sends one.
- Layout geometry in `display.html` is hand-tuned against the ticker's position. The bar is 55px tall (border-box, rules included) floating 100px off the bottom, so it occupies `y=925..980`. The reveal group is placed to land 15px above that: images at `y=626`, arrow at `y=711`, name tags at `y=879`, group bottom at `y=910`. The trade-count badge's `bottom:170px` ties it to that same `y=910` line. **Move or resize the ticker and every one of those numbers has to move with it** — too small a gap and the bar rides over the name tags, too large and the group floats away from it. There's a comment in the CSS saying so.
- Type inside the ticker was halved along with the bar, which puts the countdown's "DEADLINE" sub-label at **8px** and the crawl at 17px. That's legible at native 1080p but thins out badly once the stream is downscaled to 720p or watched on a phone. If it reads poorly on air, the bar can stay at 55px while the type backs off to label 18px / sub-label 11px / clock 16px / crawl 20px — measured to still fit the 49px content box without clipping.
- If you want the brand **Rift** font instead of the Barlow Condensed fallback, drop the font files next to `display.html` and uncomment the `@font-face` block near the top of the `<style>` section — same pattern as your other overlays.
- Ticker items persist in the control panel's local storage between sessions, so a pre-loaded list of pre-deadline trades will still be there if you refresh the control page mid-show.
