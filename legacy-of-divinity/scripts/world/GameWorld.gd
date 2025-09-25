extends Node3D

@onready var stats_container = $UI/HUD/StatsPanel/StatsContainer
@onready var name_label = $UI/HUD/StatsPanel/StatsContainer/NameLabel
@onready var health_label = $UI/HUD/StatsPanel/StatsContainer/HealthLabel
@onready var alignment_label = $UI/HUD/StatsPanel/StatsContainer/AlignmentLabel
@onready var level_label = $UI/HUD/StatsPanel/StatsContainer/LevelLabel
@onready var generation_label = $UI/HUD/StatsPanel/StatsContainer/GenerationLabel
@onready var test_choice_button = $UI/HUD/TestChoiceButton
@onready var player = $Player

var moral_choice_dialog: Control

func _ready():
	print("GameWorld: Initializing...")
	GameManager.change_game_state(GameManager.GameState.PLAYING)
	# Initialize UI systems for this scene
	if UIManager:
		UIManager.initialize_ui_systems()
		print("GameWorld: UI systems initialized")

	# Connect signals
	PlayerData.player_data_updated.connect(update_hud)
	test_choice_button.pressed.connect(show_test_moral_choice)

	# Initial HUD update
	update_hud()
	print("GameWorld: Ready!")

func update_hud():
	name_label.text = PlayerData.player_name if PlayerData.player_name != "" else "Unnamed"
	health_label.text = "Health: " + str(PlayerData.health) + "/" + str(PlayerData.max_health)
	alignment_label.text = "Alignment: " + PlayerData.get_moral_alignment_text()
	level_label.text = "Level: " + str(PlayerData.level)
	generation_label.text = "Generation: " + str(PlayerData.generation)

func show_test_moral_choice():
	print("Test moral choice activated!")
	# For now just add some experience as a placeholder
	PlayerData.add_experience(25)
	print("Added 25 experience for testing")

func _input(event):
	# Basic movement for testing
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ESCAPE:
				get_tree().change_scene_to_file("res://scenes/main/MainMenu.tscn")
			KEY_C:
				show_test_moral_choice()
			KEY_H:
				# Show family history
				print(LegacySystem.get_family_history_summary())
			KEY_I:
				print("I key pressed - toggling inventory...")
				if UIManager:
					UIManager.toggle_inventory()
				else:
					print("ERROR: UIManager not available")
			KEY_T:
				print("T key pressed in GameWorld - adding test data...")
				if UIManager:
					UIManager.setup_test_data()
				else:
					print("ERROR: UIManager not available")
			KEY_1:
				print("Testing High Priest Aaron dialogue...")
				if UIManager:
					UIManager.test_dialogue_aaron()
			KEY_2:
				print("Testing Merchant Benjamin dialogue...")
				if UIManager:
					UIManager.test_dialogue_benjamin()
			KEY_3:
				print("Testing Prophetess Miriam dialogue...")
				if UIManager:
					UIManager.test_dialogue_miriam()
			KEY_F1:
				print("=== Current Game State ===")
				_print_game_state()

func _print_game_state():
	if PlayerData:
		print("Player: ", PlayerData.player_name)
		print("Class: ", PlayerData.selected_class)
		print("Level: ", PlayerData.level, " (", PlayerData.experience, " XP)")
		print("Health: ", PlayerData.health, "/", PlayerData.max_health)
		print("Faith: ", PlayerData.faith_points)
		print("Wisdom: ", PlayerData.wisdom_points)
		print("Social: ", PlayerData.social_skills)
		print("Moral Alignment: ", PlayerData.get_moral_alignment_text())

	if InventorySystem:
		print("Gold: ", InventorySystem.gold_coins)
		print("Items in inventory: ", InventorySystem.inventory_items.size())

	if WorldData:
		var world_summary = WorldData.get_world_state_summary()
		print("World Time: ", world_summary.get("time_of_day", 0), "h")
		print("Season: ", world_summary.get("season", "unknown"))
		print("Community Faith: ", world_summary.get("community_faith", 0))