extends CharacterBody3D

const SENSITIVITY = 0.01
const CROUCH_SPEED = 2
const WALK_SPEED = 5.0
const SPRINT_SPEED = 8
const WALK_HEIGHT = 1.8
const CROUCH_HEIGHT_REDUCTION = 1.2
const JUMP_VELOCITY = 4.5
const GROUND_CONTROL = 10
const AIR_CONTROL = 3
const FOV = 90
const FOV_SPRINT = 15
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
		
func _process(delta: float) -> void:
	var spell = Spell.new()
	spell.damageType = spell.spellDamageType

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if Input.is_action_pressed("Crouch"):
		speed = CROUCH_SPEED
	elif Input.is_action_pressed("Sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED

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
		
	t_bob += delta * velocity.length() * int(is_on_floor())
	
	Head.transform.origin.y = lerp(Head.transform.origin.y, WALK_HEIGHT - CROUCH_HEIGHT_REDUCTION * float(speed == CROUCH_SPEED), delta * 8)
	Camera.transform.origin = Vector3(cos(t_bob * BOB_FREQ /2) * BOB_AMP, sin(t_bob * BOB_FREQ) * BOB_AMP, 0)
	Camera.fov = lerp(Camera.fov, FOV + FOV_SPRINT * float(speed == SPRINT_SPEED && input_dir != Vector2.ZERO), delta * 8)

	move_and_slide()
