extends CharacterBody3D

const SENSITIVITY = 0.01
const ANIM_SPEED = 10

const CROUCH_SPEED = 2.0
const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0

const EYE_HEIGHT = 0.5
const COLLIDER_HEIGHT = 4.5
const CROUCH_HEIGHT_REDUCTION = 0.9

const JUMP_VELOCITY = 4.5
const GROUND_CONTROL = 10.0
const AIR_CONTROL = 3.0

const FOV = 75.0
const FOV_SPRINT = 90.0

const BOB_FREQ = 2
const BOB_AMP = .08

var speed
var t_bob = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var Head = $Head
@onready var Camera = $Head/Camera3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		Head.rotate_y(-event.relative.x * SENSITIVITY)
		Camera.rotate_x(-event.relative.y * SENSITIVITY)
		Camera.rotation.x = clamp(Camera.rotation.x, -1.5, 1.5)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("Jump"): #and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if Input.is_action_pressed("Sprint") && Input.is_action_pressed("Forward"):
		SprintFOVSetup(delta)
	elif Input.is_action_pressed("Crouch"):
		CrouchFOVSetup(delta)
	else:
		WalkFOVSetup(delta)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("Left", "Right", "Forward", "Back")
	var direction = (Head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction and is_on_floor():
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	elif is_on_floor():
		velocity.x = lerp(velocity.x, direction.x * speed, delta * GROUND_CONTROL)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * GROUND_CONTROL)
		velocity.z = 0
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * AIR_CONTROL)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * AIR_CONTROL)
	
	t_bob += delta * velocity.length() * int(is_on_floor()) * int(!is_on_wall())
	Camera.transform.origin = Vector3(cos(t_bob * BOB_FREQ /2) * BOB_AMP, sin(t_bob * BOB_FREQ) * BOB_AMP, 0)

	move_and_slide()
	
func SprintFOVSetup(delta):
	speed = SPRINT_SPEED
	Head.transform.origin.y = lerp(Head.transform.origin.y, EYE_HEIGHT, delta * ANIM_SPEED)
	Camera.fov = lerp(Camera.fov, FOV_SPRINT, delta * ANIM_SPEED)
func CrouchFOVSetup(delta):
	speed = CROUCH_SPEED
	Head.transform.origin.y = lerp(Head.transform.origin.y, EYE_HEIGHT - CROUCH_HEIGHT_REDUCTION, delta * ANIM_SPEED)
	Camera.fov = lerp(Camera.fov, FOV, delta * ANIM_SPEED)
func WalkFOVSetup(delta):
	speed = WALK_SPEED
	Head.transform.origin.y = lerp(Head.transform.origin.y, EYE_HEIGHT, delta * ANIM_SPEED)
	Camera.fov = lerp(Camera.fov, FOV, delta * ANIM_SPEED)
