extends Node

signal world_data_updated
signal world_state_changed

# World persistence data
var world_id: String = "biblical_world_main"
var server_time: float = 0.0
var world_events: Array[Dictionary] = []
var npc_states: Dictionary = {}
var world_objects: Dictionary = {}
var player_interactions: Dictionary = {}

# Shared world resources
var temple_donations: int = 0
var community_faith_level: int = 50
var active_world_quests: Array[Dictionary] = []
var completed_world_events: Array[String] = []

# Dynamic content
var marketplace_items: Dictionary = {}
var weather_state: Dictionary = {"type": "clear", "intensity": 0.5}
var time_of_day: float = 12.0  # Hours (0-24)
var seasonal_data: Dictionary = {"season": "spring", "day_of_year": 1}

# Player-driven world changes
var player_built_structures: Dictionary = {}
var reputation_systems: Dictionary = {}
var guild_data: Dictionary = {}

func _ready():
	load_world_data()
	# Start world update timer
	var timer = Timer.new()
	timer.wait_time = 60.0  # Update world every minute
	timer.timeout.connect(_update_world_time)
	timer.autostart = true
	add_child(timer)

func save_world_data():
	var world_data = {
		"world_id": world_id,
		"server_time": Time.get_unix_time_from_system(),
		"world_events": world_events,
		"npc_states": npc_states,
		"world_objects": world_objects,
		"player_interactions": player_interactions,
		"temple_donations": temple_donations,
		"community_faith_level": community_faith_level,
		"active_world_quests": active_world_quests,
		"completed_world_events": completed_world_events,
		"marketplace_items": marketplace_items,
		"weather_state": weather_state,
		"time_of_day": time_of_day,
		"seasonal_data": seasonal_data,
		"player_built_structures": player_built_structures,
		"reputation_systems": reputation_systems,
		"guild_data": guild_data,
		"save_timestamp": Time.get_unix_time_from_system()
	}

	var file = FileAccess.open("user://world_data.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(world_data))
		file.close()
		print("World data saved")

func load_world_data():
	var file = FileAccess.open("user://world_data.json", FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()

		var json = JSON.new()
		var parse_result = json.parse(json_string)

		if parse_result == OK:
			var world_data = json.data
			world_id = world_data.get("world_id", "biblical_world_main")
			server_time = world_data.get("server_time", 0.0)
			var events_data = world_data.get("world_events", [])
			world_events.clear()
			for event in events_data:
				if event is Dictionary:
					world_events.append(event)
			npc_states = world_data.get("npc_states", {})
			world_objects = world_data.get("world_objects", {})
			player_interactions = world_data.get("player_interactions", {})
			temple_donations = world_data.get("temple_donations", 0)
			community_faith_level = world_data.get("community_faith_level", 50)
			var quests_data = world_data.get("active_world_quests", [])
			active_world_quests.clear()
			for quest in quests_data:
				if quest is Dictionary:
					active_world_quests.append(quest)
			var events_completed_data = world_data.get("completed_world_events", [])
			completed_world_events.clear()
			for event_id in events_completed_data:
				if event_id is String:
					completed_world_events.append(event_id)
			marketplace_items = world_data.get("marketplace_items", {})
			weather_state = world_data.get("weather_state", {"type": "clear", "intensity": 0.5})
			time_of_day = world_data.get("time_of_day", 12.0)
			seasonal_data = world_data.get("seasonal_data", {"season": "spring", "day_of_year": 1})
			player_built_structures = world_data.get("player_built_structures", {})
			reputation_systems = world_data.get("reputation_systems", {})
			guild_data = world_data.get("guild_data", {})

			print("World data loaded")
		else:
			print("Failed to parse world data, initializing defaults")
			_initialize_default_world_state()
	else:
		print("No world data file found, initializing defaults")
		_initialize_default_world_state()

func _initialize_default_world_state():
	# Initialize NPCs with default states
	npc_states = {
		"high_priest_aaron": {
			"location": "temple_courtyard",
			"mood": "contemplative",
			"last_conversation": {},
			"quest_availability": ["temple_blessing", "sacred_scroll_delivery"]
		},
		"merchant_benjamin": {
			"location": "marketplace",
			"mood": "eager",
			"last_conversation": {},
			"inventory_gold": 500,
			"quest_availability": ["caravan_guard", "rare_spice_collection"]
		},
		"prophet_miriam": {
			"location": "desert_outskirts",
			"mood": "mystical",
			"last_conversation": {},
			"vision_count": 0,
			"quest_availability": ["prophecy_interpretation", "divine_vision_quest"]
		}
	}

	# Initialize world objects
	world_objects = {
		"temple_altar": {
			"state": "clean",
			"donations_today": 0,
			"last_blessed_by": "",
			"blessing_power": 100
		},
		"marketplace_fountain": {
			"state": "flowing",
			"water_quality": "pure",
			"last_blessed": 0
		},
		"ancient_scroll_library": {
			"available_scrolls": ["genesis_fragment", "psalms_collection", "proverbs_wisdom"],
			"restricted_scrolls": ["prophetic_visions", "divine_law_tablets"],
			"librarian_present": true
		}
	}

	# Initialize marketplace with biblical items
	marketplace_items = {
		"daily_bread": {"price": 5, "stock": 50, "type": "consumable"},
		"olive_oil_lamp": {"price": 25, "stock": 10, "type": "tool"},
		"prayer_shawl": {"price": 75, "stock": 5, "type": "equipment"},
		"cedar_staff": {"price": 150, "stock": 3, "type": "weapon"},
		"frankincense": {"price": 200, "stock": 2, "type": "offering"}
	}

func _update_world_time():
	time_of_day += 0.25  # 15 minutes of game time per real minute
	if time_of_day >= 24.0:
		time_of_day = 0.0
		seasonal_data.day_of_year += 1

	# Update seasonal progression
	if seasonal_data.day_of_year > 365:
		seasonal_data.day_of_year = 1

	var season_day = int(seasonal_data.day_of_year) % 365
	if season_day < 91:
		seasonal_data.season = "spring"
	elif season_day < 182:
		seasonal_data.season = "summer"
	elif season_day < 273:
		seasonal_data.season = "autumn"
	else:
		seasonal_data.season = "winter"

	# Trigger world events based on time
	_check_time_based_events()

	save_world_data()
	world_data_updated.emit()

func _check_time_based_events():
	# Morning prayers at temples (6 AM)
	if abs(time_of_day - 6.0) < 0.1:
		trigger_world_event("morning_prayers", {"location": "temple_courtyard"})

	# Marketplace opening (8 AM)
	elif abs(time_of_day - 8.0) < 0.1:
		trigger_world_event("marketplace_opens", {"location": "marketplace"})

	# Evening prayers (18:00 / 6 PM)
	elif abs(time_of_day - 18.0) < 0.1:
		trigger_world_event("evening_prayers", {"location": "temple_courtyard"})

func trigger_world_event(event_id: String, event_data: Dictionary):
	var world_event = {
		"id": event_id,
		"data": event_data,
		"timestamp": Time.get_unix_time_from_system(),
		"game_time": time_of_day,
		"season": seasonal_data.season
	}

	world_events.append(world_event)

	# Keep only recent events (last 100)
	if world_events.size() > 100:
		world_events = world_events.slice(-100)

	print("World event triggered: ", event_id)
	world_state_changed.emit(event_id, event_data)

func update_npc_state(npc_id: String, new_state: Dictionary):
	if npc_states.has(npc_id):
		npc_states[npc_id].merge(new_state)
	else:
		npc_states[npc_id] = new_state

	save_world_data()

func update_world_object(object_id: String, new_state: Dictionary):
	if world_objects.has(object_id):
		world_objects[object_id].merge(new_state)
	else:
		world_objects[object_id] = new_state

	save_world_data()

func add_player_interaction(player_id: String, interaction_data: Dictionary):
	if not player_interactions.has(player_id):
		player_interactions[player_id] = []

	player_interactions[player_id].append({
		"data": interaction_data,
		"timestamp": Time.get_unix_time_from_system(),
		"game_time": time_of_day
	})

	# Keep only recent interactions per player (last 50)
	if player_interactions[player_id].size() > 50:
		player_interactions[player_id] = player_interactions[player_id].slice(-50)

func contribute_to_temple(amount: int, player_id: String):
	temple_donations += amount
	community_faith_level += int(amount / 10.0)  # Each donation increases community faith
	community_faith_level = min(community_faith_level, 100)

	add_player_interaction(player_id, {
		"type": "temple_donation",
		"amount": amount,
		"new_total": temple_donations
	})

	save_world_data()
	print("Temple donation: ", amount, " by player: ", player_id)

func get_world_state_summary() -> Dictionary:
	return {
		"time_of_day": time_of_day,
		"season": seasonal_data.season,
		"day_of_year": seasonal_data.day_of_year,
		"weather": weather_state,
		"community_faith": community_faith_level,
		"temple_donations": temple_donations,
		"active_events": world_events.slice(-10)  # Last 10 events
	}

# Network sync functions for multiplayer
@rpc("authority", "call_local")
func sync_world_state(world_state: Dictionary):
	# Called by server to sync world state to all clients
	if not GameManager.is_server:
		npc_states = world_state.get("npc_states", {})
		world_objects = world_state.get("world_objects", {})
		time_of_day = world_state.get("time_of_day", 12.0)
		weather_state = world_state.get("weather_state", {"type": "clear"})
		community_faith_level = world_state.get("community_faith_level", 50)
		world_data_updated.emit()

@rpc("any_peer", "call_local")
func request_world_sync():
	# Client requests world state sync from server
	if GameManager.is_server:
		var sync_data = {
			"npc_states": npc_states,
			"world_objects": world_objects,
			"time_of_day": time_of_day,
			"weather_state": weather_state,
			"community_faith_level": community_faith_level
		}
		sync_world_state.rpc_id(multiplayer.get_remote_sender_id(), sync_data)