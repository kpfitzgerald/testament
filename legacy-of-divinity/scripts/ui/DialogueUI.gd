extends Control

# UI References
@onready var npc_name = $DialoguePanel/VBoxContainer/NPCInfo/NPCNameContainer/NPCName
@onready var npc_title = $DialoguePanel/VBoxContainer/NPCInfo/NPCNameContainer/NPCTitle
@onready var portrait_label = $DialoguePanel/VBoxContainer/NPCInfo/NPCPortrait/PortraitLabel
@onready var dialogue_text = $DialoguePanel/VBoxContainer/DialogueContent/DialogueText
@onready var choices_container = $DialoguePanel/VBoxContainer/DialogueContent/ChoicesContainer
@onready var continue_button = $DialoguePanel/VBoxContainer/ActionButtons/ContinueButton
@onready var end_button = $DialoguePanel/VBoxContainer/ActionButtons/EndButton

# Choice buttons
var choice_buttons: Array[Button] = []
var current_npc_id: String = ""
var is_waiting_for_choice: bool = false

func _ready():
	# Get choice buttons
	choice_buttons = [
		$DialoguePanel/VBoxContainer/DialogueContent/ChoicesContainer/Choice1,
		$DialoguePanel/VBoxContainer/DialogueContent/ChoicesContainer/Choice2,
		$DialoguePanel/VBoxContainer/DialogueContent/ChoicesContainer/Choice3,
		$DialoguePanel/VBoxContainer/DialogueContent/ChoicesContainer/Choice4,
		$DialoguePanel/VBoxContainer/DialogueContent/ChoicesContainer/Choice5
	]

	# Connect choice buttons
	for i in range(choice_buttons.size()):
		choice_buttons[i].pressed.connect(_on_choice_selected.bind(i))

	# Connect to dialogue system signals
	if DialogueSystem:
		DialogueSystem.dialogue_started.connect(_on_dialogue_started)
		DialogueSystem.dialogue_ended.connect(_on_dialogue_ended)
		DialogueSystem.dialogue_choice_made.connect(_on_dialogue_choice_made)

func show_dialogue(npc_id: String):
	if DialogueSystem and DialogueSystem.start_dialogue(npc_id):
		current_npc_id = npc_id
		visible = true
		_update_dialogue_display()

func hide_dialogue():
	visible = false
	current_npc_id = ""
	is_waiting_for_choice = false

func _on_close_button_pressed():
	_end_dialogue()

func _on_end_button_pressed():
	_end_dialogue()

func _on_continue_button_pressed():
	# Used when dialogue continues without choices
	_update_dialogue_display()

func _end_dialogue():
	if DialogueSystem:
		DialogueSystem.end_dialogue()
	hide_dialogue()

func _on_dialogue_started(npc_id: String):
	current_npc_id = npc_id
	_update_npc_info()

func _on_dialogue_ended(npc_id: String):
	hide_dialogue()

func _on_dialogue_choice_made(choice_data: Dictionary):
	# Update display after choice is made
	_update_dialogue_display()

func _update_npc_info():
	if not DialogueSystem or current_npc_id == "":
		return

	var npc_info = DialogueSystem.get_npc_info(current_npc_id)
	npc_name.text = npc_info.get("name", "Unknown NPC")
	npc_title.text = npc_info.get("title", "")

	# Set portrait based on NPC
	var portrait_icons = {
		"high_priest_aaron": "⛪",
		"merchant_benjamin": "🏪",
		"prophet_miriam": "🔮"
	}
	portrait_label.text = portrait_icons.get(current_npc_id, "👤")

func _update_dialogue_display():
	if not DialogueSystem:
		return

	# Update dialogue text
	dialogue_text.text = DialogueSystem.get_current_dialogue_text()

	# Get available choices
	var choices = DialogueSystem.get_current_choices()
	_display_choices(choices)

func _display_choices(choices: Array):
	# Hide all choice buttons first
	for button in choice_buttons:
		button.visible = false
		button.disabled = false

	if choices.is_empty():
		# No choices, show continue or end button
		continue_button.visible = false
		end_button.visible = true
		is_waiting_for_choice = false
	else:
		# Show choice buttons
		is_waiting_for_choice = true
		continue_button.visible = false
		end_button.visible = false

		for i in range(min(choices.size(), choice_buttons.size())):
			var choice = choices[i]
			var button = choice_buttons[i]

			button.text = choice.get("text", "")
			button.disabled = choice.get("disabled", false)
			button.visible = true

			# Style button based on requirements
			if choice.get("disabled", false):
				button.modulate = Color.GRAY
				button.tooltip_text = "Requirements not met"
			else:
				button.modulate = Color.WHITE
				button.tooltip_text = ""

			# Color code choices based on moral implications
			var choice_text = choice.get("text", "").to_lower()
			if "blessing" in choice_text or "pray" in choice_text or "help" in choice_text:
				button.modulate = Color.LIGHT_BLUE
			elif "gold" in choice_text or "coins" in choice_text or "pay" in choice_text:
				button.modulate = Color.YELLOW
			elif "work" in choice_text or "job" in choice_text:
				button.modulate = Color.LIGHT_GREEN

func _on_choice_selected(choice_index: int):
	if not is_waiting_for_choice or not DialogueSystem:
		return

	DialogueSystem.make_dialogue_choice(choice_index)

# Handle keyboard input for dialogue
func _input(event):
	if not visible:
		return

	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ESCAPE:
				_end_dialogue()
			KEY_ENTER, KEY_SPACE:
				if continue_button.visible:
					_on_continue_button_pressed()
				elif end_button.visible:
					_end_dialogue()
			KEY_1:
				if is_waiting_for_choice and choice_buttons[0].visible:
					_on_choice_selected(0)
			KEY_2:
				if is_waiting_for_choice and choice_buttons[1].visible:
					_on_choice_selected(1)
			KEY_3:
				if is_waiting_for_choice and choice_buttons[2].visible:
					_on_choice_selected(2)
			KEY_4:
				if is_waiting_for_choice and choice_buttons[3].visible:
					_on_choice_selected(3)
			KEY_5:
				if is_waiting_for_choice and choice_buttons[4].visible:
					_on_choice_selected(4)

# Test function to start dialogue with different NPCs
func test_dialogue(npc_id: String):
	show_dialogue(npc_id)

# Function to be called by NPCs or interaction system
func start_npc_conversation(npc_id: String):
	show_dialogue(npc_id)