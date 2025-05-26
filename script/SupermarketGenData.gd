extends MazeGenData
class_name SupermarketGenData


var entrance_area: Rect2i
var entrance_pos: Vector2i


func generate_entrance_coord() -> void:
	entrance_pos = Vector2i(1, rng.randi_range(2, maze_dim.y - 7))
	entrance_area = Rect2i(entrance_pos + Vector2i(-1, -1), Vector2i(4, 6))


static func from_maze_data(_data: MazeGenData) -> SupermarketGenData:
	var new_data: SupermarketGenData = SupermarketGenData.new()
	new_data.maze_dim = _data.maze_dim
	new_data.maze_seed = _data.maze_seed
	new_data.rng = _data.rng
	
	new_data.btm_boundaries = _data.btm_boundaries
	new_data.btm_corners = _data.btm_corners
	new_data.btm_walls = _data.btm_walls
	new_data.btm_maze = _data.btm_maze
	new_data.list_boundaries = _data.list_boundaries
	new_data.list_corners = _data.list_corners
	new_data.list_walls = _data.list_walls
	new_data.list_maze = _data.list_maze
	
	new_data.generate_entrance_coord()
	
	return new_data
