extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const SPRINT_MULTIPLIER = 0.75

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _process(delta: float) -> void:
	if velocity.length() != 0:
		$mesh.rotation.y = lerp($mesh.rotation.y, velocity.angle_to(-basis.z) + PI/2, 5 * delta)


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed(&"jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

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
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x*0.001)
	
	%SprintParticles.emitting = Input.is_action_pressed(&"sprint") and velocity.length() > 0.0 and is_on_floor_only()
