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
	%pnl_select_seed.hide()
func go_option() -> void:
	%Options.show()
	%menu_buttons.hide()
	%pnl_select_seed.hide()
func go_to_select() -> void:
	%Options.hide()
	%menu_buttons.hide()
	%pnl_select_seed.show()


func _on_start_pressed() -> void:
	Mng.go_to_game_scene(%ln_supermarket_name.text)
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


func _on_btn_easter_egg_pressed() -> void:
	var url = "https://store.steampowered.com/app/2649940/Ridiculous_Shipping/"
	OS.shell_open(url)
func _on_btn_shuffle_pressed() -> void:
	%ln_supermarket_name.text = Mng.SEEDS.pick_random()
func _on_btn_open_select_pressed() -> void:
	go_to_select()
