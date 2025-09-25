extends Control

# Test controller for demonstrating all UI features
# Add this script to any scene to test the UI systems

func _ready():
	print("=== UI Test Controller Ready ===")
	print("Controls:")
	print("I/TAB - Toggle Inventory")
	print("K - Toggle Skills")
	print("1 - Test dialogue with High Priest Aaron")
	print("2 - Test dialogue with Merchant Benjamin")
	print("3 - Test dialogue with Prophetess Miriam")
	print("T - Add test data (items, experience)")
	print("ESC - Close any open UI")

	# Wait a moment then add some test data
	await get_tree().create_timer(1.0).timeout
	_setup_test_data()

func _setup_test_data():
	if UIManager:
		UIManager.setup_test_data()

func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				print("Testing High Priest Aaron dialogue...")
				if UIManager:
					UIManager.test_dialogue_aaron()
			KEY_2:
				print("Testing Merchant Benjamin dialogue...")
				if UIManager:
					UIManager.test_dialogue_benjamin()
			KEY_3:
				print("Testing Prophetess Miriam dialogue...")
				if UIManager:
					UIManager.test_dialogue_miriam()
			KEY_T:
				print("Adding test data...")
				if UIManager:
					UIManager.setup_test_data()
			KEY_F1:
				print("=== Current Game State ===")
				_print_game_state()

func _print_game_state():
	if PlayerData:
		print("Player: ", PlayerData.player_name)
		print("Class: ", PlayerData.selected_class)
		print("Level: ", PlayerData.level, " (", PlayerData.experience, " XP)")
		print("Health: ", PlayerData.health, "/", PlayerData.max_health)
		print("Faith: ", PlayerData.faith_points)
		print("Wisdom: ", PlayerData.wisdom_points)
		print("Social: ", PlayerData.social_skills)
		print("Moral Alignment: ", PlayerData.get_moral_alignment_text())

	if InventorySystem:
		print("Gold: ", InventorySystem.gold_coins)
		print("Items in inventory: ", InventorySystem.inventory_items.size())

	if WorldData:
		var world_summary = WorldData.get_world_state_summary()
		print("World Time: ", world_summary.get("time_of_day", 0), "h")
		print("Season: ", world_summary.get("season", "unknown"))
		print("Community Faith: ", world_summary.get("community_faith", 0))