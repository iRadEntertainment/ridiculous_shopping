class_name Options
extends Node

func _ready() -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	
	%Volume.value = db_to_linear(Aud.master_db_volume)

func _on_volume_value_changed(value: float) -> void:
	Aud.master_db_volume = linear_to_db(value)
	AudioServer.set_bus_volume_db(Aud.MASTER_BUS_INDEX, Aud.master_db_volume)
	Aud.save_audio_settings()

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://ui/MainMenu.tscn")
