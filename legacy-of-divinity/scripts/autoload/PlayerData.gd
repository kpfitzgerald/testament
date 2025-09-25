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
var faith_points: int = 50
var wisdom_points: int = 50
var social_skills: int = 50

# Skill system
var skills: Dictionary = {
	"faith": {"level": 1, "experience": 0, "max_level": 100},
	"wisdom": {"level": 1, "experience": 0, "max_level": 100},
	"social": {"level": 1, "experience": 0, "max_level": 100},
	"crafting": {"level": 1, "experience": 0, "max_level": 100},
	"trading": {"level": 1, "experience": 0, "max_level": 100},
	"healing": {"level": 1, "experience": 0, "max_level": 100},
	"combat": {"level": 1, "experience": 0, "max_level": 100},
	"leadership": {"level": 1, "experience": 0, "max_level": 100}
}

# Attributes that affect gameplay
var attributes: Dictionary = {
	"strength": 10,
	"intelligence": 10,
	"charisma": 10,
	"spirit": 10,
	"endurance": 10
}

# Available skill points for distribution
var skill_points: int = 0
var attribute_points: int = 0

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
	skill_points += 3  # Gain skill points on level up
	attribute_points += 1  # Gain attribute points on level up
	print("Level up! New level: ", level)
	save_player_data()
	player_data_updated.emit()

func add_skill_experience(skill_name: String, amount: int):
	if not skills.has(skill_name):
		return false

	var skill = skills[skill_name]
	skill.experience += amount

	# Check for skill level up
	var required_exp = skill.level * 100  # Progressive requirement
	while skill.experience >= required_exp and skill.level < skill.max_level:
		skill.level += 1
		skill.experience -= required_exp
		required_exp = skill.level * 100
		print("Skill level up! ", skill_name, " is now level ", skill.level)

	# Update related stats when skills level up
	_update_stats_from_skills()
	save_player_data()
	player_data_updated.emit()
	return true

func _update_stats_from_skills():
	# Update character stats based on skill levels
	faith_points = 50 + (skills.faith.level * 5)
	wisdom_points = 50 + (skills.wisdom.level * 5)
	social_skills = 50 + (skills.social.level * 5)

func spend_skill_point(skill_name: String) -> bool:
	if skill_points <= 0 or not skills.has(skill_name):
		return false

	var skill = skills[skill_name]
	if skill.level >= skill.max_level:
		return false

	skill_points -= 1
	skill.level += 1
	_update_stats_from_skills()
	save_player_data()
	player_data_updated.emit()
	print("Skill point spent on ", skill_name, ". New level: ", skill.level)
	return true

func spend_attribute_point(attribute_name: String) -> bool:
	if attribute_points <= 0 or not attributes.has(attribute_name):
		return false

	attribute_points -= 1
	attributes[attribute_name] += 1
	_update_max_health_from_attributes()
	save_player_data()
	player_data_updated.emit()
	print("Attribute point spent on ", attribute_name, ". New value: ", attributes[attribute_name])
	return true

func _update_max_health_from_attributes():
	# Base health + endurance bonus
	var base_health = 100
	var endurance_bonus = (attributes.endurance - 10) * 5
	max_health = base_health + endurance_bonus
	if health > max_health:
		health = max_health

func get_skill_level(skill_name: String) -> int:
	if skills.has(skill_name):
		return skills[skill_name].level
	return 1

func get_skill_experience(skill_name: String) -> int:
	if skills.has(skill_name):
		return skills[skill_name].experience
	return 0

func get_skill_progress(skill_name: String) -> float:
	if not skills.has(skill_name):
		return 0.0

	var skill = skills[skill_name]
	var required_exp = skill.level * 100
	return float(skill.experience) / float(required_exp)

func get_character_power_level() -> int:
	var total_power = level * 10
	for skill_name in skills.keys():
		total_power += skills[skill_name].level
	for attr_name in attributes.keys():
		total_power += attributes[attr_name]
	return total_power

func get_class_bonus_skills() -> Array[String]:
	# Return skills that get bonuses based on selected class
	match selected_class:
		"Prophet":
			return ["faith", "wisdom"]
		"Warrior of God":
			return ["combat", "leadership"]
		"High Priest":
			return ["faith", "healing"]
		"Desert Hermit":
			return ["wisdom", "crafting"]
		"Royal Scribe":
			return ["wisdom", "social"]
		"Temple Musician":
			return ["faith", "social"]
		"Merchant Prince":
			return ["trading", "social"]
		"Pilgrim":
			return ["faith", "wisdom", "social"]  # Balanced class gets multiple bonuses
		_:
			return []

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
		"social_skills": social_skills,
		"skills": skills,
		"attributes": attributes,
		"skill_points": skill_points,
		"attribute_points": attribute_points,
		"selected_class": selected_class,
		"selected_background": selected_background,
		"character_appearance": character_appearance,
		"moral_choices": moral_choices,
		"completed_quests": completed_quests,
		"active_quests": active_quests,
		"ancestor_data": ancestor_data,
		"legacy_bonuses": legacy_bonuses,
		"inventory_data": InventorySystem.save_inventory_data() if InventorySystem else {},
		"dialogue_data": DialogueSystem.save_dialogue_data() if DialogueSystem else {}
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
			faith_points = save_data.get("faith_points", 50)
			wisdom_points = save_data.get("wisdom_points", 50)
			social_skills = save_data.get("social_skills", 50)
			skills = save_data.get("skills", {
				"faith": {"level": 1, "experience": 0, "max_level": 100},
				"wisdom": {"level": 1, "experience": 0, "max_level": 100},
				"social": {"level": 1, "experience": 0, "max_level": 100},
				"crafting": {"level": 1, "experience": 0, "max_level": 100},
				"trading": {"level": 1, "experience": 0, "max_level": 100},
				"healing": {"level": 1, "experience": 0, "max_level": 100},
				"combat": {"level": 1, "experience": 0, "max_level": 100},
				"leadership": {"level": 1, "experience": 0, "max_level": 100}
			})
			attributes = save_data.get("attributes", {
				"strength": 10,
				"intelligence": 10,
				"charisma": 10,
				"spirit": 10,
				"endurance": 10
			})
			skill_points = save_data.get("skill_points", 0)
			attribute_points = save_data.get("attribute_points", 0)
			selected_class = save_data.get("selected_class", "")
			selected_background = save_data.get("selected_background", "")
			character_appearance = save_data.get("character_appearance", {})
			var loaded_moral_choices = save_data.get("moral_choices", [])
			moral_choices.clear()
			for choice in loaded_moral_choices:
				moral_choices.append(choice)

			var loaded_completed_quests = save_data.get("completed_quests", [])
			completed_quests.clear()
			for quest in loaded_completed_quests:
				completed_quests.append(quest)

			var loaded_active_quests = save_data.get("active_quests", [])
			active_quests.clear()
			for quest in loaded_active_quests:
				active_quests.append(quest)

			var loaded_ancestor_data = save_data.get("ancestor_data", [])
			ancestor_data.clear()
			for ancestor in loaded_ancestor_data:
				ancestor_data.append(ancestor)
			legacy_bonuses = save_data.get("legacy_bonuses", {})

			# Load inventory data
			var inventory_data = save_data.get("inventory_data", {})
			if InventorySystem and not inventory_data.is_empty():
				InventorySystem.load_inventory_data(inventory_data)

			# Load dialogue data
			var dialogue_data = save_data.get("dialogue_data", {})
			if DialogueSystem and not dialogue_data.is_empty():
				DialogueSystem.load_dialogue_data(dialogue_data)

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