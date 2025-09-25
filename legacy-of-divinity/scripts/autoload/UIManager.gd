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

signal ui_opened(ui_name)
signal ui_closed(ui_name)

func _ready():
	# Initialize UI systems when game is ready
	# Only initialize UI systems if not on main menu
	var scene_name = get_tree().current_scene.name if get_tree().current_scene else ""
	if scene_name != "MainMenu":
		call_deferred("_initialize_ui_systems")

# Public method to manually initialize UI systems when needed
func initialize_ui_systems():
	_initialize_ui_systems()

func _initialize_ui_systems():
	# Wait for the scene tree to be ready
	await get_tree().process_frame

	# Find the main game scene or create UI container
	var ui_container = _get_or_create_ui_container()
	if not ui_container:
		print("Warning: Could not create UI container")
		return

	# Instantiate UI scenes
	inventory_ui = INVENTORY_UI_SCENE.instantiate()
	skills_ui = SKILLS_UI_SCENE.instantiate()
	dialogue_ui = DIALOGUE_UI_SCENE.instantiate()

	# Add to scene tree
	ui_container.add_child(inventory_ui)
	ui_container.add_child(skills_ui)
	ui_container.add_child(dialogue_ui)

	print("UI systems initialized successfully")

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

	# Create new UI container
	if current_scene is Control:
		ui_container = Control.new()
		ui_container.name = "UIContainer"
		ui_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		current_scene.add_child(ui_container)
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

func close_dialogue():
	if dialogue_ui and dialogue_ui.visible:
		dialogue_ui.hide_dialogue()
		_clear_current_ui("dialogue")

# UI management functions
func _set_current_ui(ui: Control, ui_name: String):
	current_open_ui = ui
	ui_stack.push_back(ui)
	ui_opened.emit(ui_name)

func _clear_current_ui(ui_name: String):
	if current_open_ui:
		ui_stack.erase(current_open_ui)
		current_open_ui = null

	# If there are other UIs in the stack, show the previous one
	if not ui_stack.is_empty():
		current_open_ui = ui_stack.back()

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
				toggle_inventory()
			KEY_K:
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
		InventorySystem.add_item("daily_bread", 3)
		InventorySystem.add_item("blessed_water", 2)
		InventorySystem.add_item("shepherds_staff", 1)
		InventorySystem.add_item("simple_robe", 1)
		InventorySystem.gold_coins += 50

func add_test_experience():
	# Add some experience for testing progression
	if PlayerData:
		PlayerData.add_experience(150)  # Level up
		PlayerData.add_skill_experience("faith", 75)
		PlayerData.add_skill_experience("wisdom", 50)
		PlayerData.add_skill_experience("social", 25)

# Initialize test data for demonstration
func setup_test_data():
	add_test_items()
	add_test_experience()
	print("Test data added to character")