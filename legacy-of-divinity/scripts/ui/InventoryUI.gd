extends Control

# UI References
@onready var stats_container = $InventoryPanel/VBoxContainer/MainContent/LeftPanel/PlayerStats/StatsContainer
@onready var level_label = $InventoryPanel/VBoxContainer/MainContent/LeftPanel/PlayerStats/StatsContainer/LevelLabel
@onready var health_label = $InventoryPanel/VBoxContainer/MainContent/LeftPanel/PlayerStats/StatsContainer/HealthLabel
@onready var faith_label = $InventoryPanel/VBoxContainer/MainContent/LeftPanel/PlayerStats/StatsContainer/FaithLabel
@onready var wisdom_label = $InventoryPanel/VBoxContainer/MainContent/LeftPanel/PlayerStats/StatsContainer/WisdomLabel
@onready var social_label = $InventoryPanel/VBoxContainer/MainContent/LeftPanel/PlayerStats/StatsContainer/SocialLabel
@onready var gold_label = $InventoryPanel/VBoxContainer/MainContent/LeftPanel/PlayerStats/StatsContainer/GoldLabel

@onready var equipment_grid = $InventoryPanel/VBoxContainer/MainContent/LeftPanel/Equipment/EquipmentGrid
@onready var item_grid = $InventoryPanel/VBoxContainer/MainContent/RightPanel/InventoryTabs/"All Items"/ItemGrid
@onready var consumable_grid = $InventoryPanel/VBoxContainer/MainContent/RightPanel/InventoryTabs/Consumables/ConsumableGrid
@onready var equip_grid = $InventoryPanel/VBoxContainer/MainContent/RightPanel/InventoryTabs/Equipment/EquipGrid
@onready var material_grid = $InventoryPanel/VBoxContainer/MainContent/RightPanel/InventoryTabs/Materials/MaterialGrid

@onready var detail_title = $InventoryPanel/VBoxContainer/ItemDetails/DetailTitle
@onready var detail_text = $InventoryPanel/VBoxContainer/ItemDetails/DetailText
@onready var use_button = $InventoryPanel/VBoxContainer/ItemDetails/ActionButtons/UseButton
@onready var equip_button = $InventoryPanel/VBoxContainer/ItemDetails/ActionButtons/EquipButton
@onready var drop_button = $InventoryPanel/VBoxContainer/ItemDetails/ActionButtons/DropButton

# Equipment slot buttons
var equipment_slots: Dictionary = {}
var selected_item: Dictionary = {}
var item_buttons: Array[Button] = []

func _ready():
	# Connect equipment slots
	_setup_equipment_slots()

	# Connect to inventory system signals
	if InventorySystem:
		InventorySystem.inventory_updated.connect(_update_inventory_display)
		InventorySystem.item_equipped.connect(_update_equipment_display)
		InventorySystem.item_unequipped.connect(_update_equipment_display)

	# Connect to player data updates
	if PlayerData:
		PlayerData.player_data_updated.connect(_update_stats_display)

	# Connect action buttons
	use_button.pressed.connect(_on_use_button_pressed)
	equip_button.pressed.connect(_on_equip_button_pressed)
	drop_button.pressed.connect(_on_drop_button_pressed)

	# Initial display update
	_update_all_displays()

func _setup_equipment_slots():
	equipment_slots["head"] = $InventoryPanel/VBoxContainer/MainContent/LeftPanel/Equipment/EquipmentGrid/HeadSlot
	equipment_slots["chest"] = $InventoryPanel/VBoxContainer/MainContent/LeftPanel/Equipment/EquipmentGrid/ChestSlot
	equipment_slots["legs"] = $InventoryPanel/VBoxContainer/MainContent/LeftPanel/Equipment/EquipmentGrid/LegsSlot
	equipment_slots["weapon"] = $InventoryPanel/VBoxContainer/MainContent/LeftPanel/Equipment/EquipmentGrid/WeaponSlot
	equipment_slots["shield"] = $InventoryPanel/VBoxContainer/MainContent/LeftPanel/Equipment/EquipmentGrid/ShieldSlot
	equipment_slots["accessory"] = $InventoryPanel/VBoxContainer/MainContent/LeftPanel/Equipment/EquipmentGrid/AccessorySlot

	# Connect equipment slot buttons
	for slot in equipment_slots:
		equipment_slots[slot].pressed.connect(_on_equipment_slot_pressed.bind(slot))

func show_inventory():
	visible = true
	_update_all_displays()

func hide_inventory():
	visible = false

func _on_close_button_pressed():
	hide_inventory()

func _update_all_displays():
	_update_stats_display()
	_update_equipment_display()
	_update_inventory_display()

func _update_stats_display():
	if not PlayerData:
		return

	level_label.text = "Level: " + str(PlayerData.level)
	health_label.text = "❤️ Health: " + str(PlayerData.health) + "/" + str(PlayerData.max_health)
	faith_label.text = "✨ Faith: " + str(PlayerData.faith_points)
	wisdom_label.text = "🧠 Wisdom: " + str(PlayerData.wisdom_points)
	social_label.text = "🗣️ Social: " + str(PlayerData.social_skills)

	if InventorySystem:
		gold_label.text = "💰 Gold: " + str(InventorySystem.gold_coins)

func _update_equipment_display():
	if not InventorySystem:
		return

	# Update equipment slots
	for slot in equipment_slots:
		var button = equipment_slots[slot]
		if InventorySystem.equipped_items.has(slot):
			var item_id = InventorySystem.equipped_items[slot]
			var item_data = InventorySystem.item_database.get(item_id, {})
			button.text = item_data.get("name", item_id)
			button.tooltip_text = item_data.get("description", "")
			_set_button_rarity_style(button, item_data.get("rarity", "common"))
		else:
			button.text = slot.capitalize()
			button.tooltip_text = "No " + slot + " equipped"
			_set_button_rarity_style(button, "empty")

func _update_inventory_display():
	if not InventorySystem:
		return

	# Clear existing item buttons
	_clear_item_grids()

	# Create buttons for all items
	for item in InventorySystem.inventory_items:
		_create_item_button(item)

func _clear_item_grids():
	for button in item_buttons:
		if button and is_instance_valid(button):
			button.queue_free()
	item_buttons.clear()

	# Clear grid children
	for child in item_grid.get_children():
		child.queue_free()
	for child in consumable_grid.get_children():
		child.queue_free()
	for child in equip_grid.get_children():
		child.queue_free()
	for child in material_grid.get_children():
		child.queue_free()

func _create_item_button(item: Dictionary):
	var item_data = InventorySystem.item_database.get(item.id, {})
	var item_type = item_data.get("type", "material")

	var button = Button.new()
	button.custom_minimum_size = Vector2(64, 64)
	button.text = item_data.get("name", item.id)
	if item.quantity > 1:
		button.text += "\n(" + str(item.quantity) + ")"

	button.tooltip_text = item_data.get("description", "")
	_set_button_rarity_style(button, item_data.get("rarity", "common"))

	# Connect button signal
	button.pressed.connect(_on_item_button_pressed.bind(item))
	item_buttons.append(button)

	# Add to appropriate grid
	item_grid.add_child(button)

	match item_type:
		"consumable", "offering":
			var consumable_button = button.duplicate()
			consumable_button.pressed.connect(_on_item_button_pressed.bind(item))
			consumable_grid.add_child(consumable_button)
		"weapon", "chest", "head", "legs", "feet", "hands", "shield", "accessory", "cloak":
			var equipment_button = button.duplicate()
			equipment_button.pressed.connect(_on_item_button_pressed.bind(item))
			equip_grid.add_child(equipment_button)
		"material":
			var material_button = button.duplicate()
			material_button.pressed.connect(_on_item_button_pressed.bind(item))
			material_grid.add_child(material_button)

func _set_button_rarity_style(button: Button, rarity: String):
	# Set button colors based on rarity
	match rarity:
		"common":
			button.modulate = Color.WHITE
		"uncommon":
			button.modulate = Color.GREEN
		"rare":
			button.modulate = Color.BLUE
		"epic":
			button.modulate = Color.PURPLE
		"legendary":
			button.modulate = Color.ORANGE
		"empty":
			button.modulate = Color.GRAY

func _on_item_button_pressed(item: Dictionary):
	selected_item = item
	_update_item_details()

func _on_equipment_slot_pressed(slot: String):
	if InventorySystem.equipped_items.has(slot):
		var item_id = InventorySystem.equipped_items[slot]
		var item_data = InventorySystem.item_database.get(item_id, {})
		selected_item = {
			"id": item_id,
			"quantity": 1,
			"data": item_data,
			"equipped_slot": slot
		}
		_update_item_details()

func _update_item_details():
	if selected_item.is_empty():
		detail_title.text = "Select an item to see details"
		detail_text.text = "Item description will appear here."
		use_button.disabled = true
		equip_button.disabled = true
		drop_button.disabled = true
		return

	var item_data = selected_item.get("data", {})
	detail_title.text = item_data.get("name", selected_item.get("id", "Unknown"))

	# Build detailed description
	var description = item_data.get("description", "No description available.")
	description += "\n\n"

	# Add rarity
	var rarity = item_data.get("rarity", "common")
	description += "[color=gray]Rarity:[/color] " + rarity.capitalize() + "\n"

	# Add value
	var value = item_data.get("value", 0)
	description += "[color=gray]Value:[/color] " + str(value) + " gold\n"

	# Add stats if equipment
	var stats = item_data.get("stats", {})
	if not stats.is_empty():
		description += "\n[color=green]Stats:[/color]\n"
		for stat in stats:
			description += "  +" + str(stats[stat]) + " " + stat.capitalize() + "\n"

	# Add requirements
	var requirements = item_data.get("requirements", {})
	if not requirements.is_empty():
		description += "\n[color=red]Requirements:[/color]\n"
		for req in requirements:
			description += "  " + req.capitalize() + ": " + str(requirements[req]) + "\n"

	# Add special properties
	if item_data.has("special"):
		description += "\n[color=yellow]Special:[/color] " + str(item_data["special"]) + "\n"

	detail_text.text = description

	# Update button states
	var item_type = item_data.get("type", "")
	use_button.disabled = item_type != "consumable"
	equip_button.disabled = not (item_type in ["weapon", "chest", "head", "legs", "feet", "hands", "shield", "accessory", "cloak"])
	drop_button.disabled = false

	# Change equip button text if item is equipped
	if selected_item.has("equipped_slot"):
		equip_button.text = "Unequip"
		equip_button.disabled = false

func _on_use_button_pressed():
	if selected_item.is_empty():
		return

	if InventorySystem.use_item(selected_item.id):
		print("Used ", selected_item.get("data", {}).get("name", selected_item.id))
		selected_item = {}
		_update_item_details()

func _on_equip_button_pressed():
	if selected_item.is_empty():
		return

	if selected_item.has("equipped_slot"):
		# Unequip item
		if InventorySystem.unequip_item(selected_item.equipped_slot):
			print("Unequipped item from ", selected_item.equipped_slot)
			selected_item = {}
			_update_item_details()
	else:
		# Equip item
		if InventorySystem.equip_item(selected_item.id):
			print("Equipped ", selected_item.get("data", {}).get("name", selected_item.id))
			selected_item = {}
			_update_item_details()

func _on_drop_button_pressed():
	if selected_item.is_empty():
		return

	# Simple drop (remove from inventory)
	if selected_item.has("equipped_slot"):
		InventorySystem.unequip_item(selected_item.equipped_slot)
	else:
		InventorySystem.remove_item(selected_item.id, 1)

	print("Dropped ", selected_item.get("data", {}).get("name", selected_item.id))
	selected_item = {}
	_update_item_details()

# Handle input for opening/closing inventory
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_I or event.keycode == KEY_TAB:
			if visible:
				hide_inventory()
			else:
				show_inventory()