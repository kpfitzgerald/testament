extends Node

signal dialogue_started(npc_id)
signal dialogue_ended(npc_id)
signal dialogue_choice_made(choice_data)

# Dialogue state
var current_dialogue: Dictionary = {}
var dialogue_history: Dictionary = {}
var active_npc: String = ""

# Biblical dialogue database
var dialogue_database: Dictionary = {
	"high_priest_aaron": {
		"name": "High Priest Aaron",
		"title": "Servant of the Most High",
		"personality": "wise_and_gentle",
		"dialogues": {
			"first_meeting": {
				"text": "Peace be with you, child. I am Aaron, servant of the Most High. I sense the divine spark within you. Have you come seeking wisdom or blessing?",
				"choices": [
					{
						"text": "I seek wisdom, wise one.",
						"response": "wisdom_seeker",
						"requirements": {},
						"moral_impact": 5
					},
					{
						"text": "I wish to make an offering.",
						"response": "offering_dialogue",
						"requirements": {"gold": 50},
						"moral_impact": 10
					},
					{
						"text": "I'm just passing through.",
						"response": "casual_greeting",
						"requirements": {},
						"moral_impact": 0
					}
				]
			},
			"wisdom_seeker": {
				"text": "The fear of the Lord is the beginning of wisdom. Tell me, what weighs upon your heart? Perhaps the ancient scrolls hold guidance for your path.",
				"choices": [
					{
						"text": "How can I grow in faith?",
						"response": "faith_guidance",
						"requirements": {},
						"skill_bonus": {"faith": 25}
					},
					{
						"text": "I seek to understand the scriptures.",
						"response": "scripture_study",
						"requirements": {"wisdom": 15},
						"skill_bonus": {"wisdom": 25}
					},
					{
						"text": "Thank you for your counsel.",
						"response": "blessing_farewell",
						"requirements": {},
						"moral_impact": 5
					}
				]
			},
			"offering_dialogue": {
				"text": "Your heart's desire to give is blessed. The temple serves all who seek the divine. Your offering will help feed the hungry and shelter the homeless.",
				"choices": [
					{
						"text": "I offer 50 gold coins.",
						"response": "small_offering",
						"requirements": {"gold": 50},
						"cost": {"gold": 50},
						"rewards": {"faith": 15, "blessing": "temple_favor"}
					},
					{
						"text": "I offer 200 gold coins.",
						"response": "generous_offering",
						"requirements": {"gold": 200},
						"cost": {"gold": 200},
						"rewards": {"faith": 40, "blessing": "divine_favor", "reputation": 20}
					},
					{
						"text": "I'll return when I have more to give.",
						"response": "offer_later",
						"requirements": {},
						"moral_impact": 0
					}
				]
			},
			"faith_guidance": {
				"text": "Faith grows through prayer, study, and service to others. Begin each day with gratitude, end it with reflection. Let your actions speak louder than your words.",
				"choices": [
					{
						"text": "I will follow this path.",
						"response": "accept_guidance",
						"requirements": {},
						"quest": "daily_prayers",
						"moral_impact": 10
					},
					{
						"text": "This seems difficult to maintain.",
						"response": "doubt_response",
						"requirements": {},
						"moral_impact": -2
					}
				]
			}
		},
		"repeat_dialogues": {
			"greeting": "May the peace of the Almighty be with you. How may I serve you today?",
			"busy": "I am preparing for the evening prayers. Please visit me after sunset if you need counsel."
		}
	},

	"merchant_benjamin": {
		"name": "Benjamin the Merchant",
		"title": "Trader of Fine Goods",
		"personality": "shrewd_but_honest",
		"dialogues": {
			"first_meeting": {
				"text": "Welcome, friend! I am Benjamin, and these are the finest goods in all the land. From Damascus silk to Arabian spices - what brings you to my stall?",
				"choices": [
					{
						"text": "Show me your wares.",
						"response": "browse_goods",
						"requirements": {},
						"action": "open_shop"
					},
					{
						"text": "I'm looking for work.",
						"response": "seeking_work",
						"requirements": {},
						"moral_impact": 0
					},
					{
						"text": "Just looking around.",
						"response": "window_shopping",
						"requirements": {},
						"moral_impact": 0
					}
				]
			},
			"seeking_work": {
				"text": "Ah, a person willing to work! I respect that. I need someone trustworthy to help with deliveries. The roads can be dangerous, but the pay is good.",
				"choices": [
					{
						"text": "I accept the job.",
						"response": "accept_delivery_quest",
						"requirements": {"level": 3},
						"quest": "merchant_delivery",
						"rewards": {"gold": 100, "trading_exp": 50}
					},
					{
						"text": "What are the risks?",
						"response": "explain_dangers",
						"requirements": {},
						"moral_impact": 0
					},
					{
						"text": "I'll think about it.",
						"response": "consider_offer",
						"requirements": {},
						"moral_impact": 0
					}
				]
			},
			"browse_goods": {
				"text": "Excellent choice! I have everything from daily necessities to rare treasures. What catches your eye?",
				"choices": [
					{
						"text": "Show me weapons and armor.",
						"response": "equipment_shop",
						"requirements": {},
						"action": "open_equipment_shop"
					},
					{
						"text": "I need supplies for travel.",
						"response": "travel_supplies",
						"requirements": {},
						"action": "open_supply_shop"
					},
					{
						"text": "Do you have any rare items?",
						"response": "rare_items",
						"requirements": {"trading": 20, "reputation": 50},
						"action": "open_rare_shop"
					}
				]
			}
		},
		"repeat_dialogues": {
			"greeting": "Back again, friend! What can Benjamin provide for you today?",
			"after_purchase": "Thank you for your business! May your journey be profitable and safe."
		}
	},

	"prophet_miriam": {
		"name": "Prophetess Miriam",
		"title": "Voice of Divine Revelation",
		"personality": "mystical_and_profound",
		"dialogues": {
			"first_meeting": {
				"text": "The winds have whispered of your coming, child of destiny. I am Miriam, and the visions flow through me like rivers in the desert. Seek you the sight beyond sight?",
				"choices": [
					{
						"text": "I seek understanding of my purpose.",
						"response": "purpose_vision",
						"requirements": {"wisdom": 20, "faith": 25},
						"moral_impact": 0
					},
					{
						"text": "Can you see my future?",
						"response": "future_reading",
						"requirements": {"gold": 100},
						"cost": {"gold": 100},
						"rewards": {"vision": "future_glimpse"}
					},
					{
						"text": "Your words are strange to me.",
						"response": "explain_gift",
						"requirements": {},
						"moral_impact": 0
					}
				]
			},
			"purpose_vision": {
				"text": "Close your eyes and listen with your spirit... I see a crossroads ahead, where your choices will echo through generations. You carry the weight of legacy, but also its power.",
				"choices": [
					{
						"text": "What must I do?",
						"response": "guidance_received",
						"requirements": {},
						"quest": "legacy_path",
						"moral_impact": 5
					},
					{
						"text": "I don't understand these riddles.",
						"response": "prophecy_unclear",
						"requirements": {},
						"moral_impact": -5
					}
				]
			},
			"future_reading": {
				"text": "The mists part before my sight... I see triumph and trial intertwined. A choice between power and righteousness approaches. Choose wisely, for the consequences reach beyond your lifetime.",
				"choices": [
					{
						"text": "I will remember your words.",
						"response": "prophecy_accepted",
						"requirements": {},
						"blessing": "prophetic_insight",
						"moral_impact": 5
					},
					{
						"text": "Can you be more specific?",
						"response": "details_requested",
						"requirements": {"faith": 40},
						"blessing": "detailed_vision"
					}
				]
			}
		},
		"repeat_dialogues": {
			"greeting": "The threads of fate bring you to me again. What does your spirit seek?",
			"cryptic": "The answers you seek are within you, waiting to be born through experience."
		}
	}
}

func start_dialogue(npc_id: String, _player_node = null):
	if not dialogue_database.has(npc_id):
		print("NPC dialogue not found: ", npc_id)
		return false

	active_npc = npc_id
	var npc_data = dialogue_database[npc_id]

	# Determine which dialogue to show
	var dialogue_key = "first_meeting"
	if dialogue_history.has(npc_id):
		# Check for special conditions or use repeat dialogue
		dialogue_key = _get_contextual_dialogue(npc_id)

	current_dialogue = npc_data.dialogues.get(dialogue_key, {})
	if current_dialogue.is_empty():
		current_dialogue = {"text": npc_data.repeat_dialogues.get("greeting", "Hello.")}

	# Update NPC state in WorldData
	if WorldData:
		WorldData.update_npc_state(npc_id, {
			"last_conversation": {
				"player_id": PlayerData.player_id,
				"timestamp": Time.get_unix_time_from_system(),
				"dialogue": dialogue_key
			}
		})

	dialogue_started.emit(npc_id)
	return true

func make_dialogue_choice(choice_index: int):
	if current_dialogue.is_empty() or not current_dialogue.has("choices"):
		return

	var choices = current_dialogue["choices"]
	if choice_index < 0 or choice_index >= choices.size():
		return

	var choice = choices[choice_index]

	# Check requirements
	if not _check_choice_requirements(choice.get("requirements", {})):
		print("Choice requirements not met")
		return

	# Apply costs
	_apply_choice_costs(choice.get("cost", {}))

	# Apply rewards
	_apply_choice_rewards(choice.get("rewards", {}))

	# Apply moral impact
	var moral_impact = choice.get("moral_impact", 0)
	if moral_impact != 0:
		PlayerData.moral_alignment += moral_impact
		PlayerData.moral_alignment = clamp(PlayerData.moral_alignment, -100, 100)

	# Apply skill bonuses
	var skill_bonus = choice.get("skill_bonus", {})
	for skill in skill_bonus:
		PlayerData.add_skill_experience(skill, skill_bonus[skill])

	# Start quest if specified
	if choice.has("quest"):
		_start_quest(choice["quest"])

	# Handle special actions
	if choice.has("action"):
		_handle_special_action(choice["action"])

	# Record choice in history
	_record_dialogue_choice(choice)

	# Continue to next dialogue or end
	if choice.has("response"):
		var npc_data = dialogue_database[active_npc]
		current_dialogue = npc_data.dialogues.get(choice["response"], {})
		if current_dialogue.is_empty():
			end_dialogue()
	else:
		end_dialogue()

	dialogue_choice_made.emit(choice)

func end_dialogue():
	dialogue_ended.emit(active_npc)
	active_npc = ""
	current_dialogue = {}

func _get_contextual_dialogue(npc_id: String) -> String:
	var npc_data = dialogue_database[npc_id]
	var world_time = WorldData.time_of_day if WorldData else 12.0

	# Check time-based dialogues
	if world_time >= 18.0 or world_time <= 6.0:
		if npc_data.repeat_dialogues.has("evening"):
			return "evening"

	# Check for special states
	var npc_state = WorldData.npc_states.get(npc_id, {}) if WorldData else {}
	var mood = npc_state.get("mood", "normal")

	if mood == "busy" and npc_data.repeat_dialogues.has("busy"):
		return "busy"

	# Default to greeting for repeat visits
	return "greeting"

func _check_choice_requirements(requirements: Dictionary) -> bool:
	for req in requirements:
		match req:
			"level":
				if PlayerData.level < requirements[req]:
					return false
			"gold":
				if InventorySystem.gold_coins < requirements[req]:
					return false
			"moral_alignment":
				if PlayerData.moral_alignment < requirements[req]:
					return false
			"reputation":
				# Check reputation system when implemented
				return true
			_:
				# Check skills
				if PlayerData.skills.has(req):
					if PlayerData.skills[req].level < requirements[req]:
						return false

	return true

func _apply_choice_costs(costs: Dictionary):
	for cost_type in costs:
		match cost_type:
			"gold":
				InventorySystem.gold_coins -= costs[cost_type]
			"health":
				PlayerData.health = max(1, PlayerData.health - costs[cost_type])
			_:
				# Handle item costs
				if InventorySystem.has_item(cost_type, costs[cost_type]):
					InventorySystem.remove_item(cost_type, costs[cost_type])

func _apply_choice_rewards(rewards: Dictionary):
	for reward_type in rewards:
		match reward_type:
			"gold":
				InventorySystem.gold_coins += rewards[reward_type]
			"faith":
				PlayerData.faith_points += rewards[reward_type]
			"experience":
				PlayerData.add_experience(rewards[reward_type])
			"reputation":
				# Add to reputation system when implemented
				pass
			"blessing":
				# Apply temporary or permanent blessing
				_apply_blessing(rewards[reward_type])
			"vision":
				# Provide special vision/prophecy
				_grant_vision(rewards[reward_type])

func _apply_blessing(blessing_type: String):
	# Implement blessing system
	match blessing_type:
		"temple_favor":
			print("You have received the temple's favor")
		"divine_favor":
			print("Divine favor shines upon you")
		"prophetic_insight":
			print("You gain prophetic insight")
		"detailed_vision":
			print("The future becomes clearer to you")

func _grant_vision(vision_type: String):
	match vision_type:
		"future_glimpse":
			print("You see glimpses of possible futures")

func _start_quest(quest_id: String):
	# Integrate with quest system when implemented
	print("Quest started: ", quest_id)

func _handle_special_action(action: String):
	match action:
		"open_shop":
			print("Opening merchant shop")
		"open_equipment_shop":
			print("Opening equipment shop")
		"open_supply_shop":
			print("Opening supply shop")
		"open_rare_shop":
			print("Opening rare items shop")

func _record_dialogue_choice(choice: Dictionary):
	if not dialogue_history.has(active_npc):
		dialogue_history[active_npc] = []

	dialogue_history[active_npc].append({
		"choice": choice,
		"timestamp": Time.get_unix_time_from_system(),
		"player_level": PlayerData.level,
		"moral_alignment": PlayerData.moral_alignment
	})

	# Record in WorldData for persistence
	if WorldData:
		WorldData.add_player_interaction(PlayerData.player_id, {
			"type": "dialogue_choice",
			"npc_id": active_npc,
			"choice_text": choice.get("text", ""),
			"moral_impact": choice.get("moral_impact", 0)
		})

func get_current_dialogue_text() -> String:
	return current_dialogue.get("text", "")

func get_current_choices() -> Array:
	var choices = current_dialogue.get("choices", [])
	var available_choices = []

	for i in range(choices.size()):
		var choice = choices[i]
		if _check_choice_requirements(choice.get("requirements", {})):
			available_choices.append({
				"index": i,
				"text": choice.get("text", ""),
				"disabled": false
			})
		else:
			available_choices.append({
				"index": i,
				"text": choice.get("text", "") + " (Requirements not met)",
				"disabled": true
			})

	return available_choices

func get_npc_info(npc_id: String) -> Dictionary:
	if not dialogue_database.has(npc_id):
		return {}

	var npc_data = dialogue_database[npc_id]
	return {
		"name": npc_data.get("name", npc_id),
		"title": npc_data.get("title", ""),
		"personality": npc_data.get("personality", "normal")
	}

func save_dialogue_data() -> Dictionary:
	return {
		"dialogue_history": dialogue_history
	}

func load_dialogue_data(data: Dictionary):
	dialogue_history = data.get("dialogue_history", {})