class_name MainMenu
extends Node

func _ready() -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	Aud.play_main_theme_music()
	%VolumeSprite.frame += 1
	%Options.go_back.connect(go_main)
	go_main()


func go_main() -> void:
	%Options.hide()
	%menu_buttons.show()
func go_option() -> void:
	%Options.show()
	%menu_buttons.hide()



func _on_start_pressed() -> void:
	Mng.go_to_game_scene()
func _on_options_pressed() -> void:
	go_option()
func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_volume_sprite_frame_changed() -> void:
	if !Aud.is_game_muted:
		await get_tree().create_timer(0.2).timeout
		if %VolumeSprite.frame < 3:
			%VolumeSprite.frame += 1
		else:
			%VolumeSprite.frame = 0
