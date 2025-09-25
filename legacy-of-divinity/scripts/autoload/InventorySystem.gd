extends Node

signal inventory_updated
signal item_equipped
signal item_unequipped

# Inventory data
var inventory_items: Array[Dictionary] = []
var equipped_items: Dictionary = {}
var max_inventory_slots: int = 30
var gold_coins: int = 100

# Equipment slots
var equipment_slots: Array[String] = [
	"head", "chest", "legs", "feet", "hands",
	"weapon", "shield", "accessory", "cloak"
]

# Item database with biblical items
var item_database: Dictionary = {
	# Consumables
	"daily_bread": {
		"name": "Daily Bread",
		"type": "consumable",
		"rarity": "common",
		"description": "Give us this day our daily bread. Restores health and faith.",
		"effects": {"health": 25, "faith": 5},
		"value": 5,
		"stackable": true,
		"max_stack": 20
	},
	"blessed_water": {
		"name": "Blessed Water",
		"type": "consumable",
		"rarity": "uncommon",
		"description": "Water sanctified by priests. Purifies corruption and restores spirit.",
		"effects": {"health": 15, "removes_curse": true},
		"value": 15,
		"stackable": true,
		"max_stack": 10
	},
	"olive_oil": {
		"name": "Sacred Olive Oil",
		"type": "consumable",
		"rarity": "rare",
		"description": "Oil used for anointing. Provides temporary blessing.",
		"effects": {"blessing_duration": 600, "skill_bonus": 10},
		"value": 50,
		"stackable": true,
		"max_stack": 5
	},
	"frankincense": {
		"name": "Frankincense",
		"type": "offering",
		"rarity": "rare",
		"description": "Precious incense for temple offerings. Increases divine favor.",
		"effects": {"temple_offering_bonus": 2.0},
		"value": 200,
		"stackable": true,
		"max_stack": 3
	},

	# Weapons
	"shepherds_staff": {
		"name": "Shepherd's Staff",
		"type": "weapon",
		"rarity": "common",
		"description": "Simple wooden staff used by shepherds. Provides comfort to allies.",
		"stats": {"damage": 8, "wisdom": 3, "leadership": 2},
		"value": 25,
		"requirements": {"level": 1},
		"stackable": false
	},
	"cedar_staff": {
		"name": "Cedar Staff",
		"type": "weapon",
		"rarity": "uncommon",
		"description": "Staff carved from cedar wood. Symbol of strength and endurance.",
		"stats": {"damage": 15, "wisdom": 5, "faith": 3},
		"value": 150,
		"requirements": {"level": 5, "wisdom": 15},
		"stackable": false
	},
	"sword_of_righteousness": {
		"name": "Sword of Righteousness",
		"type": "weapon",
		"rarity": "epic",
		"description": "Blessed sword that glows with divine light. Effective against evil.",
		"stats": {"damage": 35, "faith": 10, "combat": 8},
		"special": "deals_extra_damage_to_evil",
		"value": 800,
		"requirements": {"level": 15, "moral_alignment": 50},
		"stackable": false
	},

	# Armor
	"simple_robe": {
		"name": "Simple Robe",
		"type": "chest",
		"rarity": "common",
		"description": "Plain cloth robe worn by common folk.",
		"stats": {"defense": 5, "social": 1},
		"value": 20,
		"requirements": {"level": 1},
		"stackable": false
	},
	"prayer_shawl": {
		"name": "Prayer Shawl",
		"type": "cloak",
		"rarity": "uncommon",
		"description": "Blessed shawl worn during prayer. Enhances spiritual connection.",
		"stats": {"defense": 8, "faith": 5, "wisdom": 3},
		"value": 75,
		"requirements": {"level": 3, "faith": 10},
		"stackable": false
	},
	"high_priest_vestments": {
		"name": "High Priest's Vestments",
		"type": "chest",
		"rarity": "legendary",
		"description": "Sacred robes worn by the high priest. Radiates divine authority.",
		"stats": {"defense": 25, "faith": 20, "wisdom": 15, "leadership": 10},
		"special": "temple_blessing_bonus",
		"value": 2000,
		"requirements": {"level": 20, "selected_class": "High Priest"},
		"stackable": false
	},

	# Accessories
	"bronze_bracelet": {
		"name": "Bronze Bracelet",
		"type": "accessory",
		"rarity": "common",
		"description": "Simple bronze bracelet with protective engravings.",
		"stats": {"defense": 2, "health": 5},
		"value": 30,
		"requirements": {"level": 1},
		"stackable": false
	},
	"signet_ring": {
		"name": "Royal Signet Ring",
		"type": "accessory",
		"rarity": "rare",
		"description": "Ring bearing a royal seal. Symbol of authority and wealth.",
		"stats": {"social": 10, "trading": 5, "gold_bonus": 0.1},
		"value": 500,
		"requirements": {"level": 10, "selected_background": "Royal Ward"},
		"stackable": false
	},

	# Tools and Materials
	"scroll_blank": {
		"name": "Blank Scroll",
		"type": "material",
		"rarity": "common",
		"description": "Empty parchment for writing prayers or messages.",
		"value": 10,
		"stackable": true,
		"max_stack": 50
	},
	"pottery_clay": {
		"name": "Potter's Clay",
		"type": "material",
		"rarity": "common",
		"description": "Clay suitable for creating vessels and pottery.",
		"value": 5,
		"stackable": true,
		"max_stack": 100
	},
	"precious_stones": {
		"name": "Precious Stones",
		"type": "material",
		"rarity": "rare",
		"description": "Gems and stones for crafting fine jewelry and temple decorations.",
		"value": 100,
		"stackable": true,
		"max_stack": 20
	}
}

func _ready():
	# Initialize starting items based on class and background
	_initialize_starting_inventory()

func _initialize_starting_inventory():
	# Add starting items based on character class
	match PlayerData.selected_class:
		"Prophet":
			add_item("blessed_water", 3)
			add_item("scroll_blank", 5)
		"Warrior of God":
			add_item("simple_robe")
			add_item("bronze_bracelet")
		"High Priest":
			add_item("prayer_shawl")
			add_item("frankincense", 2)
		"Desert Hermit":
			add_item("daily_bread", 5)
			add_item("blessed_water", 2)
		"Royal Scribe":
			add_item("scroll_blank", 10)
			if PlayerData.selected_background == "Royal Ward":
				add_item("signet_ring")
		"Temple Musician":
			add_item("simple_robe")
			add_item("daily_bread", 3)
		"Merchant Prince":
			gold_coins += 200
			add_item("daily_bread", 3)
		"Pilgrim":
			add_item("shepherds_staff")
			add_item("daily_bread", 3)
			add_item("blessed_water", 1)

	# Add background-specific items
	match PlayerData.selected_background:
		"Shepherd":
			if not has_item("shepherds_staff"):
				add_item("shepherds_staff")
		"Carpenter's Child":
			add_item("pottery_clay", 10)
		"Temple Orphan":
			add_item("prayer_shawl")
		"Merchant's Heir":
			gold_coins += 100

func add_item(item_id: String, quantity: int = 1) -> bool:
	if not item_database.has(item_id):
		print("Item not found in database: ", item_id)
		return false

	var item_data = item_database[item_id]

	# Check if item is stackable
	if item_data.get("stackable", false):
		# Find existing stack
		for item in inventory_items:
			if item.id == item_id:
				var max_stack = item_data.get("max_stack", 99)
				var can_add = min(quantity, max_stack - item.quantity)
				item.quantity += can_add
				quantity -= can_add
				if quantity <= 0:
					inventory_updated.emit()
					return true

	# Add new item instances
	while quantity > 0:
		if inventory_items.size() >= max_inventory_slots:
			print("Inventory full!")
			return false

		var max_stack = item_data.get("max_stack", 1) if item_data.get("stackable", false) else 1
		var add_quantity = min(quantity, max_stack)

		var new_item = {
			"id": item_id,
			"quantity": add_quantity,
			"data": item_data.duplicate()
		}

		inventory_items.append(new_item)
		quantity -= add_quantity

	inventory_updated.emit()
	return true

func remove_item(item_id: String, quantity: int = 1) -> bool:
	var removed = 0
	var i = 0

	while i < inventory_items.size() and removed < quantity:
		var item = inventory_items[i]
		if item.id == item_id:
			var remove_from_stack = min(quantity - removed, item.quantity)
			item.quantity -= remove_from_stack
			removed += remove_from_stack

			if item.quantity <= 0:
				inventory_items.remove_at(i)
				continue
		i += 1

	if removed > 0:
		inventory_updated.emit()

	return removed == quantity

func has_item(item_id: String, quantity: int = 1) -> bool:
	var total = 0
	for item in inventory_items:
		if item.id == item_id:
			total += item.quantity
			if total >= quantity:
				return true
	return false

func get_item_count(item_id: String) -> int:
	var total = 0
	for item in inventory_items:
		if item.id == item_id:
			total += item.quantity
	return total

func use_item(item_id: String) -> bool:
	if not has_item(item_id):
		return false

	var item_data = item_database.get(item_id, {})
	var item_type = item_data.get("type", "")

	if item_type == "consumable":
		# Apply item effects
		var effects = item_data.get("effects", {})
		for effect in effects:
			_apply_item_effect(effect, effects[effect])

		remove_item(item_id, 1)
		print("Used ", item_data.get("name", item_id))
		return true

	return false

func _apply_item_effect(effect_type: String, value):
	match effect_type:
		"health":
			PlayerData.health = min(PlayerData.health + value, PlayerData.max_health)
		"faith":
			PlayerData.faith_points += value
		"wisdom":
			PlayerData.wisdom_points += value
		"removes_curse":
			# Remove any active curses/debuffs
			pass
		"blessing_duration":
			# Apply temporary blessing
			pass
		"skill_bonus":
			# Temporary skill bonus
			pass

func equip_item(item_id: String) -> bool:
	if not has_item(item_id):
		return false

	var item_data = item_database.get(item_id, {})
	var slot = item_data.get("type", "")

	if not slot in equipment_slots:
		print("Item cannot be equipped")
		return false

	# Check requirements
	var requirements = item_data.get("requirements", {})
	if not _check_requirements(requirements):
		print("Requirements not met for ", item_data.get("name", item_id))
		return false

	# Unequip current item in slot
	if equipped_items.has(slot):
		unequip_item(slot)

	# Equip new item
	equipped_items[slot] = item_id
	remove_item(item_id, 1)

	# Apply stat bonuses
	_apply_equipment_stats()

	item_equipped.emit(item_id, slot)
	print("Equipped ", item_data.get("name", item_id))
	return true

func unequip_item(slot: String) -> bool:
	if not equipped_items.has(slot):
		return false

	var item_id = equipped_items[slot]
	equipped_items.erase(slot)

	# Return item to inventory
	add_item(item_id, 1)

	# Reapply equipment stats
	_apply_equipment_stats()

	item_unequipped.emit(item_id, slot)
	print("Unequipped item from ", slot)
	return true

func _check_requirements(requirements: Dictionary) -> bool:
	for req in requirements:
		match req:
			"level":
				if PlayerData.level < requirements[req]:
					return false
			"moral_alignment":
				if PlayerData.moral_alignment < requirements[req]:
					return false
			"selected_class":
				if PlayerData.selected_class != requirements[req]:
					return false
			"selected_background":
				if PlayerData.selected_background != requirements[req]:
					return false
			_:
				# Check skill requirements
				if PlayerData.skills.has(req):
					if PlayerData.skills[req].level < requirements[req]:
						return false
	return true

func _apply_equipment_stats():
	# Reset equipment bonuses (implement in PlayerData)
	# Then reapply all equipped items
	for slot in equipped_items:
		var item_id = equipped_items[slot]
		var item_data = item_database.get(item_id, {})
		var stats = item_data.get("stats", {})

		# Apply stat bonuses to PlayerData
		for stat in stats:
			match stat:
				"defense":
					# Add to defense calculation
					pass
				"damage":
					# Add to damage calculation
					pass
				"health":
					PlayerData.max_health += stats[stat]
				"faith":
					PlayerData.faith_points += stats[stat]
				"wisdom":
					PlayerData.wisdom_points += stats[stat]
				"social":
					PlayerData.social_skills += stats[stat]

func get_inventory_value() -> int:
	var total_value = gold_coins

	for item in inventory_items:
		var item_data = item_database.get(item.id, {})
		total_value += item_data.get("value", 0) * item.quantity

	return total_value

func get_equipment_summary() -> Dictionary:
	var summary = {}
	for slot in equipped_items:
		var item_id = equipped_items[slot]
		var item_data = item_database.get(item_id, {})
		summary[slot] = {
			"name": item_data.get("name", item_id),
			"rarity": item_data.get("rarity", "common")
		}
	return summary

func save_inventory_data() -> Dictionary:
	return {
		"inventory_items": inventory_items,
		"equipped_items": equipped_items,
		"gold_coins": gold_coins,
		"max_inventory_slots": max_inventory_slots
	}

func load_inventory_data(data: Dictionary):
	var items_data = data.get("inventory_items", [])
	inventory_items.clear()
	for item in items_data:
		if item is Dictionary:
			inventory_items.append(item)
	equipped_items = data.get("equipped_items", {})
	gold_coins = data.get("gold_coins", 100)
	max_inventory_slots = data.get("max_inventory_slots", 30)

	_apply_equipment_stats()
	inventory_updated.emit()