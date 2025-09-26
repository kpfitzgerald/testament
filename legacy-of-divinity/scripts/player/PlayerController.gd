extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.002

@onready var camera_pivot = $CameraPivot
@onready var camera = $CameraPivot/Camera3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	print("Player controller initialized - mouse captured mode")

func _input(event):
	if event is InputEventMouseMotion:
		# Don't process mouse camera control if UI is open
		if UIManager and UIManager.is_any_ui_open():
			return

		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera_pivot.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, deg_to_rad(-80), deg_to_rad(80))

	if event.is_action_pressed("ui_cancel"):
		# Don't toggle mouse mode if UI is handling the ESC key
		if UIManager and UIManager.is_any_ui_open():
			return

		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	# Always apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Don't process movement input if UI is open
	var ui_is_open = UIManager and UIManager.is_any_ui_open()

	if not ui_is_open:
		# Jump input
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		# Movement input
		var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
		var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
	else:
		# Stop horizontal movement when UI is open
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

# Used by NPCs to identify if this node is the player
func is_player() -> bool:
	return true