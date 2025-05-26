extends CanvasLayer
class_name GUI


@onready var hud: Control = %HUD
@onready var timer: GameTimer = %Timer


func _ready() -> void:
	Mng.gui = self
	timer.reset_timer()


func toggle_timer(val: bool) -> void:
	timer.reset_timer()
	timer.visible = val
	if val:
		timer.start_timer()
