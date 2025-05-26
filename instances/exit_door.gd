extends Node3D
class_name ExitDoor


@export var autoclose_time: float = 3.0

var is_locked: bool = false

var door_pos: Vector3

var tw: Tween
var tmr: Timer


func _ready() -> void:
	tmr = Timer.new()
	add_child(tmr)
	tmr.wait_time = autoclose_time
	tmr.timeout.connect(_toggle_door.bind(false))
	
	door_pos = %SlidingDoor.position


func lock_door(val: bool) -> void:
	_toggle_door(false)
	%coll_area.disabled = val


func _toggle_door(toggle_open: bool) -> void:
	tmr.stop()
	if tw:
		tw.kill()
	
	var final_val: Vector3 = door_pos
	
	if toggle_open:
		final_val -= Vector3.LEFT * 3.5
	
	tw = create_tween()
	tw.set_ease(Tween.EASE_IN_OUT)
	tw.set_trans(Tween.TRANS_SPRING)
	tw.tween_property(%SlidingDoor, ^"position", final_val, 0.4)


func _on_area_3d_body_entered(_body: Node3D) -> void:
	if !is_locked:
		_toggle_door(true)
func _on_area_3d_body_exited(_body: Node3D) -> void:
	tmr.start()
