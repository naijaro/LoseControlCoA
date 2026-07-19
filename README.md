# LoseControlCoA

LoseControlCoA displays the remaining duration of crowd-control effects (stuns,
silences, disarms, roots, snares, fears, immunities, and more) as a cooldown
spiral on unit portraits — your player, target, focus, party, and arena frames.

This is an adaptation of the classic **LoseControl** addon for **Ascension WoW:
Conquest of Azeroth**, which adds 21 new classes along with many new abilities.
The goal of this fork is to keep the original, lightweight LoseControl behaviour
while extending its spell/ability tracking to cover the new Conquest of Azeroth
content.

## Credits

This addon stands on the work of several people:

- **Kouri (Kouri86)** — original author of LoseControl.
- **millanzarreta** and contributors — maintainers of the GPLv3 LoseControl
  fork that this work builds on.
- **MaxQuest / Naijaro** — Conquest of Azeroth adaptation (this repository).

Upstream / original sources:

- Original LoseControl: <https://www.wowinterface.com/downloads/info11642-LoseControl.html>
- GPLv3 fork: <https://github.com/millanzarreta/LoseControl>

## What changed in this fork

- Renamed the addon to `LoseControlCoA` so it can be installed alongside (but
  not simultaneously with) the original.
- Updated the `.toc` (title, author, website, version) and corrected the loaded
  file reference.
- Adapting the tracked spell/ability list and class handling for the new
  Conquest of Azeroth classes and abilities (ongoing).

## Installation

1. Copy the `LoseControlCoA` folder into
   `World of Warcraft/Interface/AddOns/`.
2. Restart the game (or reload with `/reload`).
3. Configure it via the in-game Interface Options panel, or with the `/lc`
   command. Type `/lc help` for the list of commands.

## License

LoseControlCoA is free software, licensed under the **GNU General Public License,
version 3 (GPLv3)** — the same license as the upstream fork it is based on. You
may use, study, modify, and redistribute it under the terms of that license.
Because the GPL is a copyleft license, any distributed version derived from this
code must also remain under the GPLv3, with source code included and the
original credits preserved.

The full license text is in [LICENSE.txt](LICENSE.txt), or online at
<https://www.gnu.org/licenses/gpl-3.0.html>.

Third-party libraries bundled under `Libs/` (if any) retain their own licenses;
GPLv3 applies to the LoseControlCoA code itself, not to those bundled libraries.
