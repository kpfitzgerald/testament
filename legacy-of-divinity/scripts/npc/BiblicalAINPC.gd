extends CharacterBody3D
class_name BiblicalAINPC
# AI-powered biblical NPC that integrates with Testament's systems

@export_group("AI Character Settings")
@export var npc_name: String = "Moses"
@export_multiline var physical_description: String = "an elderly prophet with a long white beard, wearing simple robes"
@export_multiline var personality: String = "wise, patient, and deeply faithful. A leader who speaks with authority from God but remains humble"
@export_multiline var location_description: String = "near Mount Sinai in the wilderness"
@export_multiline var secret_knowledge: String = "knows the location of the Ark of the Covenant and remembers receiving the Ten Commandments"
@export var biblical_era: String = "Exodus period - around 1300 BC"
@export_multiline var relationships: String = "Brother of Aaron the High Priest, leader of the Israelites"

@export_group("Visual Settings")
@export var npc_sprite: Texture2D
@export var interaction_radius: float = 3.0
@export var show_name_label: bool = true

@export_group("Behavior Settings")
@export var can_move: bool = false
@export var patrol_points: Array[Vector3] = []
@export var movement_speed: float = 2.0

# Internal components
var interaction_area: Area3D
var visual_mesh: MeshInstance3D  # Changed from Sprite3D to MeshInstance3D
var name_label: Label3D
var collision_shape: CollisionShape3D

# AI dialogue state
var is_in_conversation: bool = false
var player_in_range: bool = false
var current_player: Node = null

# Signals
signal conversation_started(npc)
signal conversation_ended(npc)

func _ready():
	print("🏛️ ========================================")
	print("🏛️ MOSES DEBUG: _ready() called!")
	print("🏛️ MOSES DEBUG: NPC Name: ", npc_name)
	print("🏛️ MOSES DEBUG: Node position: ", global_position)
	print("🏛️ MOSES DEBUG: Node name: ", name)
	print("🏛️ ========================================")
	_setup_components()
	_connect_ai_signals()
	print("🏛️ MOSES DEBUG: Setup complete - Moses should be visible!")
	print("🏛️ MOSES DEBUG: Look for Moses at position ", global_position)
	print("🏛️ ========================================")

func _setup_components():
	print("🏛️ MOSES DEBUG: Setting up components...")

	# Find existing components (created in scene file)
	collision_shape = $CollisionShape3D if has_node("CollisionShape3D") else null
	visual_mesh = $VisualMesh if has_node("VisualMesh") else null

	print("🏛️ MOSES DEBUG: Collision shape found: ", collision_shape != null)
	print("🏛️ MOSES DEBUG: Visual mesh found: ", visual_mesh != null)

	# Create name label above character
	if show_name_label:
		print("🏛️ MOSES DEBUG: Creating name label...")
		name_label = Label3D.new()
		name_label.text = npc_name
		name_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		name_label.position.y = 3.0  # Made higher to be more visible
		name_label.modulate = Color.YELLOW
		name_label.outline_modulate = Color.BLACK
		name_label.outline_size = 2
		add_child(name_label)
		print("🏛️ MOSES DEBUG: Yellow name label created at Y=3.0")

	# Create interaction area for detecting player proximity
	print("BiblicalAINPC: Creating interaction area with radius ", interaction_radius)
	interaction_area = Area3D.new()
	interaction_area.name = "InteractionArea"

	var interaction_collision = CollisionShape3D.new()
	var sphere = SphereShape3D.new()
	sphere.radius = interaction_radius
	interaction_collision.shape = sphere
	interaction_collision.name = "InteractionCollision"

	interaction_area.add_child(interaction_collision)
	add_child(interaction_area)

	# Connect area signals
	interaction_area.body_entered.connect(_on_player_entered)
	interaction_area.body_exited.connect(_on_player_exited)
	print("BiblicalAINPC: Interaction area created and signals connected")

func _connect_ai_signals():
	if AIDialogue:
		AIDialogue.ai_response_ready.connect(_on_ai_response_ready)
		AIDialogue.ai_thinking_started.connect(_on_ai_thinking_started)
		AIDialogue.ai_thinking_finished.connect(_on_ai_thinking_finished)
		print("BiblicalAINPC: AI signals connected successfully")
	else:
		print("BiblicalAINPC: Warning - AIDialogue system not available")

func _input(event):
	# Simple, direct interaction handling
	if event.is_action_pressed("interact") and player_in_range and not is_in_conversation:
		print("🔑 MOSES: Starting conversation with E key!")
		start_conversation()
		get_viewport().set_input_as_handled()  # Prevent other systems from processing this input

func _on_player_entered(body):
	print("BiblicalAINPC: Body entered area: ", body.name, " (type: ", body.get_class(), ")")
	if body.has_method("is_player") or body.name == "Player":  # Check if it's the player
		player_in_range = true
		current_player = body
		print("BiblicalAINPC: PLAYER DETECTED! Entered interaction range of ", npc_name)

		# Show interaction prompt (fallback to console if UIManager not available)
		if UIManager and UIManager.has_method("show_interaction_prompt"):
			UIManager.show_interaction_prompt("Press E to talk to " + npc_name)
		else:
			print("BiblicalAINPC: Press E to talk to ", npc_name, " (UIManager not available)")
	else:
		print("BiblicalAINPC: Body ", body.name, " does not appear to be player")

func _on_player_exited(body):
	if body == current_player:
		player_in_range = false
		current_player = null
		print("BiblicalAINPC: Player left interaction range of ", npc_name)

		# Hide interaction prompt
		if UIManager and UIManager.has_method("hide_interaction_prompt"):
			UIManager.hide_interaction_prompt()
		else:
			print("BiblicalAINPC: UIManager.hide_interaction_prompt not available")

func start_conversation():
	print("BiblicalAINPC: start_conversation() called for ", npc_name)

	if not AIDialogue or not AIDialogue.is_ai_available():
		print("BiblicalAINPC: AI system not available for ", npc_name)
		# Fall back to traditional dialogue
		_start_traditional_dialogue()
		return

	print("BiblicalAINPC: Starting AI conversation with ", npc_name)
	is_in_conversation = true
	conversation_started.emit(self)

	# Hide interaction prompt
	if UIManager and UIManager.has_method("hide_interaction_prompt"):
		UIManager.hide_interaction_prompt()
	else:
		print("BiblicalAINPC: Interaction prompt hidden (UIManager method not available)")

	# Prepare NPC data for AI
	var npc_data = {
		"name": npc_name,
		"physical_description": physical_description,
		"personality": personality,
		"location_description": location_description,
		"secret_knowledge": secret_knowledge,
		"biblical_era": biblical_era,
		"relationships": relationships
	}

	# Start AI dialogue
	AIDialogue.start_dialogue(npc_data)

	# Show dialogue UI (fallback to console if not available)
	if UIManager and UIManager.has_method("start_ai_dialogue"):
		UIManager.start_ai_dialogue(npc_name)
		print("BiblicalAINPC: AI Dialogue UI opened for ", npc_name)
	else:
		print("BiblicalAINPC: STARTING AI CONVERSATION - ", npc_name, " is thinking...")

func _start_traditional_dialogue():
	# Fallback for when AI is not available
	print("BiblicalAINPC: Using traditional dialogue for ", npc_name)
	is_in_conversation = true

	var fallback_dialogue = "Peace be with you, traveler. I am " + npc_name + ". " + physical_description.split(",")[0] + "."
	print("BiblicalAINPC: Traditional dialogue: ", fallback_dialogue)

	# Try to show dialogue UI, but also print to console as backup
	if UIManager and UIManager.has_method("start_dialogue"):
		UIManager.start_dialogue(npc_name.to_lower())
		print("BiblicalAINPC: Traditional dialogue UI opened for ", npc_name)
	else:
		print("BiblicalAINPC: DIALOGUE - ", npc_name, ": ", fallback_dialogue)
		print("BiblicalAINPC: (Press any key to end conversation)")

func end_conversation():
	print("BiblicalAINPC: Ending conversation with ", npc_name)
	is_in_conversation = false
	conversation_ended.emit(self)

	# End AI dialogue
	if AIDialogue:
		AIDialogue.end_dialogue()

	# Hide dialogue UI
	if UIManager and UIManager.has_method("close_dialogue"):
		UIManager.close_dialogue()
		print("BiblicalAINPC: Dialogue UI closed for ", npc_name)
	else:
		print("BiblicalAINPC: Conversation ended with ", npc_name)

	# Force mouse capture to ensure proper input state
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	print("BiblicalAINPC: Forced mouse capture after conversation end")

	# Show interaction prompt again if player still in range
	if player_in_range:
		print("BiblicalAINPC: Player still in range, showing interaction prompt again")
		if UIManager and UIManager.has_method("show_interaction_prompt"):
			UIManager.show_interaction_prompt("Press E to talk to " + npc_name)
		else:
			print("BiblicalAINPC: Press E to talk to ", npc_name, " (player in range)")

func send_player_message(message: String):
	if AIDialogue and is_in_conversation:
		AIDialogue.send_player_dialogue(message)

# AI Response Callbacks
func _on_ai_response_ready(npc_name_from_ai: String, dialogue: String):
	if npc_name_from_ai == npc_name or AIDialogue.get_current_npc_name() == npc_name:
		print("BiblicalAINPC: Received AI response for ", npc_name, ": ", dialogue)

		# AI response will be handled by the DialogueUI system
		# The dialogue UI should receive and display the AI response
		print("BiblicalAINPC: AI RESPONSE - ", npc_name, ": ", dialogue)

func _on_ai_thinking_started():
	if is_in_conversation:
		print("BiblicalAINPC: AI is thinking...")
		# Thinking indicator will be handled by DialogueUI
		print("BiblicalAINPC: ", npc_name, " is thinking...")

func _on_ai_thinking_finished():
	if is_in_conversation:
		# AI response will be handled by _on_ai_response_ready
		pass

# Movement (if enabled)
func _physics_process(delta):
	if can_move and not is_in_conversation and patrol_points.size() > 0:
		_handle_movement(delta)

var current_patrol_index: int = 0
var movement_target: Vector3

func _handle_movement(delta):
	if patrol_points.size() == 0:
		return

	if movement_target == Vector3.ZERO:
		movement_target = patrol_points[current_patrol_index]

	var direction = (movement_target - global_position).normalized()
	velocity = direction * movement_speed

	if global_position.distance_to(movement_target) < 0.5:
		current_patrol_index = (current_patrol_index + 1) % patrol_points.size()
		movement_target = patrol_points[current_patrol_index]

	move_and_slide()

# Utility functions
func get_npc_data() -> Dictionary:
	return {
		"name": npc_name,
		"physical_description": physical_description,
		"personality": personality,
		"location_description": location_description,
		"secret_knowledge": secret_knowledge,
		"biblical_era": biblical_era,
		"relationships": relationships
	}

func set_sprite_texture(texture: Texture2D):
	npc_sprite = texture
	if visual_mesh:
		# Update the material texture for MeshInstance3D
		var material = visual_mesh.get_surface_override_material(0) as StandardMaterial3D
		if material:
			material.albedo_texture = texture