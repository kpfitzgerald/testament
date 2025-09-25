extends Control

@onready var continue_button = $VBoxContainer/ContinueButton

func _ready():
	# Check if save data exists to enable/disable continue button
	var save_file = FileAccess.open("user://player_data.json", FileAccess.READ)
	continue_button.disabled = (save_file == null)
	if save_file:
		save_file.close()

	# Set initial game state
	GameManager.change_game_state(GameManager.GameState.MENU)

func _on_new_game_button_pressed():
	print("Starting new character creation...")
	get_tree().change_scene_to_file("res://scenes/ui/CharacterCreation.tscn")

func _on_continue_button_pressed():
	print("Continuing existing journey...")
	# Load player data and go to world
	get_tree().change_scene_to_file("res://scenes/world/GameWorld.tscn")

func _on_multiplayer_button_pressed():
	print("Opening multiplayer menu...")
	get_tree().change_scene_to_file("res://scenes/ui/MultiplayerMenu.tscn")

func _on_settings_button_pressed():
	print("Opening settings...")
	# Create settings popup or scene
	pass

func _on_quit_button_pressed():
	print("Quitting game...")
	get_tree().quit()