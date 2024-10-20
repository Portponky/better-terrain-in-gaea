@tool
class_name BetterTerrainGaeaRenderer
extends GaeaRenderer2D

# Adapted from Gaea's code

@export var tile_map_layers: Array[TileMapLayer] :
	set(value):
		tile_map_layers = value
		update_configuration_warnings()
@export var clear_tile_map_on_draw: bool = true
@export var erase_empty_tiles: bool = true


func _ready() -> void:
	super()

	if !generator:
		push_error("Needs a GaeaGenerator node assigned in its exports.")
		return

	if tile_map_layers.is_empty():
		push_error("Needs at least one TileMapLayer to work.")
		return

	var layer: TileMapLayer = tile_map_layers.front()
	if Vector2i(Vector2(layer.tile_set.tile_size) * layer.scale) != generator.tile_size:
		push_warning("The TileMapLayer's tile size doesn't match with generator's tile size, can cause generation issues.
					The generator's tile size has been set to the layer's tile size. (Only layer 0 checked)")
		generator.tile_size = Vector2(layer.tile_set.tile_size) * layer.scale


func _draw_area(area: Rect2i) -> void:
	var cells: Dictionary

	if tile_map_layers.is_empty():
		push_error("No TileMapLayers assigned, can't draw area.")
		return

	for x in range(area.position.x, area.end.x + 1):
		for y in range(area.position.y, area.end.y + 1):
			var tile_position := Vector2i(x, y)
			if erase_empty_tiles:
				var has_cell_in_position: bool = false
				for layer in range(generator.grid.get_layer_count()):
					if generator.grid.has_cell(tile_position, layer):
						has_cell_in_position = true
						break

				if not has_cell_in_position:
					for l in range(_get_tilemap_layers_count()):
						_erase_tilemap_cell(l, Vector2i(x, y))
					continue

			for layer in range(generator.grid.get_layer_count()):
				var tile_info = generator.grid.get_value(tile_position, layer)

				if tile_info is BetterTerrainTileInfo:
					_set_terrain(tile_position, tile_info)
					
					if not cells.has(tile_info.tilemap_layer):
						cells[tile_info.tilemap_layer] = [tile_position]
					else:
						cells[tile_info.tilemap_layer].append(tile_position)
				elif tile_info is TilemapTileInfo and tile_info.type == TilemapTileInfo.Type.SINGLE_CELL:
					_set_tile(tile_position, tile_info)
					

	for layer in cells:
		_update_terrain(layer, cells[layer])
	
	(func(): area_rendered.emit(area)).call_deferred()


func _draw() -> void:
	if clear_tile_map_on_draw:
		for layer in tile_map_layers:
			layer.clear()
	super._draw()



func _set_tile(cell: Vector2i, tile_info: TilemapTileInfo) -> void:
	tile_map_layers[tile_info.tilemap_layer].call_thread_safe(&"set_cell",
		cell, tile_info.source_id,
		tile_info.atlas_coord, tile_info.alternative_tile
	)


func _set_terrain(cell: Vector2i, bt_info: BetterTerrainTileInfo) -> void:
	BetterTerrain.call_thread_safe(&"set_cell",
		tile_map_layers[bt_info.tilemap_layer], cell, bt_info.terrain
	)


func _update_terrain(layer: int, cells: Array) -> void:
	BetterTerrain.call_thread_safe(&"update_terrain_cells",
		tile_map_layers[layer], cells
	)


func _get_tilemap_layers_count() -> int:
	return tile_map_layers.size()


func _erase_tilemap_cell(layer: int, cell: Vector2i) -> void:
	tile_map_layers[layer].call_thread_safe(&"erase_cell", cell)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray

	warnings.append_array(super._get_configuration_warnings())

	if tile_map_layers.is_empty():
		warnings.append("Needs at least one TileMapLayer to work.")

	return warnings
