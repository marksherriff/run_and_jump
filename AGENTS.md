# Looper

## Game vision

Looper is a single-player, 2D puzzle platformer with a pixel-like graphic style.
Its central mechanic is spatial wrapping inside a player-activated dotted
rectangle. Here, "loop" means spatial wrapping, not time travel or replay.

The player starts with left/right movement, ordinary jumping, and looping.
Double jump, wall jump, and air dash remain implemented but are disabled by
default through exported player ability flags. Future pickups can enable them;
do not remove their code or turn them on by default. The prototype also includes
coins and health variables, not a finished health/progression system.

## Collaboration and scope

- The user designs individual levels using Godot's TileMap editor.
- Codex focuses on reliable player mechanics (especially looping), recovery from
  bad states, and supporting game flow: title screen, level select, HUD, pause,
  restart, and completion behavior when requested.
- Keep the existing level layout intact during mechanics or UI work unless the
  user explicitly asks for level changes.
- Help the user learn TileMap authoring. When requested, provide small template
  or example levels using the existing sprites and TileSet, with terrain that
  remains editable in Godot. Do not replace painted terrain with generated
  geometry or scripts as an incidental implementation choice.
- A larger loop box is planned as a later mechanic. Keep the implementation
  size-configurable; do not add its unlock rules, inputs, or progression yet.
- Future-work lists are context, not authorization to implement everything.

## Agreed mechanics

- Activating the loop centers the dotted rectangle on the player collider and
  freezes the current camera view. The box stays fixed while the player moves.
- The full player collider stays within the rectangle. Crossing an edge wraps
  to the opposite edge; only crossed axes wrap, including both axes at corners.
- Wrapping preserves velocity, overshoot, facing, and spent jumps/dashes.
  Teleportation must not grant abilities through stale floor or wall contacts.
- If a destination overlaps solid terrain or lies outside safe level bounds,
  block that edge and keep the loop active. Preserve movement parallel to the
  blocked edge where possible; never place the player inside solid terrain.
- The same input deactivates the loop and restores the player-following camera.
- Leaving safe level bounds returns the player to the initial spawn, clears
  velocity and spent movement abilities, and turns looping off. This is
  positional recovery; it does not reset coins or collected objects.
- Releasing directional input preserves facing for neutral-input air dashes.
- Double jump, wall jump, and air dash require their respective ability flags.
  Positional respawn preserves acquired flags; cross-level persistence is not
  implemented yet.
- The current box is 150 by 150 pixels. One configurable size drives its visual
  size and wrapping calculations. A larger box must use the same safety rules.

Treat these rules as design intent. Fix implementation defects without silently
changing the intended behavior. See [player mechanics](docs/player-mechanics.md)
for tuning settings and manual verification steps.

## Current project

- Godot 4 with GDScript, `.tscn` scenes, and assets under `Assets/`.
- `project.godot` selects `Scenes/main.tscn`. Its application name is still
  `Run and Jump`; the intended game name is Looper.
- `Scenes/player.gd` and `Scenes/player.tscn`: movement, abilities, animation,
  collider, respawn, player-following camera, and player signals.
- `Scenes/main.tscn`: launch scene containing one Level instance. No gameplay
  controller is attached to Main.
- `Scenes/Levels/base_level.tscn`: reusable inherited level setup. World contains
  TileMapLayer, SpawnPoint, and Objects; Gameplay contains Player, LooperBox,
  and LooperCamera; HUD is a child of the level root.
- `Scenes/Levels/level.gd`: shared spawn, bounds, camera, loop, and HUD wiring.
- `Scenes/Levels/example_level.tscn`: inherited level preserving the original
  example's painted terrain and spawn. Each new level should inherit the base.
- `Scenes/looper_box.gd` and `Scenes/looper_box.tscn`: configurable box visuals,
  edge wrapping, and handling blocked destinations.
- `Scenes/tile_map_layer.tscn`: shared TileSet and original sample map. The base
  clears its instance's cells; example_level supplies its own painted tile data.
- `Scenes/hud.gd` and `Scenes/hud.tscn`: coin display.
- `Scenes/coin.gd` and `Scenes/coin.tscn`: collectible behavior.
- `tests/test_player_mechanics.gd`: headless movement and looping regression checks.
- `tests/test_level_structure.gd`: standalone levels, spawn, bounds, and defaults.
- `docs/creating-levels.md`: scene hierarchy and Godot editor authoring workflow.

Use the existing input actions: `move_left`, `move_right`, `jump`, `looper`, and
`air_dash`. Read bindings from `project.godot` and support the existing keyboard
and controller inputs when changing gameplay or adding menus.

The level root's empty `level_bounds` setting falls back to painted TileMapLayers
under World plus `recovery_margin` (128 pixels). Explicit bounds are level-local
and converted to world space. Use explicit bounds when decorative maps would
make automatic bounds unsuitable. SpawnPoint controls initial and recovery spawn.
Recovery bounds do not add physical walls.

## Design priorities

- Make wrapping understandable, predictable, and useful for solving puzzles.
- Keep terrain, collision boundaries, the player, and the dotted rectangle
  visually readable in the pixel-like style.
- For requested example levels, introduce one idea, allow practice, then combine
  it with previously learned ideas. Identify the intended insight and route.
- Check whether ordinary movement, air dash, or wall jumping bypasses a puzzle.
- Consider loop placement, all four edges, corners, and destinations near solids.
- Provide practical recovery from failure and stuck states.
- Prefer tuning and clear feedback over adding unrequested abilities or systems.

Title screen, level selection, multi-level progression, completion rules, and
saving are upcoming work, not completed systems. Make only decisions needed for
the current task; flag decisions that materially change the player experience.

## Development guidelines

- Inspect relevant scripts, scene trees, resources, and signal connections before
  editing. Keep changes focused on the request and preserve existing user edits.
- Prefer simple, readable GDScript and small scripts on appropriate scene nodes.
  Follow existing conventions and add types where useful.
- Use signals between otherwise independent components and expose useful design
  tuning values through the inspector.
- Reuse player, loop-box, HUD, TileSet, and asset resources across levels. Avoid
  duplicating gameplay logic per level or introducing a large framework early.
- Preserve node names, resource paths, UIDs, and connections unless necessary.
  Update references when they change. Preserve path case for Windows and macOS.
- Edit `project.godot` only when required. Do not incidentally change engine
  version, renderer, or input mappings.
- Do not hand-edit `.godot/` caches or generated asset import metadata. Avoid
  unrelated reimports and changes to imported assets.
- Do not add plugins or dependencies unless requested or necessary for the
  agreed task; explain any necessary addition before making it.
- Keep this file and the mechanics documentation accurate as decisions change.

## Verification

- Documentation-only edits require accuracy and diff review, not a game run.
- For scripts or scenes, use an available compatible Godot executable to check
  parsing and loading. Use its actual executable name/path on the current OS.
- For player or looping changes, run:
  `godot --headless --path . --script tests/test_player_mechanics.gd`.
- For level setup changes, also run:
  `godot --headless --path . --script tests/test_level_structure.gd`.
- Check movement, jump/double-jump limits, dash facing, activation/deactivation,
  camera continuity, all wrap edges and corners, blocked destinations, bounds,
  momentum, ability availability, respawn, and different box sizes as relevant.
- Add meaningful regression tests for nontrivial logic; do not duplicate the
  implementation in tests or add tests for trivial documentation changes.
- Play the affected scene when possible. Headless checks do not establish visual
  quality or gameplay feel. For requested level changes, check intended solutions,
  likely shortcuts, and recovery. For menus, check focus, input, and transitions.
- Report what changed, what was checked, and remaining limitations. If Godot or
  interactive testing is unavailable, say so and provide concise manual steps.
  Never claim an unplayed level or untested interaction has been validated.
