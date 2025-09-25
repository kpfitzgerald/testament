extends Control

@onready var name_input = $VBoxContainer/CharacterInfo/NameInput
@onready var class_option = $VBoxContainer/CharacterInfo/ClassOption
@onready var background_option = $VBoxContainer/CharacterInfo/BackgroundOption
@onready var create_button = $VBoxContainer/ButtonContainer/CreateButton
@onready var description_label = $VBoxContainer/DescriptionLabel

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
	}
}

func _ready():
	print("Character creation initialized")
	setup_options()
	connect_signals()

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

func connect_signals():
	if class_option:
		class_option.item_selected.connect(_on_class_selected)
	if background_option:
		background_option.item_selected.connect(_on_background_selected)

func _on_class_selected(_index: int):
	update_description()

func _on_background_selected(_index: int):
	update_description()

func update_description():
	if not description_label:
		return

	var desc_text = "Select your character's class and background to see details."

	if class_option and class_option.selected >= 0:
		var selected_class = class_option.get_item_text(class_option.selected)
		if character_classes.has(selected_class):
			desc_text = "Class: " + selected_class + "\n"
			desc_text += character_classes[selected_class]["description"] + "\n"
			desc_text += "Bonuses: " + character_classes[selected_class]["bonuses"]

	description_label.text = desc_text

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
		"appearance": {}
	}

	if PlayerData:
		PlayerData.create_new_character(character_data)
		print("Character created successfully")

	get_tree().change_scene_to_file("res://scenes/world/BiblicalWorld.tscn")

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main/MainMenu.tscn")