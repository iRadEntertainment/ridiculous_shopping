# Mng.gd singleton
extends Node


const SEEDS = [
	"JustCovino",
	"Seano4D",
	"HypnoticK_Games",
	"FoolBox",
	"code807",
	"konradgryt",
	"mrdboy_",
	"ScaryPastry",
	"iheartfunnyboys",
	"mudbound_dragon",
	"Vex667",
	"bluefoxstudios432",
	"SirAeron",
	"robmblind",
	"gingerc4t",
	"Nekoht20",
]

# Game variables
var game: GameScene
var bean: BeanPlayer
var trolley: Trolley
var entrance: SupermarketEntrance
var gui: GUI

var is_debug: bool = true

var is_mouse_captured: bool:
	get():
		return Input.mouse_mode == Input.MOUSE_MODE_CAPTURED


func go_to_game_scene() -> void:
	get_tree().change_scene_to_file("res://instances/dunkaccino.tscn")

func go_to_main_menu() -> void:
	get_tree().change_scene_to_file("res://ui/MainMenu.tscn")


func toggle_mouse_capture(val: bool) -> void:
	if val:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
