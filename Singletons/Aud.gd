# Aud.gd singleton
extends Node

const MASTER_BUS_INDEX := 0
const DEFAULT_VOLUME: float = -2

var is_game_muted := false
var master_db_volume := DEFAULT_VOLUME


func _ready() -> void:
	load_audio_settings()


func load_audio_settings() -> void:
	var config = ConfigFile.new()
	
	if config.load("user://audio_settings.cfg") == OK:
		master_db_volume = config.get_value("audio", "Master", DEFAULT_VOLUME)
	else:
		master_db_volume = DEFAULT_VOLUME


func save_audio_settings() -> void:
	var config = ConfigFile.new()
	config.set_value("audio", "Master", master_db_volume)
	
	config.save("user://audio_settings.cfg")


func play_main_theme_music() -> void:
	%MainStreamPlayer.play()
	if Mng.is_web_build:
		%MainStreamPlayer.finished.connect(play_main_theme_music)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("mute"):
		is_game_muted = !is_game_muted
		AudioServer.set_bus_mute(MASTER_BUS_INDEX, is_game_muted)
