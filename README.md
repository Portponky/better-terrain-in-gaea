# better-terrain-in-gaea

Godot 4.3 plugin to combine Better Terrain and Gaea. Adaptation of code from Gaea https://github.com/BenjaTK/Gaea/

Adds three new types:

`better_terrain_tile_info` - A type to assign gaea noise to better terrain terrains. Just has a layer and terrain number. Get the terrain number by hovering over the terrain you want in the Better Terrain dock.

`better_terrain_gaea_renderer` - Renders Gaea generators with Better Terrain. Also supports regular TilemapTileInfo, as long as they are in single cell mode.

`better_terrain_changeset_renderer` - Renders Gaea generators with Better Terrain using the changeset system, so it occurs off-thread. I'm not sure if this works correctly, I didn't see any performance difference in the editor.

