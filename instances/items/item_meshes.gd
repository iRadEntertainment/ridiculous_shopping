extends Node3D
class_name ItemMesh

var type: Item.Type


func _ready() -> void:
	set_type()


func set_type() -> void:
	for child in get_children():
		child.hide()
	match type:
		Item.Type.ANANAS: $PineappleMesh.show()
		Item.Type.BANANA: $BananaMesh.show()
		Item.Type.WATERMELON: $WatermelonMesh.show()
		Item.Type.FROZEN_FISH: $FrozenFishSticks.show()
		Item.Type.FROZEN_PEAS: $FrozenPeas.show()
		Item.Type.FROZEN_PIZZA: $FrozenPizza.show()
		Item.Type.DONUT: $DonutBody.show()
