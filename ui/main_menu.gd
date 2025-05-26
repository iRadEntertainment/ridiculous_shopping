class_name MainMenu
extends Node

func _ready() -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	Aud.play_main_theme_music()
	%VolumeSprite.frame += 1
	
	%Timer.start_timer()


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://instances/dunkaccino.tscn")
	
	
func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://ui/Options.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_volume_sprite_frame_changed() -> void:
	if !Aud.is_game_muted:
		await get_tree().create_timer(0.2).timeout
		if %VolumeSprite.frame < 3:
			%VolumeSprite.frame += 1
		else:
			%VolumeSprite.frame = 0
