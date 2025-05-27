extends CanvasLayer
class_name GUI


@onready var hud: Control = %HUD
@onready var timer: GameTimer = %Timer
@onready var in_game_menu: Control = %in_game_menu


var is_shopping_list_visible: bool = false
var tw_shopping_list: Tween


func _ready() -> void:
	%lb_wave_notification.hide()
	Mng.gui = self
	timer.reset_timer()
	Mng.cam.last_item_changed.connect(_on_last_item_changed)
	Mng.trolley.count_updated.connect(update_shopping_list)
	
	%in_game_menu.hide()
	%win_screen.hide()
	
	%in_game_menu.visibility_changed.connect(_on_full_screen_visibility_changed)
	%win_screen.visibility_changed.connect(_on_full_screen_visibility_changed)


func _on_full_screen_visibility_changed() -> void:
	var is_on_screen: bool = %in_game_menu.is_visible_in_tree() or %win_screen.is_visible_in_tree()
	Mng.bean.can_input = !is_on_screen
	Mng.toggle_mouse_capture(!is_on_screen)
	if is_on_screen:
		timer.stop_timer()
	elif Mng.game.is_challenge_started:
		timer.start_timer()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"secondary"):
		toggle_shopping_list(!is_shopping_list_visible)
	if event.is_action_pressed(&"ui_cancel"):
		%in_game_menu.visible = !%in_game_menu.visible


func set_is_main_menu_background(val: bool) -> void:
	hud.visible = !val


func toggle_timer(val: bool) -> void:
	timer.reset_timer()
	timer.visible = val
	if val:
		timer.start_timer()


func open_win_screen() -> void:
	%lb_time_elapsed.text = timer.format_time(timer.time_passed)
	%lb_supermarket_name.text = "[jiggle]%s[/jiggle]" % [Mng.super_market.supermarket_data.maze_seed]
	%win_screen.show()


func set_reticle_interact(val: bool) -> void:
	%reticle.texture = preload("res://ui/icon_crossair.png") if not val else preload("res://ui/icon_interact.png")



func toggle_shopping_list(val: bool) -> void:
	is_shopping_list_visible = val
	if tw_shopping_list:
		tw_shopping_list.kill()
	
	var vert_anchor = 1.0 if val else 1.2
	var horiz_anchor = 1.0 if val else 1.35
	
	tw_shopping_list = create_tween()
	tw_shopping_list.set_ease(Tween.EASE_OUT)
	tw_shopping_list.set_trans(Tween.TRANS_SPRING)
	
	tw_shopping_list.set_parallel().tween_property(%shopping_list, ^"anchor_left", vert_anchor, 0.3)
	tw_shopping_list.set_parallel().tween_property(%shopping_list, ^"anchor_right", vert_anchor, 0.3)
	tw_shopping_list.set_parallel().tween_property(%shopping_list, ^"anchor_bottom", horiz_anchor, 0.3)
	tw_shopping_list.set_parallel().tween_property(%shopping_list, ^"anchor_top", horiz_anchor, 0.3)
	
	#%shopping_list.visible = val
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


func animate_wave_label(text: String, duration := 0.6) -> void:
	%lb_wave_notification.show()
	%lb_wave_notification.text = text
	%lb_wave_notification.modulate.a = 0
	%lb_wave_notification.anchor_left = 0
	%lb_wave_notification.anchor_right = 0
	var tw: Tween = create_tween()
	tw.set_trans(Tween.TRANS_SPRING)
	tw.set_ease(Tween.EASE_OUT)
	
	#tw.tween_property(Engine, "time_scale", 0.2, 1.0)
	tw.parallel().tween_property(%lb_wave_notification, "modulate:a", 1, duration)
	tw.parallel().tween_property(%lb_wave_notification, "anchor_right", 1, duration)
	tw.tween_interval(2.0)
	
	tw.tween_property(%lb_wave_notification, "modulate:a", 0, duration)
	tw.parallel().tween_property(%lb_wave_notification, "anchor_left", 1, duration)
	#tw.parallel().tween_property(Engine, "time_scale", 1.0, 1.0)
	tw.tween_callback(%lb_wave_notification.hide)


func _on_last_item_changed() -> void:
	var icon_empty: Texture2D = preload("res://ui/icon_crossair.png")
	var icon_interact: Texture2D = preload("res://ui/icon_interact.png")
	%reticle.texture = icon_empty if not Mng.cam.last_item else icon_interact


func _on_btn_main_menu_pressed() -> void:
	Mng.go_to_main_menu()
func _on_btn_retry_pressed() -> void:
	Mng.go_to_game_scene(Mng.game.supermarket_seed)
