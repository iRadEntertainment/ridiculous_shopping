extends RigidBody3D
class_name Item


enum Type{
	ANANAS,
	BANANA,
	DONUT,
}

const CAT_PRODUCE = [
	Type.ANANAS,
	Type.BANANA,
]
const CAT_BAKERY = [
	Type.DONUT,
]
const CAT_FREEZER = [
	Type.DONUT,
]
const CAT_MILK = [
	Type.DONUT,
]


@export var type: Type


func highlight(val: bool) -> void:
	%Interactible.highlight(val)
	

func _on_body_entered(body: Node) -> void:
	if body is BeanPlayer:
		if body.velocity.length() > 1.0:
			apply_central_impulse(body.velocity)
