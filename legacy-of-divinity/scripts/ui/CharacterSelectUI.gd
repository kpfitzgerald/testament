extends Control

@onready var character_grid = $MainPanel/VBoxContainer/ScrollContainer/CharacterGrid
@onready var new_character_button = $MainPanel/VBoxContainer/ButtonContainer/NewCharacterButton
@onready var back_button = $MainPanel/VBoxContainer/ButtonContainer/BackButton

# Character slot items are created dynamically in code

# Signals no longer needed since we handle scene transitions directly
# signal character_selected(slot_id: int)
# signal new_character_requested
# signal back_to_menu

func _ready():
	print("=== CharacterSelectUI: _ready() START ===")
	print("CharacterSelectUI: _ready() called")
	var current_scene = get_tree().current_scene
	var scene_name = "None"
	if current_scene:
		scene_name = current_scene.name
	print("CharacterSelectUI: Scene tree current scene is: ", scene_name)

	# Basic test - just try to print something
	print("CharacterSelectUI: Basic test - script is running")

	# Connect buttons
	if new_character_button:
		new_character_button.pressed.connect(_on_new_character_pressed)
		print("CharacterSelectUI: New character button connected")
	else:
		print("ERROR: new_character_button not found")

	if back_button:
		back_button.pressed.connect(_on_back_pressed)
		print("CharacterSelectUI: Back button connected")
	else:
		print("ERROR: back_button not found")

	# Connect to character slots updates
	if CharacterSlots:
		CharacterSlots.character_slots_updated.connect(_refresh_character_list)
		print("CharacterSelectUI: Connected to character slots updates")
	else:
		print("ERROR: CharacterSlots not available")

	# Initial population
	print("CharacterSelectUI: Refreshing character list...")
	_refresh_character_list()
	print("CharacterSelectUI: Ready complete")

func _refresh_character_list():
	print("CharacterSelectUI: _refresh_character_list() called")

	# Clear existing items
	for child in character_grid.get_children():
		child.queue_free()
	print("CharacterSelectUI: Cleared existing character grid items")

	if not CharacterSlots:
		print("ERROR: CharacterSlots not available in _refresh_character_list")
		return

	# Create character slot items
	var slots = CharacterSlots.get_all_slots()
	print("CharacterSelectUI: Got ", slots.size(), " character slots")
	for slot in slots:
		var slot_item = _create_character_slot_item(slot)
		character_grid.add_child(slot_item)
		print("CharacterSelectUI: Added slot ", slot.get("slot_id", -1), " to grid")
	print("CharacterSelectUI: Character list refresh complete")

func _create_character_slot_item(slot_data: Dictionary) -> Control:
	# Create a simple panel container instead of layered controls
	var slot_panel = PanelContainer.new()
	slot_panel.custom_minimum_size = Vector2(0, 100)

	# Add colored background for debugging
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.3, 0.3, 0.6, 0.8)  # Blue-ish background
	style_box.border_width_left = 2
	style_box.border_width_right = 2
	style_box.border_width_top = 2
	style_box.border_width_bottom = 2
	style_box.border_color = Color.CYAN
	slot_panel.add_theme_stylebox_override("panel", style_box)

	# Main horizontal container inside the panel
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 15)
	slot_panel.add_child(hbox)

	var slot_id = slot_data.get("slot_id", 0)
	var is_unlocked = slot_data.get("is_unlocked", false)
	var is_empty = slot_data.get("is_empty", true)

	# Slot number label
	var slot_label = Label.new()
	slot_label.text = "SLOT %d" % (slot_id + 1)
	slot_label.custom_minimum_size = Vector2(80, 0)
	hbox.add_child(slot_label)

	if not is_unlocked:
		# Locked slot
		var locked_label = Label.new()
		locked_label.text = "🔒 LOCKED"
		locked_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(locked_label)
	elif is_empty:
		# Empty slot
		var empty_label = Label.new()
		empty_label.text = "Empty Slot"
		empty_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(empty_label)

		var create_button = Button.new()
		create_button.text = "CREATE"
		create_button.custom_minimum_size = Vector2(100, 40)
		create_button.pressed.connect(_on_create_character_in_slot.bind(slot_id))
		print("CharacterSelectUI: Created CREATE button for slot ", slot_id)
		hbox.add_child(create_button)
	else:
		# Character exists
		var info_vbox = VBoxContainer.new()
		info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(info_vbox)

		var name_label = Label.new()
		name_label.text = slot_data.get("character_name", "Unknown")
		name_label.add_theme_font_size_override("font_size", 16)
		info_vbox.add_child(name_label)

		var details_hbox = HBoxContainer.new()
		info_vbox.add_child(details_hbox)

		var class_label = Label.new()
		class_label.text = slot_data.get("character_class", "Unknown Class")
		details_hbox.add_child(class_label)

		var level_label = Label.new()
		level_label.text = "Level %d" % slot_data.get("level", 1)
		details_hbox.add_child(level_label)

		var gen_label = Label.new()
		gen_label.text = "Gen %d" % slot_data.get("generation", 1)
		details_hbox.add_child(gen_label)

		var last_played = slot_data.get("last_played", "")
		if last_played != "":
			var time_label = Label.new()
			time_label.text = "Last: " + last_played.split("T")[0]  # Just the date
			time_label.add_theme_font_size_override("font_size", 12)
			info_vbox.add_child(time_label)

		# Action buttons
		var button_hbox = HBoxContainer.new()
		hbox.add_child(button_hbox)

		var play_button = Button.new()
		play_button.text = "PLAY"
		play_button.custom_minimum_size = Vector2(80, 40)
		play_button.pressed.connect(_on_play_character.bind(slot_id))
		print("CharacterSelectUI: Created PLAY button for slot ", slot_id)
		button_hbox.add_child(play_button)

		var reset_button = Button.new()
		reset_button.text = "RESET"
		reset_button.custom_minimum_size = Vector2(80, 40)
		reset_button.pressed.connect(_on_reset_character.bind(slot_id))
		print("CharacterSelectUI: Created RESET button for slot ", slot_id)
		button_hbox.add_child(reset_button)

	return slot_panel

func _on_create_character_in_slot(slot_id: int):
	print("CharacterSelectUI: CREATE button clicked for slot ", slot_id)
	if CharacterSlots:
		CharacterSlots.select_character_slot(slot_id)
	print("CharacterSelectUI: Changing scene to CharacterCreation")
	var error = get_tree().change_scene_to_file("res://scenes/ui/CharacterCreation.tscn")
	if error != OK:
		print("ERROR: Failed to change scene to CharacterCreation - Error code: ", error)

func _on_play_character(slot_id: int):
	print("CharacterSelectUI: PLAY button clicked for slot ", slot_id)
	if CharacterSlots:
		CharacterSlots.select_character_slot(slot_id)
	print("CharacterSelectUI: Changing scene to GameWorld")
	var error = get_tree().change_scene_to_file("res://scenes/world/GameWorld.tscn")
	if error != OK:
		print("ERROR: Failed to change scene to GameWorld - Error code: ", error)

func _on_reset_character(slot_id: int):
	print("CharacterSelectUI: RESET button clicked for slot ", slot_id)
	# Show confirmation dialog
	var dialog = ConfirmationDialog.new()
	dialog.dialog_text = "Are you sure you want to reset this character? This action cannot be undone."
	dialog.title = "Reset Character"

	add_child(dialog)
	dialog.popup_centered()

	# Wait for user choice
	var result = await dialog.confirmed
	if result:
		if CharacterSlots:
			CharacterSlots.reset_character_slot(slot_id)
			_refresh_character_list()

	dialog.queue_free()

func _on_new_character_pressed():
	print("CharacterSelectUI: NEW CHARACTER button clicked")
	# Find first empty unlocked slot
	if CharacterSlots:
		var slots = CharacterSlots.get_all_slots()
		for slot in slots:
			if slot.get("is_unlocked", false) and slot.get("is_empty", true):
				CharacterSlots.select_character_slot(slot.get("slot_id", 0))
				print("CharacterSelectUI: Changing scene to CharacterCreation")
				var error = get_tree().change_scene_to_file("res://scenes/ui/CharacterCreation.tscn")
				if error != OK:
					print("ERROR: Failed to change scene to CharacterCreation - Error code: ", error)
				return

	# No empty slots available
	var dialog = AcceptDialog.new()
	dialog.dialog_text = "No empty character slots available. Please reset an existing character or unlock more slots."
	dialog.title = "No Available Slots"
	add_child(dialog)
	dialog.popup_centered()
	await dialog.confirmed
	dialog.queue_free()

func _on_back_pressed():
	print("CharacterSelectUI: BACK TO MENU button clicked")
	print("CharacterSelectUI: Changing scene to MainMenu")
	var error = get_tree().change_scene_to_file("res://scenes/main/MainMenu.tscn")
	if error != OK:
		print("ERROR: Failed to change scene to MainMenu - Error code: ", error)