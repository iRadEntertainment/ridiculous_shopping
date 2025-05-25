# Aud.gd singleton
extends Node

const MASTER_BUS_INDEX := 0

var is_game_muted := false

func play_main_theme_music() -> void:
	%MainStreamPlayer.play()

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("mute"):
		is_game_muted = !is_game_muted
		AudioServer.set_bus_mute(MASTER_BUS_INDEX, is_game_muted)
		print(is_game_muted)
