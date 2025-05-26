extends RigidBody3D
class_name Item


enum Type{
	ANANAS,
	BANANA,
	WATERMELON,
	FROZEN_FISH,
	FROZEN_PEAS,
	FROZEN_PIZZA,
	DONUT,
}

const DIC_ITEM_SCN = {
	Type.ANANAS: preload("res://instances/items/item_ananas.tscn"),
	Type.BANANA: preload("res://instances/items/item_banana.tscn"),
	Type.WATERMELON: preload("res://instances/items/item_watermelon.tscn"),
	Type.FROZEN_FISH: preload("res://instances/items/item_frozen_fish.tscn"),
	Type.FROZEN_PEAS: preload("res://instances/items/item_frozen_peas.tscn"),
	Type.FROZEN_PIZZA: preload("res://instances/items/item_frozen_pizza.tscn"),
	Type.DONUT: preload("res://instances/items/item_donut.tscn"),
}

const CAT_PRODUCE = [
	Type.ANANAS,
	Type.BANANA,
	Type.WATERMELON,
]
const CAT_BAKERY = [
	Type.DONUT,
]
const CAT_FREEZER = [
	Type.FROZEN_FISH,
	Type.FROZEN_PEAS,
	Type.FROZEN_PIZZA,
]
const CAT_MILK = [
	Type.FROZEN_FISH,
	Type.FROZEN_PEAS,
	Type.FROZEN_PIZZA,
]


@export var type: Type


func highlight(val: bool) -> void:
	%Interactible.highlight(val)
	

func _on_body_entered(body: Node) -> void:
	if body is BeanPlayer:
		if body.velocity.length() > 1.0:
			apply_central_impulse(body.velocity)
