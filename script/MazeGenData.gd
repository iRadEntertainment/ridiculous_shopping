extends Resource
class_name MazeGenData


@export var maze_dim: Vector2i
@export var maze_seed: String
var rng: RandomNumberGenerator

@export var btm_boundaries : BitMap
@export var btm_corners : BitMap
@export var btm_walls : BitMap
@export var btm_maze : BitMap
@export var list_boundaries : Array[Vector2i]
@export var list_corners : Array[Vector2i]
@export var list_walls : Array[Vector2i]
@export var list_maze : Array[Vector2i]
