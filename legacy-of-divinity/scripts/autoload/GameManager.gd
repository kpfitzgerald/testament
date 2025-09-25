extends Node

signal game_state_changed(new_state)
signal moral_choice_made(choice_data)

enum GameState {
	MENU,
	LOADING,
	PLAYING,
	PAUSED,
	CHOICE_DIALOG
}

var current_state: GameState = GameState.MENU
var current_player: Node = null

# Game settings
var game_version: String = "0.1.0"
var is_server: bool = false

func _ready():
	print("GameManager initialized - Legacy of Divinity v", game_version)
	# Wait for next frame to ensure Logger is fully initialized
	call_deferred("_post_init")

func _post_init():
	print("GameManager post-initialization complete")

func change_game_state(new_state: GameState):
	var old_state = current_state
	current_state = new_state

	game_state_changed.emit(new_state)
	print("Game state changed from ", GameState.keys()[old_state], " to ", GameState.keys()[new_state])

func make_moral_choice(choice_id: String, choice_value: int, consequences: Dictionary):
	print("Making moral choice: ", choice_id, " with value: ", choice_value)

	var choice_data = {
		"id": choice_id,
		"value": choice_value,  # -100 to 100 (evil to good)
		"consequences": consequences,
		"timestamp": Time.get_unix_time_from_system()
	}

	moral_choice_made.emit(choice_data)

	# Record in legacy system
	if LegacySystem:
		LegacySystem.record_moral_choice(choice_data)
		print("Choice recorded in legacy system")
	else:
		print("ERROR: LegacySystem not available for recording choice")

func get_current_player() -> Node:
	return current_player

func set_current_player(player: Node):
	current_player = player
	if player != null:
		print("Current player set: ", player.name)
	else:
		print("Current player set: null")