@icon("./ThirdPersonCameraIcon.svg")
class_name ThirdPersonCamera extends Node3D

enum FOLLOW_TARGETS {
	NONE = 0,
	MOUSE = 1,
	PARENT = 2,
}

var last_item: Item
signal last_item_changed
var item_spawner: ItemSpawner
var is_pick_item: bool = false
var is_aiming_trolley: bool = false

@onready var _camera := $Camera
@onready var _camera_rotation_pivot = $RotationPivot
@onready var _camera_offset_pivot = $RotationPivot/OffsetPivot
@onready var _camera_spring_arm := $RotationPivot/OffsetPivot/CameraSpringArm
@onready var _camera_marker := $RotationPivot/OffsetPivot/CameraSpringArm/CameraMarker
@onready var _camera_shaker := $CameraShaker

##
@export var distance_from_pivot := 10.0 :
	set(value) :
		distance_from_pivot = value
		_set_when_ready(^"RotationPivot/OffsetPivot/CameraSpringArm", &"spring_length", value * distance_sprint_multiplier)
var distance_sprint_multiplier: float = 1.0

##
@export var pivot_offset := Vector2.ZERO

##
@export_range(-90.0, 90.0) var initial_dive_angle_deg := -20.0 :
	set(value) :
		initial_dive_angle_deg = clampf(value, tilt_lower_limit_deg, tilt_upper_limit_deg)

##
@export_range(-90.0, 90.0) var tilt_upper_limit_deg := 60.0

##
@export_range(-90.0, 90.0) var tilt_lower_limit_deg := -60.0

##
@export_range(1.0, 1000.0) var tilt_sensitiveness := 10.0

##
@export_range(1.0, 1000.0) var horizontal_rotation_sensitiveness := 10.0

##
@export_range(0.1, 1) var camera_speed := 0.1

##
@export var current : bool = false :
	set(value) :
		current = value
		_set_when_ready(^"Camera", &"current", value)

##
@export_group("follow")

##
@export var follow_target : FOLLOW_TARGETS = FOLLOW_TARGETS.NONE :
	set(value):
		follow_target = value
		notify_property_list_changed()

##
@export_range(0., 100.) var mouse_x_sensitiveness : float = 1

##
@export_range(0., 100.) var mouse_y_sensitiveness : float = 1

##
@export_group("Camera Shake")

@export var shake_presets: Array[CameraShakePreset]


# SpringArm3D properties replication
@export_category("SpringArm3D")
@export_flags_3d_render var spring_arm_collision_mask : int = 1 :
	set(value) :
		spring_arm_collision_mask = value
		_set_when_ready(^"RotationPivot/OffsetPivot/CameraSpringArm", &"collision_mask", value)
@export_range(0.0, 100.0, 0.01, "or_greater", "or_less", "hide_slider", "suffix:m") var spring_arm_margin : float = 0.01 :
	set(value) :
		spring_arm_margin = value
		_set_when_ready(^"RotationPivot/OffsetPivot/CameraSpringArm", &"margin", value)


# Camera3D properties replication
@export_category("Camera3D")
@export var keep_aspect : Camera3D.KeepAspect = Camera3D.KEEP_HEIGHT
@export_flags_3d_render var cull_mask : int = 1048575
@export var environment : Environment
@export var attributes : CameraAttributes
@export var doppler_tracking : Camera3D.DopplerTracking = Camera3D.DOPPLER_TRACKING_DISABLED
@export var projection : Camera3D.ProjectionType = Camera3D.PROJECTION_PERSPECTIVE
@export_range(1.0, 179.0, 0.1, "suffix:°") var FOV = 75.0
@export var near := 0.05
@export var far := 4000.0



var camera_tilt_deg := 0.
var camera_horizontal_rotation_deg := 0.


func _ready() -> void:
	Mng.cam = self
	_camera.top_level = true


func _set_when_ready(node_path : NodePath, property_name : StringName, value : Variant) :
	if not is_node_ready() :
		await ready
		get_node(node_path).set(property_name, value)
	else :
		get_node(node_path).set(property_name, value)


func _validate_property(property: Dictionary) -> void:
	match property.name:
		"mouse_x_sensitiveness":
			property.usage = PROPERTY_USAGE_NONE if follow_target!=FOLLOW_TARGETS.MOUSE else PROPERTY_USAGE_DEFAULT
		"mouse_y_sensitiveness":
			property.usage = PROPERTY_USAGE_NONE if follow_target!=FOLLOW_TARGETS.MOUSE and follow_target!=FOLLOW_TARGETS.PARENT else PROPERTY_USAGE_DEFAULT
		_:
			pass
		


func _process(delta: float) -> void:
	var target_fov: float = 75.0 if not (Input.is_action_pressed(&"sprint")) else 120.0
	FOV = lerp(FOV, target_fov, camera_speed * 0.2)
	var target_distance_mult: float = 0.15 if Input.is_action_pressed(&"sprint") else 1.0
	distance_sprint_multiplier = lerp(distance_sprint_multiplier, target_distance_mult, camera_speed)
	_set_when_ready(^"RotationPivot/OffsetPivot/CameraSpringArm", &"spring_length", distance_from_pivot * distance_sprint_multiplier)


func _physics_process(_delta):
	_check_raycast_interactibles()
	_update_camera_properties()
	if Engine.is_editor_hint() :
		_camera_marker.global_position = Vector3(0., 0., 1.).rotated(Vector3(1., 0., 0.), deg_to_rad(initial_dive_angle_deg)).rotated(Vector3(0., 1., 0.), self.global_rotation.y) * _camera_spring_arm.spring_length + _camera_spring_arm.global_position
		pass
	#_camera.global_position = _camera_marker.global_position
	tweenCameraToMarker()
	_camera_offset_pivot.global_position = _camera_offset_pivot.get_parent().to_global(Vector3(pivot_offset.x, pivot_offset.y, 0.0))
	_camera_rotation_pivot.global_rotation_degrees.x = initial_dive_angle_deg
	_camera_rotation_pivot.global_position = global_position
	_process_tilt_input()
	_process_horizontal_rotation_input()
	_update_camera_tilt()
	_update_camera_horizontal_rotation()
	_process_parent_rotation_follow()


func tweenCameraToMarker() :
	_camera.global_position = lerp(_camera.global_position, _camera_marker.global_position, camera_speed)

func _process_horizontal_rotation_input() :
	if follow_target == FOLLOW_TARGETS.PARENT :
		return
	if InputMap.has_action("tp_camera_right") and InputMap.has_action("tp_camera_left") :
		var camera_horizontal_rotation_variation = Input.get_action_strength("tp_camera_right") -  Input.get_action_strength("tp_camera_left")
		camera_horizontal_rotation_variation = camera_horizontal_rotation_variation * get_process_delta_time() * 30 * horizontal_rotation_sensitiveness
		camera_horizontal_rotation_deg += camera_horizontal_rotation_variation

func _process_parent_rotation_follow() :
	if follow_target != FOLLOW_TARGETS.PARENT :
		return
	_camera_rotation_pivot.global_rotation.y = self.global_rotation.y
	var vect_to_offset_pivot : Vector2 = (
		Vector2(_camera_offset_pivot.global_position.x, _camera_offset_pivot.global_position.z)
		-
		Vector2(_camera.global_position.x, _camera.global_position.z)
		).normalized()
	_camera.global_rotation.y = -Vector2(0., -1.).angle_to(vect_to_offset_pivot.normalized())

func _process_tilt_input() :
	if InputMap.has_action("tp_camera_up") and InputMap.has_action("tp_camera_down") :
		var tilt_variation = Input.get_action_strength("tp_camera_up") -  Input.get_action_strength("tp_camera_down")
		tilt_variation = tilt_variation * get_process_delta_time() * 5 * tilt_sensitiveness
		camera_tilt_deg = clamp(camera_tilt_deg + tilt_variation, tilt_lower_limit_deg - initial_dive_angle_deg, tilt_upper_limit_deg - initial_dive_angle_deg)



func _update_camera_tilt() :
	var tilt_final_val = clampf(initial_dive_angle_deg + camera_tilt_deg, tilt_lower_limit_deg, tilt_upper_limit_deg)
	var tween = create_tween()
	tween.tween_property(_camera, "global_rotation_degrees:x", tilt_final_val, 0.1)


func _update_camera_horizontal_rotation() :
	if follow_target == FOLLOW_TARGETS.PARENT :
		return
	var tween = create_tween()
	tween.tween_property(_camera_rotation_pivot, "global_rotation_degrees:y", camera_horizontal_rotation_deg * -1, 0.1).as_relative()
	camera_horizontal_rotation_deg = 0.0 # reset the value
	var vect_to_offset_pivot : Vector2 = (
		Vector2(_camera_offset_pivot.global_position.x, _camera_offset_pivot.global_position.z)
		-
		Vector2(_camera.global_position.x, _camera.global_position.z)
		).normalized()
	_camera.global_rotation.y = -Vector2(0., -1.).angle_to(vect_to_offset_pivot.normalized())


func apply_preset_shake(preset_number: int) -> void:
	_camera_shaker.apply_preset_shake(shake_presets[preset_number])



func _unhandled_input(event: InputEvent) -> void:
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	if follow_target == FOLLOW_TARGETS.MOUSE and event is InputEventMouseMotion:
		camera_horizontal_rotation_deg += event.relative.x * 0.1 * mouse_x_sensitiveness
		camera_tilt_deg -= event.relative.y * 0.07 * mouse_y_sensitiveness
		return
	if follow_target == FOLLOW_TARGETS.PARENT and event is InputEventMouseMotion:
		camera_tilt_deg -= event.relative.y * 0.07 * mouse_y_sensitiveness
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			distance_from_pivot = clamp(distance_from_pivot - 0.10, 0.10, 10.0)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			distance_from_pivot = clamp(distance_from_pivot + 0.10, 0.10, 10.0)


func _update_camera_properties() :
	_camera.keep_aspect = keep_aspect
	_camera.cull_mask = cull_mask
	_camera.doppler_tracking = doppler_tracking
	_camera.projection = projection
	_camera.fov = FOV
	_camera.near = near
	_camera.far = far
	if _camera.environment != environment :
		_camera.environment = environment
	if _camera.attributes != attributes :
		_camera.attributes = attributes


func _check_raycast_interactibles() -> void:
	Mng.gui.set_reticle_interact(%pick_ray.is_colliding())
	if !%pick_ray.is_colliding():
		is_aiming_trolley = false
		if last_item:
			last_item.highlight(false)
			last_item = null
			item_spawner = null
		return
	
	var obj = %pick_ray.get_collider()
	is_aiming_trolley = obj is Trolley
	if is_instance_valid(obj):
		if obj.get_parent() is ItemSpawner:
			item_spawner = obj.get_parent()
		else:
			item_spawner = null
	
		if last_item != obj and last_item:
			last_item.highlight(false)
		if obj is Item:
			last_item = obj
			obj.highlight(true)
	


func get_camera():
	return $Camera


func get_front_direction() :
	var dir : Vector3 = _camera_offset_pivot.global_position - _camera.global_position
	dir.y = 0.
	dir = dir.normalized()
	return dir

func get_back_direction() :
	return -get_front_direction()

func get_left_direction() :
	return get_front_direction().rotated(Vector3.UP, PI/2)

func get_right_direction() :
	return get_front_direction().rotated(Vector3.UP, -PI/2)


func pick_item(val: bool) -> void:
	is_pick_item = val
	
	if not val:
		%pin.node_b = ""
		if last_item:
			last_item.can_sleep = true
		return
	
	%pin.global_transform = last_item.global_transform
	%pin.node_b = %pin.get_path_to(last_item)
	last_item.can_sleep = false
	
