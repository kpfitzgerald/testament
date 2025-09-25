extends Node

signal generation_advanced(new_generation)

# Legacy tracking
var family_tree: Dictionary = {}
var generational_bonuses: Dictionary = {}
var family_reputation: float = 0.0  # Community standing across generations
var divine_favor: int = 0  # Accumulated through righteous deeds

# Ancestral influences
var ancestral_skills: Array[String] = []
var ancestral_knowledge: Dictionary = {}
var family_curses: Array[Dictionary] = []
var family_blessings: Array[Dictionary] = []

func _ready():
	load_legacy_data()

func record_moral_choice(choice_data: Dictionary):
	# Record choice in current generation
	var current_gen = PlayerData.generation
	var player_id = PlayerData.player_id

	if not family_tree.has(current_gen):
		family_tree[current_gen] = {}

	if not family_tree[current_gen].has(player_id):
		family_tree[current_gen][player_id] = {
			"name": PlayerData.player_name,
			"moral_choices": [],
			"major_deeds": [],
			"final_alignment": 0
		}

	family_tree[current_gen][player_id]["moral_choices"].append(choice_data)

	# Update family reputation
	var choice_value = choice_data.get("value", 0)
	update_family_reputation(choice_value)

	save_legacy_data()

	# Notify UI systems that legacy data changed
	if choice_value != 0:
		print("Legacy updated: Family reputation now ", family_reputation)

func record_major_deed(deed_data: Dictionary):
	var current_gen = PlayerData.generation
	var player_id = PlayerData.player_id

	if family_tree.has(current_gen) and family_tree[current_gen].has(player_id):
		family_tree[current_gen][player_id]["major_deeds"].append(deed_data)

	# Major deeds have lasting impact
	var deed_value = deed_data.get("moral_impact", 0)
	update_divine_favor(deed_value * 2)  # Major deeds count double

	save_legacy_data()

func advance_generation(death_data: Dictionary):
	# Record final state of current character
	var current_gen = PlayerData.generation
	var player_id = PlayerData.player_id

	if family_tree.has(current_gen) and family_tree[current_gen].has(player_id):
		family_tree[current_gen][player_id]["final_alignment"] = PlayerData.moral_alignment
		family_tree[current_gen][player_id]["death_data"] = death_data

	# Calculate generational bonuses for next character
	calculate_generational_bonuses(current_gen)

	# Advance to next generation
	var new_generation = current_gen + 1
	generation_advanced.emit(new_generation)

	save_legacy_data()

func calculate_generational_bonuses(completed_generation: int):
	var generation_data = family_tree.get(completed_generation, {})
	var total_alignment = 0
	var character_count = 0

	# Analyze completed generation
	for player_id in generation_data.keys():
		var character_data = generation_data[player_id]
		total_alignment += character_data.get("final_alignment", 0)
		character_count += 1

		# Add skills from major deeds
		for deed in character_data.get("major_deeds", []):
			var skill = deed.get("unlocked_skill", "")
			if skill != "" and not ancestral_skills.has(skill):
				ancestral_skills.append(skill)

	# Calculate average alignment for generation
	if character_count > 0:
		var avg_alignment = total_alignment / character_count

		# Apply generational bonuses
		if avg_alignment >= 50:
			add_family_blessing("Righteous Lineage", "Your family's righteousness grants +10 Faith Points to descendants")
		elif avg_alignment <= -50:
			add_family_curse("Dark Heritage", "Your family's wickedness burdens descendants with -10 starting reputation")

func add_family_blessing(blessing_name: String, description: String):
	var blessing = {
		"name": blessing_name,
		"description": description,
		"generation_granted": PlayerData.generation,
		"active": true
	}
	family_blessings.append(blessing)
	print("Family Blessing Gained: ", blessing_name)

func add_family_curse(curse_name: String, description: String):
	var curse = {
		"name": curse_name,
		"description": description,
		"generation_cursed": PlayerData.generation,
		"active": true
	}
	family_curses.append(curse)
	print("Family Curse Incurred: ", curse_name)

func update_family_reputation(change: int):
	family_reputation += change / 10.0  # Smaller increments for family rep
	family_reputation = clamp(family_reputation, -100, 100)

func update_divine_favor(change: int):
	divine_favor += change
	divine_favor = clamp(divine_favor, -500, 500)

	# Check for divine interventions at extreme values
	if divine_favor >= 400:
		trigger_divine_blessing()
	elif divine_favor <= -400:
		trigger_divine_judgment()

func trigger_divine_blessing():
	# Implement divine blessing event
	print("Divine Blessing triggered! Your family has found great favor.")

func trigger_divine_judgment():
	# Implement divine judgment event
	print("Divine Judgment triggered! Your family faces consequences.")

func get_available_bonuses() -> Array[Dictionary]:
	var bonuses: Array[Dictionary] = []

	# Ancestral skill bonuses
	for skill in ancestral_skills:
		bonuses.append({
			"type": "skill",
			"name": skill,
			"description": "Inherited skill from ancestor"
		})

	# Family blessing bonuses
	for blessing in family_blessings:
		if blessing.active:
			bonuses.append({
				"type": "blessing",
				"name": blessing.name,
				"description": blessing.description
			})

	return bonuses

func save_legacy_data():
	var save_data = {
		"family_tree": family_tree,
		"generational_bonuses": generational_bonuses,
		"family_reputation": family_reputation,
		"divine_favor": divine_favor,
		"ancestral_skills": ancestral_skills,
		"ancestral_knowledge": ancestral_knowledge,
		"family_curses": family_curses,
		"family_blessings": family_blessings
	}

	var file = FileAccess.open("user://legacy_data.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()
		print("Legacy data saved")

func load_legacy_data():
	var file = FileAccess.open("user://legacy_data.json", FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()

		var json = JSON.new()
		var parse_result = json.parse(json_string)

		if parse_result == OK:
			var save_data = json.data
			family_tree = save_data.get("family_tree", {})
			generational_bonuses = save_data.get("generational_bonuses", {})
			family_reputation = save_data.get("family_reputation", 0)
			divine_favor = save_data.get("divine_favor", 0)
			ancestral_skills = save_data.get("ancestral_skills", [])
			ancestral_knowledge = save_data.get("ancestral_knowledge", {})
			family_curses = save_data.get("family_curses", [])
			family_blessings = save_data.get("family_blessings", [])

			print("Legacy data loaded")

func get_family_history_summary() -> String:
	var summary = "Family History:\n"

	for generation in family_tree.keys():
		summary += "Generation " + str(generation) + ":\n"
		var gen_data = family_tree[generation]

		for player_id in gen_data.keys():
			var character = gen_data[player_id]
			summary += "  - " + character.get("name", "Unknown") + " (Alignment: " + str(character.get("final_alignment", "Active")) + ")\n"

	return summary