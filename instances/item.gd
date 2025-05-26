extends RigidBody3D
class_name Item


enum Type{
	ANANAS,
	BANANA,
	DONUT,
}

@export var type: Type


func highlight(val: bool) -> void:
	%Interactible.highlight(val)
