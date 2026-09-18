# PAWCI PROTOCOL

An original, playable Godot 4 retro FPS prototype. You are an escaped laboratory cat. Find red clearance, survive the containment wing, and reach the surface elevator. Dr. Pawci is a fictional character; no real person's appearance is used.

## Start playing — Windows or Mac

1. Install the **standard edition of Godot 4.4 or newer** from https://godotengine.org/download/ . The .NET edition is unnecessary.
2. Extract this entire ZIP into a folder. Do not open the project inside the ZIP.
3. Open Godot, choose **Import**, and select this folder's `project.godot`.
4. Choose **Import & Edit**. Allow the initial file scan to finish.
5. Press **F6** with `Containment.tscn` open, or simply **F5** to run the project.
6. The game captures your mouse. Press **Escape** to release it and open the pause menu.

This is a source project, not a Windows executable or a browser game. No paid plugins, downloaded artwork, or external audio are required. Tested with Godot 4.4.1 using the Compatibility renderer.

## Controls

| Action | Control |
|---|---|
| Move | W A S D |
| Look / aim | Mouse |
| Sprint | Shift |
| Jump | Space |
| Fire | Left mouse button; hold for repeated shots |
| Reload | R |
| Open a nearby door | E, within 3 meters |
| Pause / release cursor | Escape |
| Restart | Pause or death screen → Restart Containment |

Aim slightly downward at the small robots. The blaster deals 25 damage per shot. Drones take two hits; mice take one. The magazine holds 12 shots, with 48 spare at the start. Reloads take 1.15 seconds. Treats restore up to 25 HP, capped at 100; Tuna Cells grant 24 spare rounds. Health pickups remain if you are already full.

## Level 1 — Containment

Designed as an approximately 5–10 minute first exploration; human completion time has not been benchmarked.

- Leave the starting lab through the normal security door.
- At the first large room, take the eastern research passage.
- Explore north and then east to find the red key in Catnip Storage.
- Return to the central hall and head south through the red security door.
- Enter the large final containment room. Three Vacuum Drones and five Tin-Can Mice activate.
- Eliminate all eight final guards. The lighting turns green and the elevator gate opens.
- Walk into the elevator to finish. You do not need to eliminate every optional enemy elsewhere.

One suspicious wall in the eastern side of the first large room conceals Dr. Pawci's private catnap suite. Use E near it. The secret supplies extra health and ammunition.

There is a full-level restart system rather than a mid-level checkpoint. Progress is not saved between launches. The HUD records health, ammo, clearance, enemies remaining, and level; the end screen reports kills, time, and secret discovery.

## Project layout

- `scenes/levels/Containment.tscn`: main playable scene.
- `scenes/player/Player.tscn`: reusable first-person cat controller.
- `scenes/weapons/TunaBlaster.tscn`: centered gun and visible cat paws.
- `scenes/enemies/`: reusable Vacuum Drone and Tin-Can Mouse scenes.
- `scenes/doors/`: normal Door and LockedDoor variants.
- `scenes/pickups/`: HealthPickup, AmmoPickup, and RedKey.
- `scenes/ui/HUD.tscn`: HUD, menus, subtitles, optional touch controls.
- `scripts/level.gd`: procedural geometry, navigation grid, encounters, and elevator.
- `scripts/game.gd`: shared run state, damage, restart, completion, input actions.
- `scripts/player.gd`: acceleration, gravity, movement, camera, and interactions.
- `scripts/weapon.gd`: hitscan, fire timing, reload, recoil, and muzzle flash.
- `scripts/enemy.gd`: shared state machine and two enemy configurations.
- `scripts/door.gd`: key checks, slide animation, collision and navigation changes.
- `scripts/pickup.gd`: pickup collection and stat changes.
- `scripts/visual.gd`: original low-resolution texture and mesh helpers.
- `scripts/retro.gdshader`: 480×270 world pixelation and palette quantization; HUD stays sharp.
- `scripts/sound.gd`: named AudioStreamPlayer nodes and generated sound fallback.
- `assets/`: replacement asset directories and guidance.
- `tests/`: engine-driven gameplay and restart checks.

Scenes are reusable entry points; meshes and child nodes are created in `_ready()`. The level therefore appears during play rather than as a fully populated editor scene. This is intentional for the small procedural prototype.

## Enemy behavior

Enemies idle/patrol locally until they see the player within 15 meters. A physics ray prevents detection and attacks through walls. Detection plays a warning tone. Pursuit uses an AStarGrid2D route when sight is blocked; closed doors also block navigation. Damage briefly interrupts movement. Drones ram for 10 HP on a 1.2-second cooldown. Mice move faster, leap at close range, and deal 5 HP. Defeated enemies disappear without gore and emit a `died` signal. Only deaths of final-room guards count toward the elevator unlock.

## Mobile-ready input

Touch controls activate automatically on platforms Godot identifies as mobile. Drag on the left to move, drag on the right to look, and use FIRE / USE / RELOAD / PAUSE. Desktop input stays available. To preview touch controls on desktop, run:

`godot --path . -- --touch`

Landscape orientation is recommended. A native Android/iOS build needs the corresponding Godot export templates and platform setup. Physical touch-device usability has not been verified. Touch jump/sprint buttons are not included; neither action is required to finish the level.

## Add another level

Duplicate the Containment scene and `level.gd`, attach your copied script, and edit its `carve()` room/corridor calls plus spawn coordinates. A grid cell is 3 meters. Keep all routes connected, with solid cells around the map. Rebuild navigation after changing cells. Use `spawn_door()` to register closed gates and their navigation blockers. Spawn the player and HUD before calling announcements. Keep the `path_between()`, `unblock()`, and final-encounter interface, or update the dependent scripts. Set the new scene as the project main scene to test it. A multi-level campaign transition is outside this prototype.

## Replace textures and models

Place original/licensed assets in `assets/textures/` and `assets/models/`. Update `LabVisual.wall_material()` to load a texture instead of constructing its 32×32 image. Keep `TEXTURE_FILTER_NEAREST`. You can replace procedural enemy/weapon mesh creation in `_ready()` with imported models or scene children; preserve their collision bodies and gameplay scripts. The pixel shader applies to the world but not the HUD. Change its `resolution` uniform, or remove the Retro CanvasLayer construction in `level.gd`, to adjust the effect.

## Replace audio / add voice

Add WAV files in `assets/audio/` with one of these names:

`fire.wav`, `reload.wav`, `footstep.wav`, `detect.wav`, `attack.wav`, `pickup.wav`, `door.wav`, `damage.wav`, `secret.wav`, `elevator.wav`, `ambient.wav`, `alarm.wav`, `music.wav`.

Godot imports them on opening the project. `sound.gd` uses each file if present and synthesizes a fallback if absent. Ambient hum plays automatically. The music node exists but music is not enabled by default. Set loop import settings on replacement ambience/music as appropriate. To enable background music, call `Sound.play("music")` after Sound initializes. Audio is simple non-spatial placeholder audio, not a finished soundtrack.

PA announcements currently use timed text subtitles. To add speech, create an AudioStreamPlayer for each announcement or a shared PA player and start the matching clip in the existing announcement block in `level.gd`. The subtitle strings remain available without voice assets.

## Add a weapon or enemy

**Weapon:** duplicate TunaBlaster and its script, change damage/cooldown/geometry, and load the new scene in `player.gd`. Keep the `fire()`, `reload()`, and `bob` interface. The current magazine/reserve fields belong to a single weapon in Game; introduce per-weapon inventory before adding weapon switching.

**Enemy:** duplicate an enemy scene and attach a derived/copied script. Preserve CharacterBody3D, collision layer 4, the `enemies` group, `take_damage()`, and `died(enemy)`. Register final guards through `spawn_enemy()` so victory accounting stays correct. Tune health, speed, cooldown, geometry, and attacks there.

## Verification

From the project folder, with the Godot executable on your PATH:

```
godot --headless --path . --editor --quit
godot --headless --path . res://tests/Smoke.tscn
godot --headless --path . --script res://tests/restart_runner.gd
```

The smoke test uses real scene instances and physics to check movement, floor collision, looking, hitscan damage, deaths, ammunition, reloads, pickups, key/door checks, navigation reachability, chase/attack, secret discovery, final-wave clearance, pause, death, reset, and elevator completion. The separate restart test reloads the actual scene after death. These checks do not replace a human playthrough, hardware performance testing, or a physical mobile-device test. See `TEST-RESULTS.md` for the recorded run.

## Originality and scope

All game geometry, procedural textures, placeholder effects, dialogue, names, and code were created for this prototype. No Doom assets or real person's likeness are included. Visuals are deliberately simple and replaceable. This is a first playable, not a finished commercial game.
