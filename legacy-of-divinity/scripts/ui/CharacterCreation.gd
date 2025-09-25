extends Control

@onready var name_input = $VBoxContainer/CharacterInfo/NameInput
@onready var class_option = $VBoxContainer/CharacterInfo/ClassOption
@onready var background_option = $VBoxContainer/CharacterInfo/BackgroundOption
@onready var create_button = $VBoxContainer/CreateButton
@onready var description_label = $VBoxContainer/DescriptionLabel

# Character classes with biblical inspiration
var character_classes = {
	"Pilgrim": {
		"description": "A seeker of truth, balanced in all aspects. Good for beginners.",
		"bonuses": "Balanced stats, moderate faith and wisdom"
	},
	"Prophet": {
		"description": "Chosen to speak divine truth, gifted with wisdom and faith.",
		"bonuses": "+20 Faith, +15 Wisdom, +10 Moral Alignment"
	},
	"Warrior of God": {
		"description": "A righteous warrior fighting for divine justice.",
		"bonuses": "+30 Health, +10 Faith, +5 Moral Alignment"
	},
	"Scholar": {
		"description": "Student of ancient texts and divine mysteries.",
		"bonuses": "+25 Wisdom, +50 Starting Experience"
	},
	"Merchant": {
		"description": "A trader who spreads faith through commerce.",
		"bonuses": "Enhanced trading abilities, moderate bonuses"
	}
}

var character_backgrounds = {
	"Commoner": {
		"description": "Born of humble origins, hardy and resilient.",
		"bonuses": "+10 Health, practical skills"
	},
	"Noble": {
		"description": "Born to privilege, with resources and connections.",
		"bonuses": "Starting resources, social advantages"
	},
	"Priest": {
		"description": "Raised in religious service, devoted to faith.",
		"bonuses": "+15 Faith, +15 Moral Alignment"
	},
	"Artisan": {
		"description": "Skilled craftsperson, knowledgeable in trade.",
		"bonuses": "Enhanced crafting abilities"
	},
	"Shepherd": {
		"description": "Caretaker of flocks, patient and wise.",
		"bonuses": "+10 Wisdom, animal handling skills"
	}
}

func _ready():
	setup_class_options()
	setup_background_options()

	# Connect signals
	class_option.item_selected.connect(_on_class_selected)
	background_option.item_selected.connect(_on_background_selected)

	# Initial description
	update_description()

func setup_class_options():
	class_option.clear()
	for class_name in character_classes.keys():
		class_option.add_item(class_name)

func setup_background_options():
	background_option.clear()
	for background_name in character_backgrounds.keys():
		background_option.add_item(background_name)

func _on_class_selected(index: int):
	update_description()

func _on_background_selected(index: int):
	update_description()

func update_description():
	var selected_class = class_option.get_item_text(class_option.selected)
	var selected_background = background_option.get_item_text(background_option.selected)

	var description_text = ""

	if character_classes.has(selected_class):
		description_text += "Class: " + selected_class + "\n"
		description_text += character_classes[selected_class]["description"] + "\n"
		description_text += "Bonuses: " + character_classes[selected_class]["bonuses"] + "\n\n"

	if character_backgrounds.has(selected_background):
		description_text += "Background: " + selected_background + "\n"
		description_text += character_backgrounds[selected_background]["description"] + "\n"
		description_text += "Bonuses: " + character_backgrounds[selected_background]["bonuses"]

	description_label.text = description_text

func _on_create_button_pressed():
	var character_name = name_input.text.strip_edges()

	if character_name == "":
		# Show error - name required
		print("Name is required!")
		return

	var selected_class = class_option.get_item_text(class_option.selected)
	var selected_background = background_option.get_item_text(background_option.selected)

	# Check for ancestral bonuses
	var generation = 1
	var legacy_bonuses = LegacySystem.get_available_bonuses()
	if legacy_bonuses.size() > 0:
		generation = get_next_generation()

	var character_data = {
		"name": character_name,
		"class": selected_class,
		"background": selected_background,
		"generation": generation,
		"appearance": {}  # Could expand this for character customization
	}

	# Create the character
	PlayerData.create_new_character(character_data)

	print("Character created: ", character_name, " (", selected_class, "/", selected_background, ")")

	# Go to game world
	get_tree().change_scene_to_file("res://scenes/world/GameWorld.tscn")

func get_next_generation() -> int:
	# Check family tree for next generation number
	var max_generation = 1
	for gen in LegacySystem.family_tree.keys():
		if gen > max_generation:
			max_generation = gen
	return max_generation + 1

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main/MainMenu.tscn")