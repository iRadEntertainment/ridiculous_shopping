extends Node3D
class_name SupermarketBlock


enum Type {
	PRODUCE,
	BAKERY,
	FREEZER,
	MILK,
}

@export var type: Type


func populate(rng: RandomNumberGenerator) -> void:
	for spawner: ItemSpawner in %spawners.get_children():
		spawner.block_type = type
		spawner.populate(rng)
