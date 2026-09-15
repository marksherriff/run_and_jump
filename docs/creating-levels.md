# Creating levels in Godot

## Scene structure

`Scenes/main.tscn` is the launch scene. It contains one instance of the current
level (`Scenes/Levels/example_level.tscn`). The example retains the original
painted tiles and spawn position.

Each level inherits `Scenes/Levels/base_level.tscn`:

```text
Level                       Shared level controller; bounds settings
├── World                   Your level design
│   ├── TileMapLayer         Paint terrain with the existing TileSet
│   ├── SpawnPoint          Move this marker to choose the player's start
│   └── Objects             Place coins and future pickups/exits here
├── Gameplay                Shared mechanics
│   ├── Player              Includes its following Camera2D
│   ├── LooperBox
│   └── LooperCamera         Fixed camera while looping
└── HUD                     Shared coin display
```

Edit the base scene when changing shared setup for every level. Edit an inherited
level when painting terrain, placing objects, or moving its spawn. Inheritance
lets shared changes flow to each level without copying player scripts or wiring.

## Make a new level

1. In Godot's FileSystem dock, right-click `Scenes/Levels/base_level.tscn` and
   choose **New Inherited Scene**.
2. Save it in `Scenes/Levels/`, for example `level_01.tscn`. You can rename its
   root to `Level01`.
3. Select **World → TileMapLayer** and use the TileMap panel to select tiles and
   paint terrain in the 2D viewport. The base has an empty map and the existing
   TileSet, so new terrain is saved in this level.
4. Move **World → SpawnPoint** to an open location above a floor. The marker is
   the player's origin; the current collider extends about 16 pixels vertically
   from it, so leave enough clearance. Moving the Player node does not set spawn.
5. Instance `Scenes/coin.tscn` under **World → Objects** if desired. Use that
   container for future level-specific objects too.
6. Select the level root to set **Level Bounds** if needed. Coordinates are local
   to the level root. Empty bounds derive a recovery area from terrain plus
   **Recovery Margin**. Keep the spawn and intended playable space inside it.
7. Press **F6** to run this level directly. HUD, camera, loop, and recovery work
   without launching through Main. An unpainted level has no floor, so paint
   terrain before playtesting.

For more terrain layers, add `TileMapLayer` nodes under World and reuse the
existing TileSet. Automatic recovery bounds include every TileMapLayer under
World. Set explicit bounds when decorative layers would make that area too large.

Painting changes this level's cells. Editing the shared **TileSet resource**
(tile collision shapes, atlas definitions, etc.) affects other levels using it.

## Choose the level launched by F5

Open `Scenes/main.tscn`, remove its **Level** instance, and instance your saved
level under Main. Keep one level instance and name it **Level** for consistency.
Save Main and press **F5**. No script paths or signal connections need changing.

You can also duplicate `example_level.tscn` to start from the existing map; use
an inherited scene from the base when you want a blank map.

## Abilities

The player starts with ordinary jumping and looping. Double jump, wall jump,
and air dash are implemented but disabled. Select **Gameplay → Player** and
look under **Abilities** to enable them for testing in a particular level.
Leave them unchecked for the current baseline.

Future pickup scripts can enable `player.double_jump`, `player.wall_jump`, or
`player.air_dash`. These flags survive positional respawn within the current
scene. Saving unlocked abilities across levels is not implemented yet.
