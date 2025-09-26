extends Control

@onready var continue_button = $VBoxContainer/ContinueButton

# Character selection UI
var character_select_ui: Control

func _ready():
	print("Main menu initialized")

	# Import legacy save data if exists
	if CharacterSlots and CharacterSlots.has_legacy_save_data():
		CharacterSlots.import_legacy_save_data()

	# Check if any save data exists to enable/disable continue button
	_update_continue_button()

	# Set initial game state
	if GameManager:
		GameManager.change_game_state(GameManager.GameState.MENU)
		print("Main menu setup completed")
	else:
		print("ERROR: GameManager not available")

func _update_continue_button():
	if not continue_button:
		print("ERROR: Continue button node not found")
		return

	var has_save_data = false

	# Check character slots system
	if CharacterSlots:
		var slots = CharacterSlots.get_all_slots()
		for slot in slots:
			if not slot.get("is_empty", true):
				has_save_data = true
				break

	# Fallback: check legacy save
	if not has_save_data:
		var save_file = FileAccess.open("user://player_data.json", FileAccess.READ)
		if save_file:
			has_save_data = true
			save_file.close()

	continue_button.disabled = not has_save_data
	if has_save_data:
		print("Save data found - Continue button enabled")
	else:
		print("No save data found - Continue button disabled")

func _on_new_game_button_pressed():
	print("MainMenu: NEW GAME button pressed")
	print("Opening character selection...")
	_show_character_select()

func _on_continue_button_pressed():
	print("MainMenu: CONTINUE button pressed")
	print("Continuing existing journey...")
	_show_character_select()

func _show_character_select():
	print("MainMenu: _show_character_select() called")
	print("MainMenu: Changing scene to CharacterSelectUI")
	var error = get_tree().change_scene_to_file("res://scenes/ui/CharacterSelectUI.tscn")
	if error != OK:
		print("ERROR: Failed to change scene to CharacterSelectUI - Error code: ", error)

# Character selection callbacks no longer needed since CharacterSelectUI handles scene transitions directly

func _on_multiplayer_button_pressed():
	print("Opening multiplayer menu...")
	var error = get_tree().change_scene_to_file("res://scenes/ui/MultiplayerMenu.tscn")
	if error != OK:
		print("ERROR: Failed to change scene to MultiplayerMenu - Error code: ", error)

func _on_settings_button_pressed():
	print("Opening settings...")
	# Create settings popup or scene
	pass

func _on_test_ui_button_pressed():
	print("Opening UI Test Environment...")
	var error = get_tree().change_scene_to_file("res://scenes/world/BiblicalWorld.tscn")
	if error != OK:
		print("ERROR: Failed to change scene to BiblicalWorld - Error code: ", error)
func _on_quit_button_pressed():
	print("Quitting game...")
	get_tree().quit()