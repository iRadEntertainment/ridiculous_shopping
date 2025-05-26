extends Node3D
class_name GameScene

@export var is_main_menu_background: bool = false

var time_elapsed: float = 0.0

var is_challenge_started: bool = false

signal challenge_started
signal challenge_ended


func _ready() -> void:
	if is_main_menu_background:
		Mng.gui.toggle_timer(false)
		return
	
	Mng.game = self
	Mng.trolley = find_child("trolley")
	Mng.bean = find_child("bean")
	Mng.bean.can_input = !is_main_menu_background
	setup_scene()
	if is_main_menu_background:
		Mng.bean.intro_scene_animation()
	else:
		Mng.toggle_mouse_capture(true)
		connect_signals()


func setup_scene() -> void:
	Mng.gui.toggle_timer(false)
	Mng.entrance.move_trolley_to_start_pos(Mng.trolley)
	Mng.entrance.lock_entrance(false)
	Mng.entrance.lock_exit(true)


func connect_signals() -> void:
	Mng.entrance.player_entered.connect(start_challenge)
	Mng.entrance.player_exited.connect(end_challenge)


func start_challenge() -> void:
	Mng.entrance.lock_entrance(true)
	Mng.gui.toggle_timer(true)


func end_challenge() -> void:
	Mng.toggle_mouse_capture(false)
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
