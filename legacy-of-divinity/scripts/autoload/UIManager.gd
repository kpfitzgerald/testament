extends Node

# UI Scene references
var inventory_ui: Control
var skills_ui: Control
var dialogue_ui: Control

# UI scenes to preload
const INVENTORY_UI_SCENE = preload("res://scenes/ui/InventoryUI.tscn")
const SKILLS_UI_SCENE = preload("res://scenes/ui/SkillsUI.tscn")
const DIALOGUE_UI_SCENE = preload("res://scenes/ui/DialogueUI.tscn")

# UI state tracking
var current_open_ui: Control = null
var ui_stack: Array[Control] = []
var test_data_applied: bool = false  # Track if test data was already applied

signal ui_opened(ui_name)
signal ui_closed(ui_name)

func _ready():
	# Initialize UI systems when game is ready
	# Only initialize UI systems if not on main menu
	var current_scene = get_tree().current_scene
	var scene_name = current_scene.name if current_scene else ""
	if scene_name != "MainMenu":
		call_deferred("_initialize_ui_systems")

# Public method to manually initialize UI systems when needed
func initialize_ui_systems():
	_initialize_ui_systems()

func _initialize_ui_systems():
	# Wait for the scene tree to be ready
	await get_tree().process_frame

	print("DEBUG: Attempting to initialize UI systems...")
	var scene_name = "null"
	if get_tree().current_scene:
		scene_name = get_tree().current_scene.name
	print("DEBUG: Current scene: ", scene_name)

	# Find the main game scene or create UI container
	var ui_container = _get_or_create_ui_container()
	if not ui_container:
		print("ERROR: Could not create UI container - UI systems will not work")
		return

	print("DEBUG: UI container found/created: ", ui_container.name)

	# Instantiate UI scenes
	inventory_ui = INVENTORY_UI_SCENE.instantiate()
	skills_ui = SKILLS_UI_SCENE.instantiate()
	dialogue_ui = DIALOGUE_UI_SCENE.instantiate()

	print("DEBUG: UI scenes instantiated successfully")

	# Add to scene tree
	ui_container.add_child(inventory_ui)
	ui_container.add_child(skills_ui)
	ui_container.add_child(dialogue_ui)

	print("DEBUG: UI scenes added to container")

	# Hide by default
	inventory_ui.visible = false
	skills_ui.visible = false
	dialogue_ui.visible = false

	print("UI systems initialized successfully - inventory_ui available: ", inventory_ui != null)

func _get_or_create_ui_container() -> Control:
	# Try to find existing UI container in the current scene
	var current_scene = get_tree().current_scene
	if not current_scene:
		return null

	# Look for existing UI container
	var ui_container = current_scene.get_node_or_null("UIContainer")
	if ui_container and ui_container is Control:
		return ui_container

	# Look for Canvas layer
	var canvas_layer = current_scene.get_node_or_null("CanvasLayer")
	if canvas_layer:
		ui_container = canvas_layer.get_node_or_null("UIContainer")
		if ui_container and ui_container is Control:
			return ui_container

	# Look for existing UI Control node in GameWorld scene
	var ui_node = current_scene.get_node_or_null("UI")
	if ui_node and ui_node is Control:
		return ui_node

	# Create new UI container if current scene is Control
	if current_scene is Control:
		ui_container = Control.new()
		ui_container.name = "UIContainer"
		ui_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		current_scene.add_child(ui_container)
		return ui_container

	# For Node3D scenes like GameWorld, try to create under existing UI node
	if ui_node:
		ui_container = Control.new()
		ui_container.name = "UIContainer"
		ui_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		ui_node.add_child(ui_container)
		return ui_container

	return null

# Inventory UI functions
func toggle_inventory():
	if not inventory_ui:
		print("Inventory UI not initialized")
		return

	if inventory_ui.visible:
		close_inventory()
	else:
		open_inventory()

func open_inventory():
	if not inventory_ui:
		return

	_close_current_ui()
	inventory_ui.show_inventory()
	_set_current_ui(inventory_ui, "inventory")

func close_inventory():
	if inventory_ui and inventory_ui.visible:
		inventory_ui.hide_inventory()
		_clear_current_ui("inventory")

# Skills UI functions
func toggle_skills():
	if not skills_ui:
		print("Skills UI not initialized")
		return

	if skills_ui.visible:
		close_skills()
	else:
		open_skills()

func open_skills():
	if not skills_ui:
		return

	_close_current_ui()
	skills_ui.show_skills()
	_set_current_ui(skills_ui, "skills")

func close_skills():
	if skills_ui and skills_ui.visible:
		skills_ui.hide_skills()
		_clear_current_ui("skills")

# Dialogue UI functions
func start_dialogue(npc_id: String):
	if not dialogue_ui:
		print("Dialogue UI not initialized")
		return

	_close_current_ui()
	dialogue_ui.show_dialogue(npc_id)
	_set_current_ui(dialogue_ui, "dialogue")

# AI Dialogue UI functions
func start_ai_dialogue(npc_name: String):
	if not dialogue_ui:
		print("Dialogue UI not initialized")
		return

	_close_current_ui()
	dialogue_ui.show_ai_dialogue(npc_name)
	_set_current_ui(dialogue_ui, "dialogue")
	print("UIManager: AI dialogue started for ", npc_name)

func close_dialogue():
	if dialogue_ui and dialogue_ui.visible:
		dialogue_ui.hide_dialogue()
		_clear_current_ui("dialogue")

# UI management functions
func _set_current_ui(ui: Control, ui_name: String):
	current_open_ui = ui
	ui_stack.push_back(ui)
	# Free mouse when opening any UI
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	print("UIManager: Mouse freed for UI interaction (", ui_name, ")")
	ui_opened.emit(ui_name)

func _clear_current_ui(ui_name: String):
	if current_open_ui:
		ui_stack.erase(current_open_ui)
		current_open_ui = null

	# If there are other UIs in the stack, show the previous one
	if not ui_stack.is_empty():
		var previous_ui = ui_stack.back()
		# Only assign if the previous UI is still valid
		if is_instance_valid(previous_ui):
			current_open_ui = previous_ui
			# Keep mouse free if other UI is still open
			print("UIManager: Switching to previous UI, mouse remains free")
		else:
			# Remove invalid UI from stack
			ui_stack.erase(previous_ui)
			current_open_ui = null

	# FORCE mouse to captured mode when all UI is closed - this fixes interaction
	if current_open_ui == null:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		print("UIManager: FORCING mouse captured mode to fix interaction")

	ui_closed.emit(ui_name)

func _close_current_ui():
	if current_open_ui:
		if current_open_ui == inventory_ui:
			close_inventory()
		elif current_open_ui == skills_ui:
			close_skills()
		elif current_open_ui == dialogue_ui:
			close_dialogue()

func close_all_ui():
	close_inventory()
	close_skills()
	close_dialogue()
	current_open_ui = null
	ui_stack.clear()

	# FORCE mouse to captured mode - this fixes interaction
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	print("UIManager: FORCING mouse captured - all UI closed (interaction fix)")

func is_any_ui_open() -> bool:
	return current_open_ui != null

func get_current_ui_name() -> String:
	if current_open_ui == inventory_ui:
		return "inventory"
	elif current_open_ui == skills_ui:
		return "skills"
	elif current_open_ui == dialogue_ui:
		return "dialogue"
	return ""

# Input handling
func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_I, KEY_TAB:
				# Don't open inventory if dialogue is active
				if get_current_ui_name() != "dialogue":
					toggle_inventory()
			KEY_K:
				# Don't open skills if dialogue is active
				if get_current_ui_name() != "dialogue":
					toggle_skills()
			KEY_ESCAPE:
				if is_any_ui_open():
					_close_current_ui()

# Test functions for development
func test_inventory():
	open_inventory()

func test_skills():
	open_skills()

func test_dialogue_aaron():
	start_dialogue("high_priest_aaron")

func test_dialogue_benjamin():
	start_dialogue("merchant_benjamin")

func test_dialogue_miriam():
	start_dialogue("prophet_miriam")

# Utility functions
func add_test_items():
	# Add some test items to inventory for demonstration
	if InventorySystem:
		print("Adding test items to inventory...")
		var added1 = InventorySystem.add_item("daily_bread", 3)
		var added2 = InventorySystem.add_item("blessed_water", 2)
		var added3 = InventorySystem.add_item("shepherds_staff", 1)
		var added4 = InventorySystem.add_item("simple_robe", 1)
		InventorySystem.gold_coins += 50
		print("Test items added: bread=", added1, " water=", added2, " staff=", added3, " robe=", added4)
		print("Current inventory size: ", InventorySystem.inventory_items.size())
	else:
		print("ERROR: InventorySystem not available for adding test items")

func add_test_experience():
	# Add some experience for testing progression
	if PlayerData:
		PlayerData.add_experience(150)  # Level up
		PlayerData.add_skill_experience("faith", 75)
		PlayerData.add_skill_experience("wisdom", 50)
		PlayerData.add_skill_experience("social", 25)

# Clear some inventory space for testing
func clear_inventory_space():
	if InventorySystem:
		print("Clearing inventory space for testing...")
		# Remove stackable items more aggressively
		InventorySystem.remove_item("daily_bread", 999)  # Remove all bread
		InventorySystem.remove_item("blessed_water", 999)  # Remove all water
		InventorySystem.remove_item("scroll_blank", 999)   # Remove all scrolls
		InventorySystem.remove_item("pottery_clay", 999)   # Remove all clay
		InventorySystem.remove_item("frankincense", 999)   # Remove all incense

		# Clear inventory completely if still too full
		if InventorySystem.inventory_items.size() > 45:
			print("Inventory still too full, clearing more items...")
			InventorySystem.inventory_items.clear()
			# Re-add just essential starting items
			InventorySystem.add_item("simple_robe", 1)
			InventorySystem.add_item("daily_bread", 2)

		print("Inventory cleared - now has ", InventorySystem.inventory_items.size(), " items")

# Initialize test data for demonstration
func setup_test_data():
	if test_data_applied:
		print("Test data already applied this session")
		return

	clear_inventory_space()  # Clear space first
	add_test_items()
	add_test_experience()
	test_data_applied = true
	print("Test data added to character")