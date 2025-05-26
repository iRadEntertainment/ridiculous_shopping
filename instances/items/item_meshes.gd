extends MeshInstance3D
class_name ItemMesh

var type: Item.Type

const MESHES = [
	preload("res://assets/meshes/props/mesh_pineapple.mesh"),
	preload("res://assets/meshes/props/mesh_banana.mesh"),
	preload("res://assets/meshes/props/mesh_watermelon.mesh"),
	preload("res://assets/meshes/props/mesh_frozen_fish_sticks.mesh"),
	preload("res://assets/meshes/props/mesh_frozen_peas.mesh"),
	preload("res://assets/meshes/props/mesh_frozen_pizza.mesh"),
]

func _ready() -> void:
	set_type()


func set_type() -> void:
	$DonutBody.visible = type == Item.Type.DONUT
	match type:
		Item.Type.ANANAS: mesh = MESHES[0]
		Item.Type.BANANA: mesh = MESHES[1]
		Item.Type.WATERMELON: mesh = MESHES[2]
		Item.Type.FROZEN_FISH: mesh = MESHES[3]
		Item.Type.FROZEN_PEAS: mesh = MESHES[4]
		Item.Type.FROZEN_PIZZA: mesh = MESHES[5]
		Item.Type.DONUT: mesh = null
