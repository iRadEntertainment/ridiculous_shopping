extends CanvasLayer
class_name GUI


@onready var hud: Control = %HUD
@onready var timer: GameTimer = %Timer


func _ready() -> void:
	%lb_wave_notification.hide()
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


func set_reticle_interact(val: bool) -> void:
	%reticle.texture = preload("res://ui/icon_crossair.png") if not val else preload("res://ui/icon_interact.png")


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


func animate_wave_label(text: String) -> void:
	%lb_wave_notification.show()
	%lb_wave_notification.text = text
	%lb_wave_notification.modulate.a = 0
	%lb_wave_notification.anchor_left = 0
	%lb_wave_notification.anchor_right = 0
	var tw: Tween = create_tween()
	tw.set_trans(Tween.TRANS_SPRING)
	tw.set_ease(Tween.EASE_OUT)
	
	#tw.tween_property(Engine, "time_scale", 0.2, 1.0)
	tw.parallel().tween_property(%lb_wave_notification, "modulate:a", 1, 0.6)
	tw.parallel().tween_property(%lb_wave_notification, "anchor_right", 1, 0.6)
	tw.tween_interval(2.0)
	
	tw.tween_property(%lb_wave_notification, "modulate:a", 0, 0.6)
	tw.parallel().tween_property(%lb_wave_notification, "anchor_left", 1, 0.6)
	#tw.parallel().tween_property(Engine, "time_scale", 1.0, 1.0)
	tw.tween_callback(%lb_wave_notification.hide)
