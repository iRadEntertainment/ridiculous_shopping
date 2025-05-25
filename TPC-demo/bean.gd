extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 7.5
const SPRINT_MULTIPLIER = 0.75

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _process(delta: float) -> void:
	if Vector2(velocity.x, velocity.z).length() != 0:
		var angle: float = Vector2(velocity.x, velocity.z).angle_to(-Vector2(basis.z.x, basis.z.z))
		angle += PI/2
		$mesh.rotation.y = lerp_angle($mesh.rotation.y, angle, 5 * delta)
		$coll2.rotation.y = $mesh.rotation.y - PI/2


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
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
		%ThirdPersonCamera.apply_preset_shake(0)


func _unhandled_input(event):
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x*0.001)
		$mesh.rotate_y(event.relative.x*0.001)
	
	%SprintParticles.emitting = Input.is_action_pressed(&"sprint") and velocity.length() > 0.0 and is_on_floor_only()
