extends RigidBody3D
class_name Trolley

@onready var marker_3d: Marker3D = $Marker3D

var bean: BeanPlayer:
	get():
		return Mng.bean

var items_collected: Array[Item] = []
var in_cart: Dictionary = {}

signal count_updated


func _ready() -> void:
	Mng.trolley = self


func _on_area_3d_trigger_body_entered(body: Node3D) -> void:
	if body is Item:
		if !items_collected.has(body):
			items_collected.append(body)
func _on_area_3d_trigger_body_exited(body: RigidBody3D) -> void:
	if body is Item and not body.freeze:
		if items_collected.has(body):
			items_collected.erase(body)


func check_item_in_cart() -> void:
	#print("Before: ", items_collected)
	for item: Item in items_collected:
		if item.freeze:
			continue
		item.reparent(self)
		item.set_deferred("freeze", true)
		add_collision_exception_with(item)
	#print("After: ", items_collected)
	if is_shopping_complete():
		Mng.gui.animate_wave_label("You got everything! Go to the checkout!")
	count_updated.emit()


func count_items() -> void:
	in_cart.clear()
	for item: Item in items_collected:
		if in_cart.has(item.type):
			in_cart[item.type] = in_cart[item.type] +1
		else:
			in_cart[item.type] = 1


func is_shopping_complete() -> bool:
	count_items()
	for key: Item.Type in Mng.game.shopping_list.keys():
		if !in_cart.has(key):
			return false
		elif in_cart[key] < Mng.game.shopping_list[key]:
			return false
	return true


func puff() -> void:
	for item in items_collected:
		item.queue_free()
	queue_free()
