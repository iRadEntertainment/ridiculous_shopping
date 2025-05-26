extends CanvasLayer
class_name GUI


@onready var hud: Control = %HUD
@onready var timer: GameTimer = %Timer


func _ready() -> void:
	Mng.gui = self
	timer.reset_timer()
	Mng.cam.last_item_changed.connect(_on_last_item_changed)
	Mng.trolley.count_updated.connect(update_shopping_list)


func set_is_main_menu_background(val: bool) -> void:
	hud.visible = !val


func toggle_timer(val: bool) -> void:
	timer.reset_timer()
	timer.visible = val
	if val:
		timer.start_timer()


func _on_last_item_changed() -> void:
	var icon_empty: Texture2D = preload("res://ui/icon_crossair.png")
	var icon_interact: Texture2D = preload("res://ui/icon_interact.png")
	%reticle.texture = icon_empty if not Mng.cam.last_item else icon_interact


func toggle_shopping_list(val: bool) -> void:
	%shopping_list.visible = val
	if val:
		update_shopping_list()


func update_shopping_list() -> void:
	var text: String = ""
	for item_type: Item.Type in Mng.game.shopping_list.keys():
		var item_name: String = Item.Type.keys()[item_type].capitalize()
		var owned: int = 0
		if Mng.trolley:
			owned = Mng.trolley.in_cart.get(item_type, 0)
		var needed: int = Mng.game.shopping_list.get(item_type, 0)
		var entry: String = "%s %s/%s\n" % [item_name, owned, needed]
		text += entry
	%shopping_list.text = text
