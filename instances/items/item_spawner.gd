extends Node3D
class_name ItemSpawner

var block_type: SupermarketBlock.Type
var items_left: int = 0
var item_type: Item.Type
var mesh: ItemMesh

var meshes_pack = preload("res://instances/items/item_meshes.tscn")


func populate(rng: RandomNumberGenerator) -> void:
	if rng.randf() < 0.3:
		%coll.disabled = true
		return
	
	items_left = rng.randi_range(1, 3)
	var types: Array = item_types_from_block_type()
	item_type = types[rng.randi_range(0, types.size() - 1)]
	mesh = meshes_pack.instantiate()
	mesh.type = item_type
	add_child(mesh)


func item_types_from_block_type() -> Array:
	match block_type:
		SupermarketBlock.Type.PRODUCE: return Item.CAT_PRODUCE
		SupermarketBlock.Type.BAKERY: return Item.CAT_BAKERY
		SupermarketBlock.Type.FREEZER: return Item.CAT_FREEZER
		SupermarketBlock.Type.MILK: return Item.CAT_MILK
	return []


func spawn() -> void:
	if items_left < 1:
		%coll.disabled = true
		return
	items_left -= 1
	
	var item_inst: Item = Item.DIC_ITEM_SCN[item_type].instantiate()
	item_inst.position = $spawn_pos.global_position
	Mng.game.items.add_child(item_inst)
	
	if items_left < 1:
		%coll.disabled = true
		mesh.queue_free()
