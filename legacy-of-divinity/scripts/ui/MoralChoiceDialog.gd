extends Control

signal choice_made(choice_id: String, choice_value: int)

@onready var title_label = $Panel/VBoxContainer/TitleLabel
@onready var description_label = $Panel/VBoxContainer/DescriptionLabel
@onready var choices_container = $Panel/VBoxContainer/ChoicesContainer
@onready var consequences_label = $Panel/VBoxContainer/ConsequencesLabel

var current_choice_data: Dictionary = {}

func _ready():
	visible = false

func show_moral_choice(choice_data: Dictionary):
	current_choice_data = choice_data

	title_label.text = choice_data.get("title", "A Moral Decision")
	description_label.text = choice_data.get("description", "You must make a choice...")

	# Clear existing choice buttons
	for child in choices_container.get_children():
		child.queue_free()

	# Create choice buttons
	var choices = choice_data.get("choices", [])
	for i in range(choices.size()):
		var choice = choices[i]
		var button = Button.new()
		button.text = choice.get("text", "Choice " + str(i + 1))
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		# Connect button to choice handler
		var choice_value = choice.get("moral_value", 0)
		var choice_id = choice_data.get("id", "unknown")
		button.pressed.connect(_on_choice_selected.bind(choice_id, choice_value, choice))

		choices_container.add_child(button)

	# Show consequences preview
	update_consequences_preview()

	visible = true
	GameManager.change_game_state(GameManager.GameState.CHOICE_DIALOG)

func update_consequences_preview():
	var preview_text = "Consider the consequences of your choice...\n\n"

	# Show current moral alignment
	var alignment_text = PlayerData.get_moral_alignment_text()
	preview_text += "Current Alignment: " + alignment_text + " (" + str(PlayerData.moral_alignment) + ")\n"

	# Show potential family legacy impact
	if PlayerData.generation > 1:
		preview_text += "Your choice will affect your family's legacy...\n"

	consequences_label.text = preview_text

func _on_choice_selected(choice_id: String, choice_value: int, choice_data: Dictionary):
	# Record the choice
	var consequences = choice_data.get("consequences", {})
	GameManager.make_moral_choice(choice_id, choice_value, consequences)

	# Apply immediate effects
	apply_choice_consequences(choice_data)

	# Hide dialog
	visible = false
	GameManager.change_game_state(GameManager.GameState.PLAYING)

	# Emit signal for quest system or other listeners
	choice_made.emit(choice_id, choice_value)

func apply_choice_consequences(choice_data: Dictionary):
	var consequences = choice_data.get("consequences", {})

	# Apply stat changes
	if consequences.has("health_change"):
		PlayerData.health = clamp(PlayerData.health + consequences.health_change, 0, PlayerData.max_health)

	if consequences.has("faith_change"):
		PlayerData.faith_points += consequences.faith_change

	if consequences.has("wisdom_change"):
		PlayerData.wisdom_points += consequences.wisdom_change

	if consequences.has("experience_change"):
		PlayerData.add_experience(consequences.experience_change)

	# Show consequence message
	var message = consequences.get("message", "Your choice has been recorded.")
	show_consequence_message(message)

func show_consequence_message(message: String):
	# Create a simple popup to show the result
	var popup = AcceptDialog.new()
	popup.dialog_text = message
	popup.title = "Consequence"
	add_child(popup)
	popup.popup_centered()

	# Remove popup after it's closed
	popup.confirmed.connect(popup.queue_free)

# Example moral choice scenarios
func create_sample_choice() -> Dictionary:
	return {
		"id": "help_stranger",
		"title": "A Stranger in Need",
		"description": "You encounter a wounded traveler on the road. They claim bandits attacked them and took their possessions. However, something about their story doesn't seem quite right. What do you do?",
		"choices": [
			{
				"text": "Help them unconditionally",
				"moral_value": 25,
				"consequences": {
					"message": "You showed compassion and helped a fellow human being.",
					"faith_change": 5,
					"experience_change": 10
				}
			},
			{
				"text": "Help, but remain cautious",
				"moral_value": 10,
				"consequences": {
					"message": "You helped while being wise about potential deception.",
					"wisdom_change": 3,
					"experience_change": 15
				}
			},
			{
				"text": "Question their story first",
				"moral_value": -5,
				"consequences": {
					"message": "Your suspicion revealed they were lying, but you were harsh.",
					"wisdom_change": 5,
					"faith_change": -2
				}
			},
			{
				"text": "Ignore them and walk away",
				"moral_value": -20,
				"consequences": {
					"message": "You turned away from someone who might have needed help.",
					"faith_change": -5,
					"health_change": -5
				}
			}
		]
	}