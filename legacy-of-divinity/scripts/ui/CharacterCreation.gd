extends Control

@onready var name_input = $ScrollContainer/VBoxContainer/HBoxContainer/LeftPanel/BasicInfo/BasicInfoContainer/NameInput
@onready var class_option = $ScrollContainer/VBoxContainer/HBoxContainer/LeftPanel/BasicInfo/BasicInfoContainer/ClassOption
@onready var background_option = $ScrollContainer/VBoxContainer/HBoxContainer/LeftPanel/BasicInfo/BasicInfoContainer/BackgroundOption
@onready var gender_option = $ScrollContainer/VBoxContainer/HBoxContainer/LeftPanel/Appearance/AppearanceContainer/GenderOption
@onready var age_option = $ScrollContainer/VBoxContainer/HBoxContainer/LeftPanel/Appearance/AppearanceContainer/AgeOption
@onready var hair_option = $ScrollContainer/VBoxContainer/HBoxContainer/LeftPanel/Appearance/AppearanceContainer/HairOption
@onready var eye_option = $ScrollContainer/VBoxContainer/HBoxContainer/LeftPanel/Appearance/AppearanceContainer/EyeOption
@onready var create_button = $ScrollContainer/VBoxContainer/ButtonContainer/CreateButton
@onready var description_label = $ScrollContainer/VBoxContainer/HBoxContainer/RightPanel/Description/DescriptionLabel
@onready var stats_labels = {
	"health": $ScrollContainer/VBoxContainer/HBoxContainer/RightPanel/Stats/StatsContainer/HealthStat,
	"faith": $ScrollContainer/VBoxContainer/HBoxContainer/RightPanel/Stats/StatsContainer/FaithStat,
	"wisdom": $ScrollContainer/VBoxContainer/HBoxContainer/RightPanel/Stats/StatsContainer/WisdomStat,
	"social": $ScrollContainer/VBoxContainer/HBoxContainer/RightPanel/Stats/StatsContainer/SocialStat,
	"alignment": $ScrollContainer/VBoxContainer/HBoxContainer/RightPanel/Stats/StatsContainer/AlignmentStat
}

var character_classes = {
	"Pilgrim": {
		"description": "A humble seeker of truth, traveling the sacred paths. Balanced and adaptable to any situation.",
		"bonuses": "+10 Faith, +10 Wisdom, +10 Health",
		"special": "Can learn any skill, starts with Travel Pack"
	},
	"Prophet": {
		"description": "Chosen vessel of divine revelation, blessed with visions and spiritual insight.",
		"bonuses": "+25 Faith, +20 Wisdom, +15 Moral Alignment",
		"special": "Can predict outcomes of moral choices"
	},
	"Warrior of God": {
		"description": "Holy crusader wielding divine authority, defender of the righteous.",
		"bonuses": "+35 Health, +15 Faith, +10 Moral Alignment",
		"special": "Combat bonuses when protecting innocents"
	},
	"High Priest": {
		"description": "Sacred intermediary between heaven and earth, master of ancient rituals.",
		"bonuses": "+30 Faith, +15 Wisdom, +20 Moral Alignment",
		"special": "Can perform blessing ceremonies for others"
	},
	"Desert Hermit": {
		"description": "Ascetic who has found wisdom in solitude, hardened by wilderness survival.",
		"bonuses": "+25 Health, +20 Wisdom, -5 Social Skills",
		"special": "Immune to environmental hazards"
	},
	"Royal Scribe": {
		"description": "Educated chronicler of divine law, keeper of sacred knowledge and texts.",
		"bonuses": "+30 Wisdom, +15 Faith, +10 Social Skills",
		"special": "Can read ancient languages and hidden meanings"
	},
	"Temple Musician": {
		"description": "Sacred artist who channels divine inspiration through song and instrument.",
		"bonuses": "+20 Faith, +15 Wisdom, +20 Social Skills",
		"special": "Music can influence NPC emotions and choices"
	},
	"Merchant Prince": {
		"description": "Wealthy trader who uses commerce to spread faith across distant lands.",
		"bonuses": "+15 Social Skills, +25 Starting Resources",
		"special": "Better prices, access to rare items"
	}
}

var character_backgrounds = {
	"Shepherd": {
		"description": "Raised tending flocks in the wilderness, learning patience and vigilance under the stars.",
		"bonuses": "+15 Health, +10 Wisdom, Survival Skills",
		"story": "The long nights watching sheep taught you to read the signs in nature and sky."
	},
	"Carpenter's Child": {
		"description": "Grew up in a craftsman's home, learning the dignity of honest work and creation.",
		"bonuses": "+10 Health, +15 Practical Skills, Tool Mastery",
		"story": "Your hands know the grain of wood and the weight of a well-made tool."
	},
	"Temple Orphan": {
		"description": "Raised within sacred walls after losing your family, devoted to divine service.",
		"bonuses": "+20 Faith, +15 Wisdom, Sacred Knowledge",
		"story": "The temple priests became your family, scripture your lullabies."
	},
	"Merchant's Heir": {
		"description": "Born into a trading family, you learned the ways of commerce and negotiation.",
		"bonuses": "+20 Social Skills, +30 Starting Coins, Trade Networks",
		"story": "Caravans and markets were your playground, every stranger a potential customer."
	},
	"Desert Nomad": {
		"description": "Child of the wandering tribes, hardened by sun and sand, wise in ancient ways.",
		"bonuses": "+20 Health, +10 Wisdom, Desert Survival",
		"story": "You know every oasis, every star that guides through the wasteland."
	},
	"Scribe's Apprentice": {
		"description": "Trained in letters and law, you can read the sacred texts and write with skill.",
		"bonuses": "+25 Wisdom, +15 Faith, Literacy, Law Knowledge",
		"story": "Ink stains your fingers, but knowledge fills your mind."
	},
	"Soldier's Child": {
		"description": "Raised in a military family, you understand discipline, honor, and sacrifice.",
		"bonuses": "+20 Health, +10 Combat Skills, Military Training",
		"story": "The sound of marching and the gleam of armor shaped your earliest memories."
	},
	"Royal Ward": {
		"description": "Raised in the royal court as a protected guest, you know politics and etiquette.",
		"bonuses": "+25 Social Skills, +20 Starting Resources, Court Connections",
		"story": "Palace intrigue and royal ceremonies taught you the subtle arts of influence."
	},
	"Fisherman's Daughter": {
		"description": "Born by the great waters, you understand patience, teamwork, and nature's bounty.",
		"bonuses": "+15 Health, +15 Wisdom, Fishing/Swimming, Weather Sense",
		"story": "The rhythm of waves and the silver flash of nets were your first teachers."
	},
	"Exile's Child": {
		"description": "Your family was cast out from their homeland, teaching you resilience and independence.",
		"bonuses": "+15 Health, +20 Survival Skills, Language Skills",
		"story": "Wandering strange lands taught you that home is what you carry within."
	}
}

var appearance_options = {
	"genders": ["Male", "Female"],
	"ages": ["Young Adult (20-30)", "Adult (30-45)", "Mature (45-60)", "Elder (60+)"],
	"hair_colors": ["Black", "Dark Brown", "Brown", "Light Brown", "Auburn", "Gray", "White", "Bald"],
	"eye_colors": ["Brown", "Dark Brown", "Hazel", "Green", "Blue", "Gray"]
}

func _ready():
	print("Character creation initialized")
	setup_options()
	setup_appearance()
	connect_signals()
	update_stats_preview()

func setup_options():
	if class_option:
		class_option.clear()

		# Use Array iteration instead of for loop
		var class_keys = character_classes.keys()
		var i = 0
		while i < class_keys.size():
			class_option.add_item(class_keys[i])
			i += 1
		print("Added character classes")

	if background_option:
		background_option.clear()

		# Use Array iteration instead of for loop
		var bg_keys = character_backgrounds.keys()
		var j = 0
		while j < bg_keys.size():
			background_option.add_item(bg_keys[j])
			j += 1
		print("Added character backgrounds")

func setup_appearance():
	if gender_option:
		gender_option.clear()
		for gender in appearance_options.genders:
			gender_option.add_item(gender)

	if age_option:
		age_option.clear()
		for age in appearance_options.ages:
			age_option.add_item(age)

	if hair_option:
		hair_option.clear()
		for hair in appearance_options.hair_colors:
			hair_option.add_item(hair)

	if eye_option:
		eye_option.clear()
		for eye in appearance_options.eye_colors:
			eye_option.add_item(eye)

func connect_signals():
	if class_option:
		class_option.item_selected.connect(_on_class_selected)
	if background_option:
		background_option.item_selected.connect(_on_background_selected)
	if gender_option:
		gender_option.item_selected.connect(_on_appearance_changed)
	if age_option:
		age_option.item_selected.connect(_on_appearance_changed)
	if hair_option:
		hair_option.item_selected.connect(_on_appearance_changed)
	if eye_option:
		eye_option.item_selected.connect(_on_appearance_changed)

func _on_class_selected(_index: int):
	update_description()

func _on_background_selected(_index: int):
	update_description()

func update_description():
	if not description_label:
		return

	var desc_text = generate_character_backstory()

	# Show class information
	if class_option and class_option.selected >= 0:
		var selected_class = class_option.get_item_text(class_option.selected)
		if character_classes.has(selected_class):
			desc_text += "📿 CLASS: " + selected_class.to_upper() + "\n"
			desc_text += character_classes[selected_class]["description"] + "\n\n"
			desc_text += "⚡ Bonuses: " + character_classes[selected_class]["bonuses"] + "\n"
			desc_text += "✨ Special: " + character_classes[selected_class]["special"] + "\n\n"

	# Show background information
	if background_option and background_option.selected >= 0:
		var selected_background = background_option.get_item_text(background_option.selected)
		if character_backgrounds.has(selected_background):
			desc_text += "🏠 BACKGROUND: " + selected_background.to_upper() + "\n"
			desc_text += character_backgrounds[selected_background]["description"] + "\n\n"
			desc_text += "⚡ Bonuses: " + character_backgrounds[selected_background]["bonuses"] + "\n"
			desc_text += "📜 Your Story: " + character_backgrounds[selected_background]["story"] + "\n"

	description_label.text = desc_text
	update_stats_preview()

var creating_character = false

func _on_create_button_pressed():
	if creating_character:
		print("Character creation already in progress...")
		return

	creating_character = true
	print("Create Character Button Pressed")

	if not name_input:
		print("ERROR: name_input not found")
		creating_character = false
		return

	var character_name = name_input.text.strip_edges()
	if character_name == "":
		print("Name is required!")
		creating_character = false
		return

	var selected_class = "Pilgrim"
	if class_option and class_option.selected >= 0:
		selected_class = class_option.get_item_text(class_option.selected)

	var selected_background = "Commoner"
	if background_option and background_option.selected >= 0:
		selected_background = background_option.get_item_text(background_option.selected)

	print("Creating character: ", character_name, " (", selected_class, "/", selected_background, ")")

	var character_data = {
		"name": character_name,
		"class": selected_class,
		"background": selected_background,
		"generation": 1,
		"appearance": {
			"gender": gender_option.get_item_text(gender_option.selected) if gender_option and gender_option.selected >= 0 else "Male",
			"age": age_option.get_item_text(age_option.selected) if age_option and age_option.selected >= 0 else "Adult (30-45)",
			"hair": hair_option.get_item_text(hair_option.selected) if hair_option and hair_option.selected >= 0 else "Brown",
			"eyes": eye_option.get_item_text(eye_option.selected) if eye_option and eye_option.selected >= 0 else "Brown"
		}
	}

	if PlayerData:
		PlayerData.create_new_character(character_data)
		print("Character created successfully")

		# Update character slot metadata
		if CharacterSlots:
			var current_slot = CharacterSlots.get_current_slot()
			CharacterSlots.create_character_in_slot(current_slot, character_name, selected_class)

	get_tree().change_scene_to_file("res://scenes/world/BiblicalWorld.tscn")

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main/MainMenu.tscn")

func _on_appearance_changed(_index: int):
	update_appearance_preview()

func update_stats_preview():
	if not stats_labels:
		return

	var base_stats = {
		"health": 100,
		"faith": 50,
		"wisdom": 50,
		"social": 50,
		"alignment": "Neutral"
	}

	# Apply class bonuses
	if class_option and class_option.selected >= 0:
		var selected_class = class_option.get_item_text(class_option.selected)
		if character_classes.has(selected_class):
			var bonuses = character_classes[selected_class]["bonuses"]
			parse_bonuses(bonuses, base_stats)

	# Apply background bonuses
	if background_option and background_option.selected >= 0:
		var selected_background = background_option.get_item_text(background_option.selected)
		if character_backgrounds.has(selected_background):
			var bonuses = character_backgrounds[selected_background]["bonuses"]
			parse_bonuses(bonuses, base_stats)

	# Update stat labels
	stats_labels["health"].text = "❤️ Health: " + str(base_stats["health"])
	stats_labels["faith"].text = "✨ Faith: " + str(base_stats["faith"])
	stats_labels["wisdom"].text = "🧠 Wisdom: " + str(base_stats["wisdom"])
	stats_labels["social"].text = "🗣️ Social: " + str(base_stats["social"])
	stats_labels["alignment"].text = "⚖️ Moral Alignment: " + str(base_stats["alignment"])

func parse_bonuses(bonus_text: String, stats: Dictionary):
	var parts = bonus_text.split(", ")
	for part in parts:
		part = part.strip_edges()
		if part.begins_with("+"):
			var value_match = part.substr(1).split(" ")
			if value_match.size() >= 2:
				var amount = int(value_match[0])
				var stat_name = value_match[1].to_lower()
				if stats.has(stat_name):
					stats[stat_name] += amount
				elif stat_name == "moral" and value_match.size() >= 3:
					stats["alignment"] = "Good"
		if part.begins_with("-"):
			var value_match = part.substr(1).split(" ")
			if value_match.size() >= 2:
				var amount = int(value_match[0])
				var stat_name = value_match[1].to_lower()
				if stats.has(stat_name):
					stats[stat_name] -= amount

func update_appearance_preview():
	var appearance_text = "Current Appearance: "

	if gender_option and gender_option.selected >= 0:
		appearance_text += gender_option.get_item_text(gender_option.selected)

	if age_option and age_option.selected >= 0:
		appearance_text += " " + age_option.get_item_text(age_option.selected)

	if hair_option and hair_option.selected >= 0:
		appearance_text += ", " + hair_option.get_item_text(hair_option.selected) + " hair"

	if eye_option and eye_option.selected >= 0:
		appearance_text += ", " + eye_option.get_item_text(eye_option.selected) + " eyes"

	print(appearance_text)

func _on_random_button_pressed():
	if name_input:
		var biblical_names = ["Abraham", "Sarah", "Moses", "Miriam", "David", "Ruth", "Solomon", "Esther", "Daniel", "Deborah", "Joshua", "Rachel", "Samuel", "Hannah", "Elijah", "Naomi"]
		name_input.text = biblical_names[randi() % biblical_names.size()]

	if class_option:
		class_option.selected = randi() % class_option.get_item_count()
		_on_class_selected(class_option.selected)

	if background_option:
		background_option.selected = randi() % background_option.get_item_count()
		_on_background_selected(background_option.selected)

	if gender_option:
		gender_option.selected = randi() % gender_option.get_item_count()

	if age_option:
		age_option.selected = randi() % age_option.get_item_count()

	if hair_option:
		hair_option.selected = randi() % hair_option.get_item_count()

	if eye_option:
		eye_option.selected = randi() % eye_option.get_item_count()

	update_appearance_preview()

func generate_character_backstory() -> String:
	var backstory = "🏛️ Your destiny awaits in the biblical lands...\n\n"

	var selected_class = ""
	var selected_background = ""

	if class_option and class_option.selected >= 0:
		selected_class = class_option.get_item_text(class_option.selected)
	if background_option and background_option.selected >= 0:
		selected_background = background_option.get_item_text(background_option.selected)

	# Create personalized narrative based on selections
	if selected_class != "" and selected_background != "":
		backstory += generate_combined_story(selected_class, selected_background)
	elif selected_class != "":
		backstory += "📿 CLASS: " + selected_class.to_upper() + "\n"
		backstory += character_classes[selected_class]["description"] + "\n\n"
		backstory += "⚡ Bonuses: " + character_classes[selected_class]["bonuses"] + "\n"
		backstory += "✨ Special: " + character_classes[selected_class]["special"] + "\n\n"
	elif selected_background != "":
		backstory += "🏠 BACKGROUND: " + selected_background.to_upper() + "\n"
		backstory += character_backgrounds[selected_background]["description"] + "\n\n"
		backstory += "⚡ Bonuses: " + character_backgrounds[selected_background]["bonuses"] + "\n"
		backstory += "📜 Your Story: " + character_backgrounds[selected_background]["story"] + "\n"
	else:
		backstory += "Choose your calling and background to shape your character's destiny in the biblical world.\n\n"

	return backstory

func generate_combined_story(character_class: String, background: String) -> String:
	var story = ""

	# Create unique narratives based on class + background combinations
	var class_info = character_classes.get(character_class, {})
	var bg_info = character_backgrounds.get(background, {})

	story += "📿 " + character_class.to_upper() + " • 🏠 " + background.to_upper() + "\n\n"

	# Generate personalized backstory
	story += "Your journey began " + bg_info.get("story", "") + " "
	story += "Now, as a " + character_class + ", " + class_info.get("description", "").to_lower() + "\n\n"

	# Combine bonuses
	story += "⚡ Combined Bonuses:\n"
	story += "• Class: " + class_info.get("bonuses", "") + "\n"
	story += "• Background: " + bg_info.get("bonuses", "") + "\n\n"

	story += "✨ Special Abilities:\n"
	story += "• " + class_info.get("special", "") + "\n"

	# Add thematic connection based on combinations
	var thematic_connection = get_thematic_connection(character_class, background)
	if thematic_connection != "":
		story += "\n🌟 Your Unique Path:\n" + thematic_connection + "\n"

	return story

func get_thematic_connection(character_class: String, background: String) -> String:
	var connections = {
		"Prophet_Temple Orphan": "Raised in holy halls, your visions carry the weight of divine authority. The priests who raised you recognize your gift.",
		"High Priest_Royal Ward": "Your noble upbringing and sacred calling make you a bridge between earthly power and divine will.",
		"Warrior of God_Soldier's Child": "Born into military tradition, you now serve a higher commander. Your sword defends the faithful.",
		"Desert Hermit_Desert Nomad": "The wasteland shaped you twice - first as child, then as seeker. You know every grain of sand holds wisdom.",
		"Royal Scribe_Scribe's Apprentice": "From apprentice to master, your pen has recorded the words of kings and now serves to chronicle God's will.",
		"Temple Musician_Temple Orphan": "The sanctuary that sheltered your youth now resonates with your sacred songs. Every note carries prayer.",
		"Merchant Prince_Merchant's Heir": "Born to trade, blessed to prosper, called to use wealth as tool for spreading faith across distant markets."
	}

	var key = character_class + "_" + background
	return connections.get(key, "")