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