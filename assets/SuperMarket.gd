@tool
extends Node3D
class_name MazeScene

@export_tool_button("DO IT!", "Button") var do_it: Callable = create_maze_3d

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
			"ihearthfunnyboyz",
			"mudbound_dragon",
			"Vex667"
		].pick_random()
	)
	var supermarket_data: SupermarketGenData = SupermarketGenData.from_maze_data(maze_data)
	%GridMap.clear()
	for x: int in maze_dim.x:
		for y: int in maze_dim.y:
			var p: Vector2i = Vector2i(x,y)
			var pos: Vector3i = Vector3i(p.x, 0, p.y)
			if maze_data.btm_maze.get_bitv(p):
				# free tiles
				%GridMap.set_cell_item(pos, 0)
				continue
			elif maze_data.btm_boundaries.get_bitv(p):
				# supermarket walls
				continue
			else:
				# supermarket shelves
				%GridMap.set_cell_item(
					pos,
					[1,2,3,4][maze_data.rng.randi() % 4],
					#1 if maze_data.rng.randf() > 0.5 else 2,
					get_random_orient_idx(supermarket_data.rng)
				)


func get_random_orient_idx(rng: RandomNumberGenerator) -> int:
	var angles = [0.0, PI * 0.5, PI, PI * 1.5]
	var angle = angles[rng.randi_range(0, 3)]
	var new_basis = Basis(Vector3.UP, angle)
	return %GridMap.get_orthogonal_index_from_basis(new_basis)
