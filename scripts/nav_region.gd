extends NavigationRegion2D

@onready var walls_tilemap := get_node("../Tilemapstuffs/TileMapLayer")
const TILE_SIZE: float = 64.0

func _ready():
	if not walls_tilemap:
		push_error("TileMapLayer (walls) not found!")
		return

	var nav_poly = NavigationPolygon.new()
	var used_cells: Array = walls_tilemap.get_used_cells()
	if used_cells.is_empty():
		push_warning("No used cells in wall tilemap.")
		return

	# Get map bounds from used cells
	var min_pos = used_cells[0]
	var max_pos = used_cells[0]
	for cell in used_cells:
		min_pos = Vector2i(min(min_pos.x, cell.x), min(min_pos.y, cell.y))
		max_pos = Vector2i(max(max_pos.x, cell.x), max(max_pos.y, cell.y))

	var top_left = walls_tilemap.map_to_local(min_pos) - Vector2(3 * TILE_SIZE, 3 * TILE_SIZE)
	var bottom_right = walls_tilemap.map_to_local(max_pos) + Vector2(4 * TILE_SIZE, 4 * TILE_SIZE)

	var outer_poly := PackedVector2Array([
		top_left,
		Vector2(bottom_right.x, top_left.y),
		bottom_right,
		Vector2(top_left.x, bottom_right.y),
	])
	nav_poly.add_outline(outer_poly)

	# Subtract obstacles from walls
	for cell in used_cells:
		var tile_id = walls_tilemap.get_cell_source_id(cell)
		if tile_id == -1:
			continue

		var world_pos = walls_tilemap.map_to_local(cell)
		var hole := PackedVector2Array([
			world_pos,
			world_pos + Vector2(TILE_SIZE, 0),
			world_pos + Vector2(TILE_SIZE, TILE_SIZE),
			world_pos + Vector2(0, TILE_SIZE),
		])
		nav_poly.add_outline(hole)

	# Finalize the polygon with holes
	nav_poly.make_polygons_from_outlines()
	self.navigation_polygon = nav_poly
