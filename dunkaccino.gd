extends Node3D



func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_released():
			return
		
		if event.keycode == KEY_BACKSLASH:
			if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			else:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
