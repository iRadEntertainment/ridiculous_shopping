extends Node3D
class_name GameScene

@export var is_main_menu_background: bool = false


signal challenge_started
signal challenge_ended


func _ready() -> void:
	if is_main_menu_background:
		return
	
	Mng.game = self
	Mng.trolley = find_child("trolley")
	Mng.bean = find_child("bean")


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
