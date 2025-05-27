# Mng.gd singleton
extends Node


const SEEDS = [
	"Rema 1000",
	"finisfine",
	"earend",
	"RyanKHawkins",
	"gridpapergames",
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
	"forgetfulprogrammer1976",
	"bluefoxstudio432",
	"Brainoid",
	"jotson",
]

# Game variables
var game: GameScene
var bean: BeanPlayer
var trolley: Trolley
var super_market: Supermarket
var entrance: SupermarketEntrance
var gui: GUI
var cam: ThirdPersonCamera

var is_debug: bool = false

var is_mouse_captured: bool:
	get():
		return Input.mouse_mode == Input.MOUSE_MODE_CAPTURED


func go_to_game_scene(seed: String = "") -> void:
	get_tree().change_scene_to_file("res://instances/dunkaccino.tscn")
	await get_tree().tree_changed
	game = get_tree().current_scene
	await game.ready
	game.setup_scene(seed)


func go_to_main_menu() -> void:
	get_tree().change_scene_to_file("res://ui/MainMenu.tscn")


func toggle_mouse_capture(val: bool) -> void:
	if val:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
