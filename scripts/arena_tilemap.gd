extends TileMap

const TILE_SIZE: int = 16
const GRID_WIDTH: int = 80
const GRID_HEIGHT: int = 45
const LAYER: int = 0
const ATLAS_COORDS: Vector2i = Vector2i.ZERO

const LAYOUT_TRAINING_YARD: int = 1
const LAYOUT_OWL_SANCTUM: int = 2
const LAYOUT_SAND_PIT: int = 3
const LAYOUT_IRON_CORRIDOR: int = 4

@export var layout_id: int = LAYOUT_TRAINING_YARD

var _ground_source_id: int = -1
var _wall_source_id: int = -1

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	z_index = -10
	_setup_tileset()
	_build_layout()

func _setup_tileset() -> void:
	var new_tile_set: TileSet = TileSet.new()
	new_tile_set.tile_size = Vector2i(TILE_SIZE, TILE_SIZE)

	var ground_texture: Texture2D = load("res://assets/tiles/tile_ground_16.png") as Texture2D
	if ground_texture == null:
		push_error("Missing tile texture: res://assets/tiles/tile_ground_16.png")
		return
	var wall_texture: Texture2D = load("res://assets/tiles/tile_wall_16.png") as Texture2D
	if wall_texture == null:
		push_error("Missing tile texture: res://assets/tiles/tile_wall_16.png")
		return

	var ground_source: TileSetAtlasSource = _make_source(ground_texture)
	_ground_source_id = new_tile_set.add_source(ground_source)

	var wall_source: TileSetAtlasSource = _make_source(wall_texture)
	_wall_source_id = new_tile_set.add_source(wall_source)

	tile_set = new_tile_set

func _make_source(texture: Texture2D) -> TileSetAtlasSource:
	var source: TileSetAtlasSource = TileSetAtlasSource.new()
	source.texture = texture
	source.texture_region_size = Vector2i(TILE_SIZE, TILE_SIZE)
	source.create_tile(ATLAS_COORDS)
	return source

func _build_layout() -> void:
	if _ground_source_id < 0 or _wall_source_id < 0:
		push_error("Tile sources not ready for layout build.")
		return
	clear()
	_fill_ground()
	_paint_border()

	match layout_id:
		LAYOUT_TRAINING_YARD:
			_paint_training_yard()
		LAYOUT_OWL_SANCTUM:
			_paint_owl_sanctum()
		LAYOUT_SAND_PIT:
			_paint_sand_pit()
		LAYOUT_IRON_CORRIDOR:
			_paint_iron_corridor()
		_:
			_paint_training_yard()

func _fill_ground() -> void:
	for y in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			set_cell(LAYER, Vector2i(x, y), _ground_source_id, ATLAS_COORDS)

func _paint_border() -> void:
	for x in range(GRID_WIDTH):
		_set_wall(Vector2i(x, 0))
		_set_wall(Vector2i(x, GRID_HEIGHT - 1))
	for y in range(GRID_HEIGHT):
		_set_wall(Vector2i(0, y))
		_set_wall(Vector2i(GRID_WIDTH - 1, y))

func _set_wall(coords: Vector2i) -> void:
	set_cell(LAYER, coords, _wall_source_id, ATLAS_COORDS)

func _fill_rect(start_x: int, start_y: int, width: int, height: int) -> void:
	for y in range(height):
		for x in range(width):
			_set_wall(Vector2i(start_x + x, start_y + y))

func _paint_training_yard() -> void:
	_fill_rect(36, 15, 8, 14)
	_fill_rect(16, 17, 5, 10)
	_fill_rect(59, 17, 5, 10)

func _paint_owl_sanctum() -> void:
	_fill_rect(35, 19, 10, 6)
	_fill_rect(36, 6, 8, 4)
	_fill_rect(36, 35, 8, 4)

func _paint_sand_pit() -> void:
	_fill_rect(18, 10, 6, 6)
	_fill_rect(56, 10, 6, 6)
	_fill_rect(34, 28, 12, 4)

func _paint_iron_corridor() -> void:
	_fill_rect(24, 20, 32, 4)
	_fill_rect(38, 6, 4, 10)
	_fill_rect(38, 29, 4, 10)
