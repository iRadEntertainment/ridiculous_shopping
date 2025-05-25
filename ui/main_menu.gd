class_name MainMenu
extends Node

func _ready() -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	Aud.play_main_theme_music()

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://dunkaccino.tscn")
	
func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://ui/Options.tscn")
	
func _on_quit_pressed() -> void:
	get_tree().quit()
