extends Control

# Character Overview References
@onready var name_label = $SkillsPanel/VBoxContainer/MainContent/LeftPanel/CharacterOverview/OverviewContainer/NameLabel
@onready var class_label = $SkillsPanel/VBoxContainer/MainContent/LeftPanel/CharacterOverview/OverviewContainer/ClassLabel
@onready var level_label = $SkillsPanel/VBoxContainer/MainContent/LeftPanel/CharacterOverview/OverviewContainer/LevelLabel
@onready var experience_label = $SkillsPanel/VBoxContainer/MainContent/LeftPanel/CharacterOverview/OverviewContainer/ExperienceLabel
@onready var power_level_label = $SkillsPanel/VBoxContainer/MainContent/LeftPanel/CharacterOverview/OverviewContainer/PowerLevelLabel
@onready var moral_alignment_label = $SkillsPanel/VBoxContainer/MainContent/LeftPanel/CharacterOverview/OverviewContainer/MoralAlignmentLabel

# Attribute References
@onready var attribute_points_label = $SkillsPanel/VBoxContainer/MainContent/LeftPanel/Attributes/AttributePoints
@onready var strength_label = $SkillsPanel/VBoxContainer/MainContent/LeftPanel/Attributes/AttributesContainer/StrengthContainer/StrengthLabel
@onready var strength_button = $SkillsPanel/VBoxContainer/MainContent/LeftPanel/Attributes/AttributesContainer/StrengthContainer/StrengthButton
@onready var intelligence_label = $SkillsPanel/VBoxContainer/MainContent/LeftPanel/Attributes/AttributesContainer/IntelligenceContainer/IntelligenceLabel
@onready var intelligence_button = $SkillsPanel/VBoxContainer/MainContent/LeftPanel/Attributes/AttributesContainer/IntelligenceContainer/IntelligenceButton
@onready var charisma_label = $SkillsPanel/VBoxContainer/MainContent/LeftPanel/Attributes/AttributesContainer/CharismaContainer/CharismaLabel
@onready var charisma_button = $SkillsPanel/VBoxContainer/MainContent/LeftPanel/Attributes/AttributesContainer/CharismaContainer/CharismaButton
@onready var spirit_label = $SkillsPanel/VBoxContainer/MainContent/LeftPanel/Attributes/AttributesContainer/SpiritContainer/SpiritLabel
@onready var spirit_button = $SkillsPanel/VBoxContainer/MainContent/LeftPanel/Attributes/AttributesContainer/SpiritContainer/SpiritButton
@onready var endurance_label = $SkillsPanel/VBoxContainer/MainContent/LeftPanel/Attributes/AttributesContainer/EnduranceContainer/EnduranceLabel
@onready var endurance_button = $SkillsPanel/VBoxContainer/MainContent/LeftPanel/Attributes/AttributesContainer/EnduranceContainer/EnduranceButton

# Skill References
@onready var skill_points_label = $SkillsPanel/VBoxContainer/MainContent/RightPanel/SkillsSection/SkillsHeader/SkillPoints

# Skill containers with labels, buttons, and progress bars
var skill_components: Dictionary = {}

func _ready():
	_setup_skill_components()
	_connect_buttons()

	# Connect to player data updates
	if PlayerData:
		PlayerData.player_data_updated.connect(_update_all_displays)

	# Initial display update
	_update_all_displays()

func _setup_skill_components():
	skill_components = {
		"faith": {
			"label": $SkillsPanel/VBoxContainer/MainContent/RightPanel/SkillsSection/SkillsContainer/FaithSkill/FaithHeader/FaithLabel,
			"button": $SkillsPanel/VBoxContainer/MainContent/RightPanel/SkillsSection/SkillsContainer/FaithSkill/FaithHeader/FaithButton,
			"progress": $SkillsPanel/VBoxContainer/MainContent/RightPanel/SkillsSection/SkillsContainer/FaithSkill/FaithProgress
		},
		"wisdom": {
			"label": $SkillsPanel/VBoxContainer/MainContent/RightPanel/SkillsSection/SkillsContainer/WisdomSkill/WisdomHeader/WisdomLabel,
			"button": $SkillsPanel/VBoxContainer/MainContent/RightPanel/SkillsSection/SkillsContainer/WisdomSkill/WisdomHeader/WisdomButton,
			"progress": $SkillsPanel/VBoxContainer/MainContent/RightPanel/SkillsSection/SkillsContainer/WisdomSkill/WisdomProgress
		},
		"social": {
			"label": $SkillsPanel/VBoxContainer/MainContent/RightPanel/SkillsSection/SkillsContainer/SocialSkill/SocialHeader/SocialLabel,
			"button": $SkillsPanel/VBoxContainer/MainContent/RightPanel/SkillsSection/SkillsContainer/SocialSkill/SocialHeader/SocialButton,
			"progress": $SkillsPanel/VBoxContainer/MainContent/RightPanel/SkillsSection/SkillsContainer/SocialSkill/SocialProgress
		},
		"crafting": {
			"label": $SkillsPanel/VBoxContainer/MainContent/RightPanel/SkillsSection/SkillsContainer/CraftingSkill/CraftingHeader/CraftingLabel,
			"button": $SkillsPanel/VBoxContainer/MainContent/RightPanel/SkillsSection/SkillsContainer/CraftingSkill/CraftingHeader/CraftingButton,
			"progress": $SkillsPanel/VBoxContainer/MainContent/RightPanel/SkillsSection/SkillsContainer/CraftingSkill/CraftingProgress
		},
		"trading": {
			"label": $SkillsPanel/VBoxContainer/MainContent/RightPanel/SkillsSection/SkillsContainer/TradingSkill/TradingHeader/TradingLabel,
			"button": $SkillsPanel/VBoxContainer/MainContent/RightPanel/SkillsSection/SkillsContainer/TradingSkill/TradingHeader/TradingButton,
			"progress": $SkillsPanel/VBoxContainer/MainContent/RightPanel/SkillsSection/SkillsContainer/TradingSkill/TradingProgress
		},
		"healing": {
			"label": $SkillsPanel/VBoxContainer/MainContent/RightPanel/SkillsSection/SkillsContainer/HealingSkill/HealingHeader/HealingLabel,
			"button": $SkillsPanel/VBoxContainer/MainContent/RightPanel/SkillsSection/SkillsContainer/HealingSkill/HealingHeader/HealingButton,
			"progress": $SkillsPanel/VBoxContainer/MainContent/RightPanel/SkillsSection/SkillsContainer/HealingSkill/HealingProgress
		},
		"combat": {
			"label": $SkillsPanel/VBoxContainer/MainContent/RightPanel/SkillsSection/SkillsContainer/CombatSkill/CombatHeader/CombatLabel,
			"button": $SkillsPanel/VBoxContainer/MainContent/RightPanel/SkillsSection/SkillsContainer/CombatSkill/CombatHeader/CombatButton,
			"progress": $SkillsPanel/VBoxContainer/MainContent/RightPanel/SkillsSection/SkillsContainer/CombatSkill/CombatProgress
		},
		"leadership": {
			"label": $SkillsPanel/VBoxContainer/MainContent/RightPanel/SkillsSection/SkillsContainer/LeadershipSkill/LeadershipHeader/LeadershipLabel,
			"button": $SkillsPanel/VBoxContainer/MainContent/RightPanel/SkillsSection/SkillsContainer/LeadershipSkill/LeadershipHeader/LeadershipButton,
			"progress": $SkillsPanel/VBoxContainer/MainContent/RightPanel/SkillsSection/SkillsContainer/LeadershipSkill/LeadershipProgress
		}
	}

func _connect_buttons():
	# Attribute buttons
	strength_button.pressed.connect(_on_attribute_button_pressed.bind("strength"))
	intelligence_button.pressed.connect(_on_attribute_button_pressed.bind("intelligence"))
	charisma_button.pressed.connect(_on_attribute_button_pressed.bind("charisma"))
	spirit_button.pressed.connect(_on_attribute_button_pressed.bind("spirit"))
	endurance_button.pressed.connect(_on_attribute_button_pressed.bind("endurance"))

	# Skill buttons
	for skill in skill_components:
		skill_components[skill]["button"].pressed.connect(_on_skill_button_pressed.bind(skill))

func show_skills():
	visible = true
	_update_all_displays()

func hide_skills():
	visible = false

func _on_close_button_pressed():
	hide_skills()

func _update_all_displays():
	_update_character_overview()
	_update_attributes_display()
	_update_skills_display()

func _update_character_overview():
	if not PlayerData:
		return

	name_label.text = "Name: " + (PlayerData.player_name if PlayerData.player_name != "" else "Unknown")
	class_label.text = "Class: " + (PlayerData.selected_class if PlayerData.selected_class != "" else "Pilgrim")
	level_label.text = "Level: " + str(PlayerData.level)

	var exp_required = PlayerData.level * 100
	experience_label.text = "Experience: " + str(PlayerData.experience) + "/" + str(exp_required)

	power_level_label.text = "Power Level: " + str(PlayerData.get_character_power_level())
	moral_alignment_label.text = "Moral Alignment: " + PlayerData.get_moral_alignment_text()

func _update_attributes_display():
	if not PlayerData:
		return

	attribute_points_label.text = "Available Points: " + str(PlayerData.attribute_points)

	strength_label.text = "💪 Strength: " + str(PlayerData.attributes.get("strength", 10))
	intelligence_label.text = "🧠 Intelligence: " + str(PlayerData.attributes.get("intelligence", 10))
	charisma_label.text = "🗣️ Charisma: " + str(PlayerData.attributes.get("charisma", 10))
	spirit_label.text = "✨ Spirit: " + str(PlayerData.attributes.get("spirit", 10))
	endurance_label.text = "🛡️ Endurance: " + str(PlayerData.attributes.get("endurance", 10))

	# Enable/disable attribute buttons
	var has_points = PlayerData.attribute_points > 0
	strength_button.disabled = not has_points
	intelligence_button.disabled = not has_points
	charisma_button.disabled = not has_points
	spirit_button.disabled = not has_points
	endurance_button.disabled = not has_points

func _update_skills_display():
	if not PlayerData:
		return

	skill_points_label.text = "Skill Points: " + str(PlayerData.skill_points)

	# Update each skill
	var skill_icons = {
		"faith": "✨",
		"wisdom": "🧠",
		"social": "🗣️",
		"crafting": "🔨",
		"trading": "💰",
		"healing": "❤️",
		"combat": "⚔️",
		"leadership": "👑"
	}

	for skill in skill_components:
		var skill_data = PlayerData.skills.get(skill, {"level": 1, "experience": 0})
		var skill_level = skill_data.get("level", 1)
		var skill_exp = skill_data.get("experience", 0)
		var exp_for_next = skill_level * 100

		# Update label
		var icon = skill_icons.get(skill, "🎯")
		skill_components[skill]["label"].text = icon + " " + skill.capitalize() + ": Level " + str(skill_level)

		# Update progress bar
		var progress_percentage = (float(skill_exp) / float(exp_for_next)) * 100.0
		skill_components[skill]["progress"].value = progress_percentage

		# Update tooltip for progress bar
		skill_components[skill]["progress"].tooltip_text = str(skill_exp) + "/" + str(exp_for_next) + " XP"

		# Enable/disable skill button
		var can_spend = PlayerData.skill_points > 0 and skill_level < skill_data.get("max_level", 100)
		skill_components[skill]["button"].disabled = not can_spend

		# Highlight class bonus skills
		var bonus_skills = PlayerData.get_class_bonus_skills()
		if skill in bonus_skills:
			skill_components[skill]["label"].modulate = Color.GOLD
		else:
			skill_components[skill]["label"].modulate = Color.WHITE

func _on_attribute_button_pressed(attribute_name: String):
	if PlayerData and PlayerData.spend_attribute_point(attribute_name):
		print("Spent attribute point on ", attribute_name)

func _on_skill_button_pressed(skill_name: String):
	if PlayerData and PlayerData.spend_skill_point(skill_name):
		print("Spent skill point on ", skill_name)

# Handle input for opening/closing skills
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_K:
			if visible:
				hide_skills()
			else:
				show_skills()

# Helper function to simulate gaining skill experience (for testing)
func _add_test_skill_experience():
	if PlayerData:
		PlayerData.add_skill_experience("faith", 25)
		PlayerData.add_skill_experience("wisdom", 30)
		PlayerData.add_skill_experience("social", 20)