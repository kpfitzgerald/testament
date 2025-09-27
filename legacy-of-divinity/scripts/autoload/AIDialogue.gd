extends Node
# AI-powered NPC dialogue system for Testament
# Integrates with existing DialogueSystem for seamless conversations

# OpenAI API Configuration
var api_key: String = ""  # Set this in _ready() or project settings
var url: String = "https://api.openai.com/v1/chat/completions"
var temperature: float = 0.7  # Slightly higher for more varied biblical conversations
var max_tokens: int = 1024
var model: String = "gpt-4o-mini"
var headers: PackedStringArray = []

# HTTP Request handling
var request: HTTPRequest

# Current conversation state
var current_npc: Dictionary = {}
var messages: Array = []
var is_ai_thinking: bool = false

# Signals for integration with existing DialogueSystem
signal ai_response_ready(npc_name: String, dialogue: String)
signal ai_thinking_started
signal ai_thinking_finished

# Biblical dialogue rules and context
var biblical_dialogue_rules: String = """
You are a character from biblical times. Your responses should:
1. Use period-appropriate language (avoid modern expressions)
2. Reference God, faith, and divine providence naturally
3. Show knowledge of biblical events, customs, and geography
4. Speak with wisdom and moral authority when appropriate
5. Keep responses conversational (2-3 sentences max)
6. Stay in character and maintain consistency
7. Be family-friendly and respectful of religious themes
"""

func _ready():
	print("AIDialogue: Initializing AI NPC system")

	# Set your OpenAI API key
	api_key = "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"
	print("AIDialogue: API key loaded (length: ", api_key.length(), ")")

	# Set up headers with API key
	headers = ["Content-Type: application/json", "Authorization: Bearer " + api_key]

	# Create HTTP request node
	request = HTTPRequest.new()
	add_child(request)
	request.request_completed.connect(_on_request_completed)

	# Configure for HTTPS/SSL
	request.set_tls_options(TLSOptions.client())
	print("AIDialogue: SSL/TLS configured")

	print("AIDialogue: AI dialogue system ready")

# Start a conversation with an AI NPC
func start_dialogue(npc_data: Dictionary):
	print("AIDialogue: Starting dialogue with ", npc_data.get("name", "Unknown NPC"))

	current_npc = npc_data
	messages.clear()

	# Create initial system prompt based on NPC data
	var system_prompt = _create_npc_system_prompt(npc_data)

	# Add system message and request initial greeting
	messages.append({
		"role": "system",
		"content": system_prompt
	})

	# Request opening dialogue
	_send_ai_request("Greet the player. What do you say as they approach you?")

# Send player's dialogue to AI and get response
func send_player_dialogue(player_text: String):
	if is_ai_thinking:
		print("AIDialogue: AI is still processing previous request")
		return

	print("AIDialogue: Player says: ", player_text)
	_send_ai_request(player_text)

# Internal function to send requests to AI
func _send_ai_request(user_message: String):
	is_ai_thinking = true
	ai_thinking_started.emit()

	# Add user message to conversation
	messages.append({
		"role": "user",
		"content": user_message
	})

	# Create request body
	var body = JSON.stringify({
		"model": model,
		"messages": messages,
		"temperature": temperature,
		"max_tokens": max_tokens
	})

	# Debug the request
	print("AIDialogue: Sending request to OpenAI...")
	print("AIDialogue: URL: ", url)
	print("AIDialogue: Body: ", body)

	# Send request
	var error = request.request(url, headers, HTTPClient.METHOD_POST, body)
	if error != OK:
		print("AIDialogue: Error sending request: ", error)
		is_ai_thinking = false
		ai_thinking_finished.emit()
	else:
		print("AIDialogue: Request sent successfully, waiting for response...")

# Handle AI API response
func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	print("AIDialogue: Response received!")
	print("AIDialogue: Result: ", result)
	print("AIDialogue: Response code: ", response_code)
	print("AIDialogue: Body length: ", body.size())

	is_ai_thinking = false
	ai_thinking_finished.emit()

	if response_code != 200:
		print("AIDialogue: API error - Response code: ", response_code)
		var response_text = body.get_string_from_utf8()
		print("AIDialogue: Full error response: ", response_text)

		# Try to parse error details
		var json = JSON.new()
		var parse_result = json.parse(response_text)
		if parse_result == OK:
			var error_data = json.get_data()
			if error_data.has("error"):
				print("AIDialogue: Error details: ", error_data["error"])

		# Emit a fallback response for testing
		var npc_name = current_npc.get("name", "Unknown")
		ai_response_ready.emit(npc_name, "Peace be with you, traveler. I am " + npc_name + ". (API Error " + str(response_code) + " - check console for details)")
		return

	# Parse response
	var json = JSON.new()
	var parse_result = json.parse(body.get_string_from_utf8())

	if parse_result != OK:
		print("AIDialogue: Error parsing JSON response")
		return

	var response = json.get_data()

	if not response.has("choices") or response["choices"].size() == 0:
		print("AIDialogue: No choices in API response")
		return

	var ai_message = response["choices"][0]["message"]["content"]
	print("AIDialogue: AI responds: ", ai_message)

	# Add AI response to conversation history
	messages.append({
		"role": "assistant",
		"content": ai_message
	})

	# Emit response for DialogueSystem integration
	var npc_name = current_npc.get("name", "Unknown")
	ai_response_ready.emit(npc_name, ai_message)

# Create system prompt based on NPC data
func _create_npc_system_prompt(npc_data: Dictionary) -> String:
	var prompt = biblical_dialogue_rules + "\n\n"

	# Basic character info
	var name = npc_data.get("name", "a biblical character")
	var description = npc_data.get("physical_description", "a person from biblical times")
	var personality = npc_data.get("personality", "wise and faithful")
	var location = npc_data.get("location_description", "the Holy Land")

	prompt += "You are " + name + ", " + description + ". "
	prompt += "Your personality: " + personality + ". "
	prompt += "Current location: " + location + ". "

	# Secret knowledge system
	if npc_data.has("secret_knowledge") and npc_data["secret_knowledge"] != "":
		prompt += "You have special knowledge that you may share if asked directly: " + npc_data["secret_knowledge"] + ". "

	# Biblical context
	if npc_data.has("biblical_era"):
		prompt += "Time period: " + npc_data["biblical_era"] + ". "

	if npc_data.has("relationships"):
		prompt += "Important relationships: " + npc_data["relationships"] + ". "

	# Player context (if available through PlayerData)
	if PlayerData and PlayerData.player_name != "":
		prompt += "The player's character name is " + PlayerData.player_name + ". "

	return prompt

# End current dialogue session
func end_dialogue():
	print("AIDialogue: Ending dialogue with ", current_npc.get("name", "Unknown"))
	current_npc.clear()
	messages.clear()
	is_ai_thinking = false

# Utility function to check if AI is available
func is_ai_available() -> bool:
	return api_key != "" and api_key != "PASTE_YOUR_OPENAI_API_KEY_HERE"

# Get current NPC name
func get_current_npc_name() -> String:
	return current_npc.get("name", "")