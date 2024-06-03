extends CharacterBody3D

var speed
var recovering
var time_elapsed

const WALK_SPEED = 5.0
const SPRINT_SPEED = 10.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.002
const STAMINA_MAX = 500
const STAMINA_WAIT = 2.0

signal hit

#view bobbing
const BOB_FREQ = 2.0
const BOB_AMP = 0.08
var t_bob = 0.0

# fov variables
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var gravity = 9.8

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var stamina = $Control/StaminaBar

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	stamina.value = STAMINA_MAX
	recovering = false
	time_elapsed = 0.0

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-70), deg_to_rad(70))

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	# handle sprint
	#print(velocity, " ", velocity.is_zero_approx())
	#print("player position:", position)
	if Input.is_action_pressed("sprint") and is_on_floor() and stamina.value > 0:
		speed = SPRINT_SPEED
		if pythagorean_theorem(velocity) >= 1:
			stamina.value -= 35.0 * delta			
	elif speed == SPRINT_SPEED and not is_on_floor():
		if pythagorean_theorem(velocity) >= 1:
			stamina.value -= 35.0 * delta
	else:
		speed = WALK_SPEED
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
			t_bob += delta * velocity.length() * float(is_on_floor())
			camera.transform.origin = _headbob(t_bob)
		else:
			#velocity.x = move_toward(velocity.x, 0, SPEED) # using SPEED just makes it 0.0
			#velocity.z = move_toward(velocity.z, 0, SPEED)
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 5.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 5.0)
			t_bob = lerp(t_bob, 0.0, 1.0)
			camera.transform.origin.x = lerp(camera.transform.origin.x, 0.0, delta * 10.0)
			camera.transform.origin.y = lerp(camera.transform.origin.y, 0.0, delta * 10.0)
			
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 5.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 5.0)
	# head bob
	#t_bob += delta * velocity.length() * float(is_on_floor())
	#camera.transform.origin = _headbob(t_bob)
	if speed != SPRINT_SPEED:
		stamina.value += delta * 20.0
	#fov
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE + velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
		
	move_and_slide()

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 3) * BOB_AMP
	return pos

func pythagorean_theorem(velo) -> float:
	return sqrt(pow(velo.x, 2.0) + pow(velo.z, 2.0))
	

func _on_raymond_detector_body_entered(body):
	hit.emit()
