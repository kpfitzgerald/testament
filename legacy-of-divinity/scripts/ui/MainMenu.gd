extends Control

@onready var continue_button = $VBoxContainer/ContinueButton

func _ready():
	print("Main menu initialized")

	# Check if save data exists to enable/disable continue button
	var save_file = FileAccess.open("user://player_data.json", FileAccess.READ)
	if continue_button:
		continue_button.disabled = (save_file == null)
		if save_file:
			save_file.close()
			print("Save data found - Continue button enabled")
		else:
			print("No save data found - Continue button disabled")
	else:
		print("ERROR: Continue button node not found")

	# Set initial game state
	if GameManager:
		GameManager.change_game_state(GameManager.GameState.MENU)
		print("Main menu setup completed")
	else:
		print("ERROR: GameManager not available")

func _on_new_game_button_pressed():
	print("Starting new character creation...")
	var error = get_tree().change_scene_to_file("res://scenes/ui/CharacterCreation.tscn")
	if error != OK:
		print("ERROR: Failed to change scene to CharacterCreation - Error code: ", error)

func _on_continue_button_pressed():
	print("Continuing existing journey...")
	var error = get_tree().change_scene_to_file("res://scenes/world/BiblicalWorld.tscn")
	if error != OK:
		print("ERROR: Failed to change scene to GameWorld - Error code: ", error)

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
	var error = get_tree().change_scene_to_file("res://scenes/world/GameWorld.tscn")
	if error != OK:
		print("ERROR: Failed to change scene to GameWorld - Error code: ", error)
func _on_quit_button_pressed():
	print("Quitting game...")
	get_tree().quit()