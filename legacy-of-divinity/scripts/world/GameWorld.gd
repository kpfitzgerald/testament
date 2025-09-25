extends Node3D

@onready var stats_container = $UI/HUD/StatsPanel/StatsContainer
@onready var name_label = $UI/HUD/StatsPanel/StatsContainer/NameLabel
@onready var health_label = $UI/HUD/StatsPanel/StatsContainer/HealthLabel
@onready var alignment_label = $UI/HUD/StatsPanel/StatsContainer/AlignmentLabel
@onready var level_label = $UI/HUD/StatsPanel/StatsContainer/LevelLabel
@onready var generation_label = $UI/HUD/StatsPanel/StatsContainer/GenerationLabel
@onready var test_choice_button = $UI/HUD/TestChoiceButton

var moral_choice_dialog: Control

func _ready():
	GameManager.change_game_state(GameManager.GameState.PLAYING)

	# Load moral choice dialog
	var choice_dialog_scene = preload("res://scenes/ui/MoralChoiceDialog.tscn")
	moral_choice_dialog = choice_dialog_scene.instantiate()
	add_child(moral_choice_dialog)

	# Connect signals
	PlayerData.player_data_updated.connect(update_hud)
	test_choice_button.pressed.connect(show_test_moral_choice)

	# Initial HUD update
	update_hud()

func update_hud():
	name_label.text = PlayerData.player_name if PlayerData.player_name != "" else "Unnamed"
	health_label.text = "Health: " + str(PlayerData.health) + "/" + str(PlayerData.max_health)
	alignment_label.text = "Alignment: " + PlayerData.get_moral_alignment_text()
	level_label.text = "Level: " + str(PlayerData.level)
	generation_label.text = "Generation: " + str(PlayerData.generation)

func show_test_moral_choice():
	var choice_data = {
		"id": "test_choice_" + str(Time.get_unix_time_from_system()),
		"title": "Help a Fellow Traveler?",
		"description": "You come across a fellow traveler who has fallen and injured their leg. They ask for your help to reach the nearby village. However, helping them would mean sharing your limited supplies and delaying your own important journey. What do you choose to do?",
		"choices": [
			{
				"text": "Help them immediately, sharing your supplies",
				"moral_value": 30,
				"consequences": {
					"message": "Your compassion moved both you and the traveler. Word of your kindness spreads.",
					"faith_change": 10,
					"wisdom_change": 5,
					"experience_change": 25,
					"health_change": -5  # Sharing supplies
				}
			},
			{
				"text": "Help them, but keep most of your supplies",
				"moral_value": 15,
				"consequences": {
					"message": "You helped while being prudent about your own needs. A balanced approach.",
					"faith_change": 5,
					"wisdom_change": 8,
					"experience_change": 20
				}
			},
			{
				"text": "Give directions but continue your journey",
				"moral_value": -5,
				"consequences": {
					"message": "You prioritized your mission, though you helped in a small way.",
					"wisdom_change": 3,
					"experience_change": 10,
					"faith_change": -3
				}
			},
			{
				"text": "Ignore them completely",
				"moral_value": -25,
				"consequences": {
					"message": "You hardened your heart and passed by. This choice weighs on your conscience.",
					"faith_change": -10,
					"health_change": -10,  # Guilt affects wellbeing
					"experience_change": 5
				}
			}
		]
	}

	moral_choice_dialog.show_moral_choice(choice_data)

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