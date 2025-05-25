@tool
extends Node3D
class_name MazeScene

enum Tiles {
	SINGLE_FLOOR,
	BAKERY,
	FRESH_PRODUCE,
	FRIDGE_MILK,
	FREEZERS,
	WALL,
	WALL_CORNER,
	ROOF_CLOSED,
	ROOF_OPEN
}

const PRODUCTS = [
	Tiles.BAKERY,
	Tiles.FRESH_PRODUCE,
	Tiles.FRIDGE_MILK,
	Tiles.FREEZERS,
]

@export_tool_button("DO IT!", "Button") var do_it: Callable = create_maze_3d
@export var generate_roof: bool = true

var maze_dim: Vector2i = Vector2i(41,41)




func create_maze_3d() -> void:
	
	var maze_data:  = MazeGen.generate_maze(
		maze_dim,
		[
			"JustCovino",
			"Seano4D",
			"HypnoticK_Games",
			"FoolBox",
			"code807",
			"konradgryt",
			"mrdboy_",
			"ScaryPastry",
			"iheartfunnyboys",
			"mudbound_dragon",
			"Vex667",
			"bluefoxstudios432",
			"SirAeron"
		].pick_random()
	)
	var supermarket_data: SupermarketGenData = SupermarketGenData.from_maze_data(maze_data)
	%GridMap.clear()
	for x: int in maze_dim.x:
		for y: int in maze_dim.y:
			var p: Vector2i = Vector2i(x,y)
			var pos_ground: Vector3i = Vector3i(p.x, 0, p.y)
			var pos_roof: Vector3i = Vector3i(p.x, 1, p.y)
			
			
			# supermarket walls
			var is_border: bool = maze_data.btm_boundaries.get_bitv(p)
			if is_border:
				var is_corner: bool = (p.x in [0, maze_dim.x-1]) and (p.y in [0, maze_dim.y-1])
				var wall_angle: float = 0.0
				if p.x == 0 and p.y != maze_dim.y-1: wall_angle = 0
				elif p.y == 0: wall_angle = -PI/2
				elif p.x == maze_dim.x-1: wall_angle = PI
				elif p.y == maze_dim.y-1: wall_angle = PI/2
				%GridMap.set_cell_item(
					pos_ground,
					Tiles.WALL_CORNER if is_corner else Tiles.WALL,
					get_orthogonal_idx(wall_angle)
				)
			
			# supermarket roof
			if generate_roof:
				%GridMap.set_cell_item(
					pos_roof,
					Tiles.ROOF_OPEN if (p.y+1) % 2 == 0 else Tiles.ROOF_CLOSED,
				)
			
			# supermarket ground floor
			if maze_data.btm_maze.get_bitv(p):
				# free tiles
				%GridMap.set_cell_item(pos_ground, 0)
				continue
			elif maze_data.btm_boundaries.get_bitv(p):
				# supermarket walls
				continue
			else:
				# supermarket shelves
				%GridMap.set_cell_item(
					pos_ground,
					PRODUCTS[maze_data.rng.randi() % PRODUCTS.size()],
					#1 if maze_data.rng.randf() > 0.5 else 2,
					get_random_orient_idx(supermarket_data.rng)
				)


func get_orthogonal_idx(angle: float) -> int:
	var new_basis = Basis(Vector3.UP, angle)
	return %GridMap.get_orthogonal_index_from_basis(new_basis)



func get_random_orient_idx(rng: RandomNumberGenerator) -> int:
	var angles = [0.0, PI * 0.5, PI, PI * 1.5]
	var angle = angles[rng.randi_range(0, 3)]
	var new_basis = Basis(Vector3.UP, angle)
	return %GridMap.get_orthogonal_index_from_basis(new_basis)
