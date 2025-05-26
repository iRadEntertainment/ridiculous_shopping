extends CharacterBody3D
class_name BeanPlayer


const SPEED = 5.0
const JUMP_VELOCITY = 9.5
const SPRINT_MULTIPLIER = 0.75


var trolley: Trolley:
	get():
		return Mng.trolley
var is_attached_to_trolley: bool = false
var tw_move_bean: Tween

var can_input: bool = true

signal item_dropped


func _ready() -> void:
	Mng.bean = self


func _process(delta: float) -> void:
	if !can_input:
		return
	if Vector2(velocity.x, velocity.z).length() != 0:
		var angle: float = Vector2(velocity.x, velocity.z).angle_to(-Vector2(basis.z.x, basis.z.z))
		angle += PI/2
		#rotation.y = lerp_angle(rotation.y, angle, 5 * delta)
		
		%mesh.rotation.y = lerp_angle(%mesh.rotation.y, angle, 5 * delta)
		%coll_climb_steps.rotation.y = %mesh.rotation.y - PI/2


func move_to_marker(node: Marker3D) -> void:
	if tw_move_bean:
			tw_move_bean.kill()
	tw_move_bean = create_tween()
	self.set_deferred(&"freeze", true)
	#target_tranform = target_tranform.scaled(%mesh.scale)
	tw_move_bean.set_ease(Tween.EASE_OUT)
	tw_move_bean.set_trans(Tween.TRANS_SPRING)
	tw_move_bean.tween_property(
		self,
		^"global_position",
		node.global_position,
		0.5
	)
	tw_move_bean.set_parallel().tween_property(
		%mesh,
		"global_rotation:y",
		node.global_rotation.y + PI/2,
		0.5
	)
	await tw_move_bean.finished
	self.set_deferred(&"freeze", false)


func attach_trolley(toggle: bool) -> void:
	if !can_input:
		return
	if toggle:
		await move_to_marker(Mng.trolley.marker_3d)
		Mng.trolley.check_item_in_cart()
	
	is_attached_to_trolley = !is_attached_to_trolley
	var trolley_path: String = %left_pin.get_path_to(trolley)
	%hinge_joint.set_deferred(&"node_b", trolley_path if toggle else "")
	#%left_pin.set_deferred(&"node_b", trolley_path if toggle else "")
	#%right_pin.set_deferred(&"node_b", trolley_path if toggle else "")
	%center_pin.set_deferred(&"node_b", trolley_path if toggle else "")


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# don't move while taking the cart
	if tw_move_bean:
		if tw_move_bean.is_running():
			return
	
	# Handle jump.
	if can_input:
		if Input.is_action_just_pressed(&"jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
			%sfx_yippie.stop()
			%sfx_yippie.pitch_scale = randf_range(0.85, 1.1)
			%sfx_yippie.play()
		
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var input_dir := Input.get_vector(&"left", &"right", &"forward", &"back")
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * SPEED * (1.0 + SPRINT_MULTIPLIER * int(Input.is_action_pressed(&"sprint")))
			velocity.z = direction.z * SPEED * (1.0 + SPRINT_MULTIPLIER * int(Input.is_action_pressed(&"sprint")))
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"interact"):
		if is_attached_to_trolley:
			attach_trolley(false)
		elif Mng.cam.is_pick_item:
			Mng.cam.pick_item(false)
			item_dropped.emit()
		elif Mng.cam.is_aiming_trolley:
			attach_trolley(true)
		elif Mng.cam.last_item:
			Mng.cam.pick_item(true)
		elif Mng.cam.item_spawner:
			Mng.cam.item_spawner.spawn()


func _unhandled_input(event):
	%SprintParticles.emitting = Input.is_action_pressed(&"sprint") \
								and velocity.length() > 0.0 \
								and is_on_floor_only()
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	if !can_input:
		return
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x*0.001)
		%mesh.rotate_y(event.relative.x*0.001)
	
