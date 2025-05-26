@tool
extends Node3D
class_name Supermarket

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

const PRODUCTS = {
	Tiles.BAKERY: preload("res://instances/blocks/block_bakery.tscn"),
	Tiles.FRESH_PRODUCE: preload("res://instances/blocks/block_fresh_produce.tscn"),
	Tiles.FRIDGE_MILK: preload("res://instances/blocks/block_milk.tscn"),
	Tiles.FREEZERS: preload("res://instances/blocks/block_freezer.tscn"),
}


@export var is_intro: bool = false
@export_tool_button("DO IT!", "Button") var do_it: Callable = create_all
@export var generate_roof: bool = true


var supermarket_data: SupermarketGenData
var maze_dim: Vector2i = Vector2i(41,41)
var entrance_scene: SupermarketEntrance


func _ready() -> void:
	Mng.super_market = self
	entrance_scene = preload("res://instances/entrance.tscn").instantiate()
	entrance_scene.rotation.y = PI


func create_all(seed: String = "") -> void:
	create_data(seed)
	create_maze_3d()
	entrance_scene.change_title(supermarket_data.maze_seed)
	entrance_scene.move_trolley_to_start_pos(Mng.trolley)


func create_data(seed: String = "") -> void:
	var maze_data:  = MazeGen.generate_maze(
		maze_dim,
		seed if !seed.is_empty() else Mng.SEEDS.pick_random()
	)
	supermarket_data = SupermarketGenData.from_maze_data(maze_data)


func create_maze_3d() -> void:
	var old_entrance: SupermarketEntrance = find_child(&"entrance")
	if old_entrance:
		remove_child(old_entrance)
	
	%GridMap.clear()
	var is_entrance_placed: bool = false
	for x: int in maze_dim.x:
		for y: int in maze_dim.y:
			var p: Vector2i = Vector2i(x,y)
			if supermarket_data.entrance_area.has_point(p):
				if is_entrance_placed:
					continue
				
				var entr_pos2: Vector2 = supermarket_data.entrance_pos
				var entr_pos3: Vector3 = Vector3(entr_pos2.x, 0, entr_pos2.y)
				entr_pos3 *= 5.0
				entr_pos3 += Vector3(2.5, 0, 2.5)
				entrance_scene.position = entr_pos3
				add_child(entrance_scene)
				if Engine.is_editor_hint():
					entrance_scene.owner = self
				is_entrance_placed = true
				continue
			
			var pos_ground: Vector3i = Vector3i(p.x, 0, p.y)
			var pos_roof: Vector3i = Vector3i(p.x, 1, p.y)
			
			
			# supermarket walls
			var is_border: bool = supermarket_data.btm_boundaries.get_bitv(p)
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
			if generate_roof or !Engine.is_editor_hint():
				%GridMap.set_cell_item(
					pos_roof,
					Tiles.ROOF_OPEN if (p.y+1) % 2 == 0 else Tiles.ROOF_CLOSED,
				)
			
			# supermarket ground floor
			if supermarket_data.btm_maze.get_bitv(p):
				# free tiles
				%GridMap.set_cell_item(pos_ground, 0)
				continue
			elif supermarket_data.btm_boundaries.get_bitv(p):
				# supermarket walls
				continue
			else:
				# supermarket shelves
				var tile_type: int = PRODUCTS.keys()[supermarket_data.rng.randi() % PRODUCTS.size()]
				var block_angle: float = [0.0, PI/2, PI, -PI/2][supermarket_data.rng.randi_range(0, 3)]
				# placeholder only
				if Engine.is_editor_hint() or Mng.game.is_main_menu_background:
					%GridMap.set_cell_item(
						pos_ground,
						tile_type,
						#1 if maze_data.rng.randf() > 0.5 else 2,
						get_orthogonal_idx(block_angle)
					)
				# active elements for actual game
				else:
					var pos_block: Vector3 = Vector3(pos_ground)
					pos_block *= 5.0
					pos_block += Vector3(2.5, 0, 2.5)
					var block: SupermarketBlock = PRODUCTS[tile_type].instantiate()
					block.position = pos_block
					block.rotation.y = block_angle
					%blocks.add_child(block)
	
	if !Engine.is_editor_hint():
		for block: SupermarketBlock in %blocks.get_children():
			block.populate(supermarket_data.rng)


func get_orthogonal_idx(angle: float) -> int:
	var new_basis = Basis(Vector3.UP, angle)
	return %GridMap.get_orthogonal_index_from_basis(new_basis)



func get_random_orient_idx(rng: RandomNumberGenerator) -> int:
	var angles = [0.0, PI * 0.5, PI, PI * 1.5]
	var angle = angles[rng.randi_range(0, 3)]
	var new_basis = Basis(Vector3.UP, angle)
	return %GridMap.get_orthogonal_index_from_basis(new_basis)
