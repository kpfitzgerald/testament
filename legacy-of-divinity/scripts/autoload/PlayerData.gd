extends Node

signal player_data_updated

# Player persistent data
var player_name: String = ""
var player_id: String = ""
var generation: int = 1
var moral_alignment: int = 0  # -100 (evil) to 100 (good)

# Character stats
var level: int = 1
var experience: int = 0
var health: int = 100
var max_health: int = 100
var faith_points: int = 0
var wisdom_points: int = 0

# Player choices and history
var moral_choices: Array[Dictionary] = []
var completed_quests: Array[String] = []
var active_quests: Array[Dictionary] = []

# Legacy data
var ancestor_data: Array[Dictionary] = []
var legacy_bonuses: Dictionary = {}

# Character creation
var selected_class: String = ""
var selected_background: String = ""
var character_appearance: Dictionary = {}

func _ready():
	load_player_data()

func create_new_character(character_data: Dictionary):
	player_name = character_data.get("name", "Unnamed")
	selected_class = character_data.get("class", "Pilgrim")
	selected_background = character_data.get("background", "Commoner")
	character_appearance = character_data.get("appearance", {})
	generation = character_data.get("generation", 1)

	# Generate unique player ID
	player_id = generate_player_id()

	# Set starting stats based on class and background
	apply_class_bonuses()
	apply_background_bonuses()

	save_player_data()
	player_data_updated.emit()

func apply_class_bonuses():
	match selected_class:
		"Prophet":
			faith_points += 20
			wisdom_points += 15
			moral_alignment += 10
		"Warrior of God":
			max_health += 30
			faith_points += 10
			moral_alignment += 5
		"Scholar":
			wisdom_points += 25
			experience += 50
		"Merchant":
			# Economic bonuses would go here
			pass
		"Pilgrim":
			# Balanced starter class
			faith_points += 10
			wisdom_points += 10
			max_health += 10

func apply_background_bonuses():
	match selected_background:
		"Noble":
			# Starting resources bonus
			pass
		"Commoner":
			# Hardy constitution
			max_health += 10
		"Priest":
			faith_points += 15
			moral_alignment += 15
		"Merchant":
			# Economic bonuses
			pass

func add_moral_choice(choice_data: Dictionary):
	moral_choices.append(choice_data)

	# Update alignment based on choice
	var choice_value = choice_data.get("value", 0)
	moral_alignment = clamp(moral_alignment + choice_value, -100, 100)

	save_player_data()
	player_data_updated.emit()

func add_experience(amount: int):
	experience += amount

	# Check for level up
	var required_exp = level * 100  # Simple formula
	if experience >= required_exp:
		level_up()

	player_data_updated.emit()

func level_up():
	level += 1
	max_health += 10
	health = max_health
	print("Level up! New level: ", level)
	save_player_data()

func save_player_data():
	var save_data = {
		"player_name": player_name,
		"player_id": player_id,
		"generation": generation,
		"moral_alignment": moral_alignment,
		"level": level,
		"experience": experience,
		"health": health,
		"max_health": max_health,
		"faith_points": faith_points,
		"wisdom_points": wisdom_points,
		"selected_class": selected_class,
		"selected_background": selected_background,
		"character_appearance": character_appearance,
		"moral_choices": moral_choices,
		"completed_quests": completed_quests,
		"active_quests": active_quests,
		"ancestor_data": ancestor_data,
		"legacy_bonuses": legacy_bonuses
	}

	var file = FileAccess.open("user://player_data.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()
		print("Player data saved")

func load_player_data():
	var file = FileAccess.open("user://player_data.json", FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()

		var json = JSON.new()
		var parse_result = json.parse(json_string)

		if parse_result == OK:
			var save_data = json.data
			player_name = save_data.get("player_name", "")
			player_id = save_data.get("player_id", "")
			generation = save_data.get("generation", 1)
			moral_alignment = save_data.get("moral_alignment", 0)
			level = save_data.get("level", 1)
			experience = save_data.get("experience", 0)
			health = save_data.get("health", 100)
			max_health = save_data.get("max_health", 100)
			faith_points = save_data.get("faith_points", 0)
			wisdom_points = save_data.get("wisdom_points", 0)
			selected_class = save_data.get("selected_class", "")
			selected_background = save_data.get("selected_background", "")
			character_appearance = save_data.get("character_appearance", {})
			moral_choices = save_data.get("moral_choices", [])
			completed_quests = save_data.get("completed_quests", [])
			active_quests = save_data.get("active_quests", [])
			ancestor_data = save_data.get("ancestor_data", [])
			legacy_bonuses = save_data.get("legacy_bonuses", {})

			print("Player data loaded")
		else:
			print("Failed to parse player data")

func generate_player_id() -> String:
	var timestamp = str(Time.get_unix_time_from_system())
	var random = str(randi() % 10000)
	return "player_" + timestamp + "_" + random

func get_moral_alignment_text() -> String:
	if moral_alignment >= 75:
		return "Righteous"
	elif moral_alignment >= 25:
		return "Good"
	elif moral_alignment >= -25:
		return "Neutral"
	elif moral_alignment >= -75:
		return "Questionable"
	else:
		return "Wicked"