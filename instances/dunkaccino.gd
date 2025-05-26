extends Node3D
class_name GameScene

@export var is_main_menu_background: bool = false
@onready var items: Node3D = %items
@onready var super_market: MazeScene = %SuperMarket


var time_elapsed: float = 0.0

var is_challenge_started: bool = false

signal challenge_started
signal challenge_ended


var shopping_list = {
	Item.Type.ANANAS: 1,
	#Item.Type.BANANA: 3,
	#Item.Type.DONUT: 1,
}


func _ready() -> void:
	setup_scene()


func setup_scene() -> void:
	Mng.bean.can_input = !is_main_menu_background
	Mng.toggle_mouse_capture(!is_main_menu_background)
	Mng.gui.set_is_main_menu_background(is_main_menu_background)
	Mng.gui.toggle_shopping_list(false)
	if !is_main_menu_background:
		Mng.game = self
		Mng.entrance.move_trolley_to_start_pos(Mng.trolley)
		Mng.entrance.lock_entrance(false)
		Mng.entrance.lock_exit(true)
		super_market.create_all()
		await get_tree().process_frame
		Mng.bean.move_to_marker(Mng.entrance.bean_spawn)
		Mng.gui.animate_wave_label("Get to the %s Super Market!" % super_market.supermarket_data.maze_seed)
	connect_signals()


func connect_signals() -> void:
	if is_main_menu_background:
		return
	Mng.entrance.player_entered.connect(start_challenge)
	Mng.entrance.player_exited.connect(end_challenge)


func start_challenge() -> void:
	Mng.gui.animate_wave_label("Get all the products!" % super_market.supermarket_data.maze_seed)
	Mng.gui.toggle_shopping_list(true)
	Mng.entrance.lock_entrance(true)
	Mng.gui.toggle_timer(true)


func end_challenge() -> void:
	Mng.gui.timer.stop_timer()


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_released():
			return
		
		if Mng.is_debug:
			if event.keycode == KEY_BACKSLASH:
				if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
					Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				else:
					Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
