# Looper

## Game vision

Looper is a single-player, 2D puzzle platformer with a pixel-like graphic style.
Its central mechanic is spatial wrapping inside a player-activated rectangle.
The basic mechanic exists; the next development priorities are level design,
level creation, a title screen, and the supporting game flow.

### Core player abilities

- Move left and right.
- Jump and double jump.
- Toggle looping with an input action. Activating it displays a dotted rectangle
  around the player and locks the camera in place.
- While looping, the player stays within that rectangle by wrapping to the
  opposite side when reaching an edge: left/right and top/bottom.
- The rectangle and locked camera remain in place while the player moves.
- The prototype toggles looping off with the same action, hides the rectangle,
  and restores the player-following camera. Preserve this unless asked to change it.

Here, "loop" means spatial wrapping, not time travel or a recording/replay mechanic.
Treat the mechanics above as design intent. Existing implementation details may
need fixes to satisfy that intent; do not silently redefine the design around a bug.

## Current project

- Godot 4 project using GDScript, `.tscn` scenes, and assets under `Assets/`.
- `project.godot` selects `Scenes/main.tscn` as the entry scene. Its application
  name is still `Run and Jump`; the intended game name is Looper.
- `Scenes/player.gd` and `Scenes/player.tscn`: movement, abilities, animation,
  player-following camera, and player signals.
- `Scenes/main.gd` and `Scenes/main.tscn`: current gameplay scene, camera switching,
  loop-box placement, and HUD wiring.
- `Scenes/looper_box.gd` and `Scenes/looper_box.tscn`: loop boundary and wrapping.
- `Scenes/main.tscn`: square introductory room with editable static walls,
  lower-left spawn, central divider, exit, and completion/replay UI.
- `Scenes/sky.gd`: editor-visible pixel-style sky and clouds.
- `Scenes/tile_map_layer.tscn`: original sample tile map, currently unused.
- `Scenes/hud.gd` and `Scenes/hud.tscn`: coin display.
- `Scenes/coin.gd` and `Scenes/coin.tscn`: collectible behavior.

The prototype also includes air dash, wall jumping, coins, and health variables.
Preserve these during unrelated changes, but do not assume they are required
parts of future puzzles or a finished health/progression system.

The introductory room is solved by activating a loop beside the central wall,
walking left to wrap to its right side, then disabling the loop and reaching the
exit. Its divider meets the ceiling to prevent wall-jump shortcuts. The exit
stops gameplay and offers replay. `tests/test_level.gd` checks this route using
Godot's headless runner (`--headless --path . --script tests/test_level.gd`).

Use the existing input actions: `move_left`, `move_right`, `jump`, `looper`, and
`air_dash`. Read their current bindings from `project.godot`; support its keyboard
and controller inputs when changing gameplay or adding menus.

## Design priorities

- Make wrapping understandable, predictable, and useful for solving puzzles.
- Keep platforms, collision boundaries, the player, and the dotted rectangle
  visually readable in the pixel-like style.
- Build small, playable levels that introduce one idea, let the player practice
  it, and then combine it with previously learned ideas.
- For each level, identify the intended insight, route, and completion condition.
  Check whether ordinary movement or extra prototype abilities bypass the puzzle.
- Consider where looping can be activated and how its placement changes the
  solution. Check all four edges, corners, and destinations near solid geometry.
- Provide a practical way to retry when adding failure states or puzzles that
  can leave the player stuck.
- Prefer tuning and clear feedback over adding new abilities or systems.

The title screen, multi-level progression, and save system are not yet
specified. Make only the decisions needed for the
current request, and flag decisions that materially change the player experience.
Do not treat this list of future work as authorization to implement it all at once.

## Development guidelines

- Inspect the relevant scripts, scene trees, resources, and signal connections
  before editing. Keep changes focused on the requested task.
- Prefer simple, readable GDScript and small scripts attached to appropriate
  scene nodes. Follow existing conventions; add types where useful.
- Use signals for communication between otherwise independent components.
- Expose values that need design tuning through the inspector when appropriate.
- Reuse player, loop-box, HUD, and asset resources across levels. Avoid copying
  gameplay logic into each level or introducing a large framework prematurely.
- Preserve node names, resource paths, UIDs, and signal connections unless the
  task requires changing them. Update all references when a change is necessary.
- Preserve filename case so resources work across Windows and macOS.
- Edit `project.godot` only when required by the task. Do not change the engine
  version, renderer, or input mappings incidentally.
- Do not hand-edit `.godot/` caches or generated asset import metadata. Avoid
  unrelated resource reimports and preserve existing user changes.
- Do not add plugins or external dependencies unless requested or necessary for
  the agreed task; explain any necessary addition before making it.
- Keep this file accurate when the project structure or agreed design changes.

## Verification

- For documentation-only changes, review accuracy and the diff; no game run is
  required.
- For scripts or scenes, use an available compatible Godot executable to check
  imports and parsing, for example `godot --headless --path . --editor --quit`.
  Use the executable's actual name or path on the current machine.
- Run the affected scene or project when possible. A headless check does not
  establish that gameplay or visual layout works.
- For movement or looping changes, check movement, jump, double jump, activation,
  camera lock, wrapping across each edge and at corners, deactivation, and
  interactions with platforms. Verify momentum and jump availability behave as
  intended across wrapping.
- For level changes, play through the intended solution, check likely shortcuts,
  and test recovery from failure. For menu changes, check focus, input, and scene
  transitions with the supported input methods.
- Add automated tests when they meaningfully protect nontrivial logic; avoid
  tests that merely duplicate the implementation.
- Report what changed, what was checked, and any remaining limitations. If Godot
  or interactive testing is unavailable, state that clearly and give concise
  manual verification steps. Do not claim an unplayed level is validated.
