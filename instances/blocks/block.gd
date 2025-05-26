extends Node3D
class_name SupermarketBlock

enum Type {
	FRESH_PRODUCE
}

@export var type: Type


func populate(rng: RandomNumberGenerator) -> void:
	for spawner: Item in %spawners.get_children():
		if rng.randf() < 0.7:
			continue
		for i: int in rng.randi_range(1, 3):
			pass
