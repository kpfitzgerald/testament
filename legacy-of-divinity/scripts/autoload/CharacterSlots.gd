extends Node

# Character slot management system
# Handles multiple character saves and slot selection

const MAX_SLOTS = 8  # Maximum number of character slots
const STARTING_SLOTS = 2  # Number of slots available initially

# Current slot data
var current_slot: int = 0
var character_slots: Array[Dictionary] = []

signal character_slot_changed(slot_id: int)
signal character_slots_updated

func _ready():
	print("CharacterSlots: _ready() called")
	load_character_slots()
	print("CharacterSlots: Character slots loaded, ", character_slots.size(), " slots available")

# Initialize empty character slots
func _initialize_slots():
	character_slots.clear()
	for i in range(MAX_SLOTS):
		character_slots.append({
			"slot_id": i,
			"is_empty": true,
			"is_unlocked": i < STARTING_SLOTS,
			"character_name": "",
			"character_class": "",
			"level": 1,
			"generation": 1,
			"last_played": "",
			"save_file": "user://character_slot_%d.json" % i
		})

# Save character slot metadata
func save_character_slots():
	var save_data = {
		"current_slot": current_slot,
		"character_slots": character_slots
	}

	var file = FileAccess.open("user://character_slots.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()
		print("Character slots saved")

# Load character slot metadata
func load_character_slots():
	var file = FileAccess.open("user://character_slots.json", FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()

		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			var data = json.data
			current_slot = data.get("current_slot", 0)
			var slots_data = data.get("character_slots", [])
			character_slots.clear()
			for slot in slots_data:
				if slot is Dictionary:
					character_slots.append(slot)

			# Ensure we have the right number of slots
			if character_slots.size() != MAX_SLOTS:
				_initialize_slots()
		else:
			print("Error parsing character slots JSON")
			_initialize_slots()
	else:
		print("No character slots file found, creating new...")
		_initialize_slots()
		save_character_slots()

# Get character slot data
func get_slot_data(slot_id: int) -> Dictionary:
	if slot_id >= 0 and slot_id < character_slots.size():
		return character_slots[slot_id]
	return {}

# Check if a slot is empty
func is_slot_empty(slot_id: int) -> bool:
	var slot_data = get_slot_data(slot_id)
	return slot_data.get("is_empty", true)

# Check if a slot is unlocked
func is_slot_unlocked(slot_id: int) -> bool:
	var slot_data = get_slot_data(slot_id)
	return slot_data.get("is_unlocked", false)

# Create a new character in a slot
func create_character_in_slot(slot_id: int, character_name: String, character_class: String):
	if slot_id >= 0 and slot_id < character_slots.size() and is_slot_unlocked(slot_id):
		character_slots[slot_id] = {
			"slot_id": slot_id,
			"is_empty": false,
			"is_unlocked": true,
			"character_name": character_name,
			"character_class": character_class,
			"level": 1,
			"generation": 1,
			"last_played": Time.get_datetime_string_from_system(),
			"save_file": "user://character_slot_%d.json" % slot_id
		}
		save_character_slots()
		character_slots_updated.emit()

# Update character slot metadata (called after playing)
func update_character_slot(slot_id: int, level: int, generation: int):
	if slot_id >= 0 and slot_id < character_slots.size():
		character_slots[slot_id]["level"] = level
		character_slots[slot_id]["generation"] = generation
		character_slots[slot_id]["last_played"] = Time.get_datetime_string_from_system()
		save_character_slots()
		character_slots_updated.emit()

# Select a character slot to play
func select_character_slot(slot_id: int) -> bool:
	if slot_id >= 0 and slot_id < character_slots.size() and is_slot_unlocked(slot_id):
		current_slot = slot_id
		save_character_slots()
		character_slot_changed.emit(slot_id)
		return true
	return false

# Delete/reset a character slot
func reset_character_slot(slot_id: int):
	if slot_id >= 0 and slot_id < character_slots.size():
		# Delete the character save file
		var save_file = character_slots[slot_id].get("save_file", "")
		if save_file != "" and FileAccess.file_exists(save_file):
			DirAccess.remove_absolute(save_file)

		# Reset slot data
		character_slots[slot_id] = {
			"slot_id": slot_id,
			"is_empty": true,
			"is_unlocked": is_slot_unlocked(slot_id),  # Keep unlock status
			"character_name": "",
			"character_class": "",
			"level": 1,
			"generation": 1,
			"last_played": "",
			"save_file": "user://character_slot_%d.json" % slot_id
		}
		save_character_slots()
		character_slots_updated.emit()

# Get current character slot
func get_current_slot() -> int:
	return current_slot

# Load character data from selected slot
func load_character_from_slot(slot_id: int) -> Dictionary:
	var slot_data = get_slot_data(slot_id)
	var save_file = slot_data.get("save_file", "")

	if save_file != "" and FileAccess.file_exists(save_file):
		var file = FileAccess.open(save_file, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			file.close()

			var json = JSON.new()
			var parse_result = json.parse(json_string)
			if parse_result == OK:
				return json.data

	return {}

# Save character data to selected slot
func save_character_to_slot(slot_id: int, character_data: Dictionary):
	var slot_data = get_slot_data(slot_id)
	var save_file = slot_data.get("save_file", "")

	if save_file != "":
		var file = FileAccess.open(save_file, FileAccess.WRITE)
		if file:
			file.store_string(JSON.stringify(character_data))
			file.close()

			# Update slot metadata
			update_character_slot(slot_id,
				character_data.get("level", 1),
				character_data.get("generation", 1))

# Get list of all character slots for UI display
func get_all_slots() -> Array[Dictionary]:
	return character_slots

# Check if we have any save data (for backward compatibility)
func has_legacy_save_data() -> bool:
	return FileAccess.file_exists("user://player_data.json")

# Import legacy save data to first slot
func import_legacy_save_data():
	if has_legacy_save_data() and is_slot_empty(0):
		var file = FileAccess.open("user://player_data.json", FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			file.close()

			var json = JSON.new()
			var parse_result = json.parse(json_string)
			if parse_result == OK:
				var data = json.data
				create_character_in_slot(0,
					data.get("player_name", "Legacy Character"),
					data.get("selected_class", "Unknown"))
				save_character_to_slot(0, data)
				print("Legacy save data imported to slot 0")