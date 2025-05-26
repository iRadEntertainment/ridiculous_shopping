extends Node3D
class_name Door


@export var is_both_ways: bool = false
@export var autoclose_time: float = 3.0

var is_locked: bool = false

var door_1_pos: Vector3
var door_2_pos: Vector3

var tw: Tween
var tmr: Timer


func _ready() -> void:
	tmr = Timer.new()
	add_child(tmr)
	tmr.wait_time = autoclose_time
	tmr.timeout.connect(_toggle_door.bind(false))
	
	door_1_pos = %SlidingDoor1.position
	door_2_pos = %SlidingDoor2.position
	
	%coll_back.set_deferred(&"disabled", !is_both_ways)


func lock_door(val: bool) -> void:
	_toggle_door(false)
	%coll_front.set_deferred(&"disabled", val)
	%coll_back.set_deferred(&"disabled", val and is_both_ways)


func _toggle_door(toggle_open: bool) -> void:
	tmr.stop()
	if tw:
		tw.kill()
	
	var final_val_1: Vector3 = door_1_pos
	var final_val_2: Vector3 = door_2_pos
	
	if toggle_open:
		final_val_1 -= Vector3.FORWARD * 3.5
		final_val_2 -= Vector3.BACK * 3.5
	
	tw = create_tween()
	tw.set_ease(Tween.EASE_IN_OUT)
	tw.set_trans(Tween.TRANS_SPRING)
	tw.tween_property(%SlidingDoor1, ^"position", final_val_1, 0.4)
	tw.set_parallel().tween_property(%SlidingDoor2, ^"position", final_val_2, 0.4)


func _on_area_3d_front_body_entered(_body: Node3D) -> void:
	if !is_locked:
		_toggle_door(true)
func _on_area_3d_back_body_entered(_body: Node3D) -> void:
	if !is_locked and is_both_ways:
		_toggle_door(true)
func _on_area_3d_back_body_exited(_body: Node3D) -> void:
	tmr.start()
func _on_area_3d_front_body_exited(_body: Node3D) -> void:
	tmr.start()
