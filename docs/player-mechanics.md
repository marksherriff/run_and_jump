# Player mechanics

The example's painted terrain is preserved in `Scenes/Levels/example_level.tscn`.
See [creating levels](creating-levels.md) for the shared scene structure.

## Loop rules

- Press the existing `looper` action to toggle the box. Activation centers it
  on the player collider and freezes the current camera view.
- The full player collider stays inside the box. Crossing an edge places it
  just inside the opposite edge. Only crossed axes wrap; a corner can wrap both.
- Wrapping preserves velocity, overshoot, facing, and spent jumps/dashes.
- If the destination overlaps solid terrain or lies outside the level's safe
  bounds, that edge behaves as solid. The loop stays active, and movement
  parallel to the blocked edge is preserved.
- Deactivating the box restores the following camera.
- A box too small for the player, or activation from inside solid terrain,
  is rejected.

`Scenes/looper_box.gd` exposes **Box Size**, currently `150 × 150`. This drives
both the sprite size and wrap calculation. Set it before activation to use a
larger box; no second ability or new input has been added yet. The original
box artwork is reused and stretches with that setting.

## Movement and recovery

- Movement speed, jump strength, acceleration, friction, air dash, and wall
  jumping retain their existing tuning.
- Double jump, wall jump, and air dash are disabled by default. Their exported
  `double_jump`, `wall_jump`, and `air_dash` flags can be enabled in the inspector
  for testing or by future pickups. Normal jumping and looping remain available.
- Releasing directional input preserves facing, so a neutral-input air dash
  still travels in the last facing direction.
- Landing restores the extra jump and air dash. Teleporting does not restore
  them or reuse floor/wall contacts from the old position.
- Leaving safe level bounds returns the player to their initial spawn,
  clears velocity and spent movement abilities, and turns looping off.
  Coins and collected objects are not reset by this positional recovery.

`Scenes/Levels/level.gd` exposes **Level Bounds**, a rectangle local to the level
root. When empty, painted TileMapLayers under World plus **Recovery Margin**
(128 pixels) provide fallback bounds. This catches falls without editing terrain.
Set explicit bounds when decorative tiles make the painted extent unsuitable.
Bounds are a recovery limit, not extra physical walls. **World/SpawnPoint** sets
both initial spawn and the recovery destination. Unlocked abilities survive
positional respawn, but cross-level persistence is not implemented yet.

## Verification

Run with an installed Godot 4 executable:

```text
godot --headless --path . --script tests/test_player_mechanics.gd
```

The checks cover original-level movement, jump/dash limits, camera toggling,
all edges, diagonal corners, larger boxes, fast overshoot, blocked destinations,
world bounds, invalid box sizes, and respawn state.

For a manual feel check, play the example: jump, verify extra jumps and dash are
unavailable, toggle the loop while moving, cross its edges, try an edge whose
destination overlaps terrain, then fall off the level. Temporarily enable the
ability flags to check double jump, wall jump, and neutral-input dash.
