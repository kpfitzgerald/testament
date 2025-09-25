extends Node

enum LogLevel {
	DEBUG,
	INFO,
	WARNING,
	ERROR,
	CRITICAL
}

var log_file_path: String = "user://legacy_of_divinity_log.txt"
var session_start_time: String
var log_file: FileAccess

func _ready():
	session_start_time = Time.get_datetime_string_from_system()
	initialize_logging()
	print("Logger initialized successfully")

func initialize_logging():
	log_file = FileAccess.open(log_file_path, FileAccess.WRITE)
	if log_file:
		log_file.store_line("")
		log_file.store_line("================================================================================")
		log_file.store_line("LEGACY OF DIVINITY - SESSION LOG")
		log_file.store_line("Session Start: " + session_start_time)
		log_file.store_line("================================================================================")
		log_file.flush()
		print("Log file created at: " + log_file_path)
	else:
		print("ERROR: Could not create log file")

func log_debug(system: String, message: String):
	_write_log(LogLevel.DEBUG, system, message)

func log_info(system: String, message: String):
	_write_log(LogLevel.INFO, system, message)

func log_warning(system: String, message: String):
	_write_log(LogLevel.WARNING, system, message)

func log_error(system: String, message: String, error_details: String = ""):
	var full_message = message
	if error_details != "":
		full_message += " | Details: " + error_details
	_write_log(LogLevel.ERROR, system, full_message)

func log_critical(system: String, message: String, error_details: String = ""):
	var full_message = message
	if error_details != "":
		full_message += " | CRITICAL DETAILS: " + error_details
	_write_log(LogLevel.CRITICAL, system, full_message)

func _write_log(level: LogLevel, system: String, message: String):
	var timestamp = Time.get_datetime_string_from_system()
	var level_name = LogLevel.keys()[level]
	var log_line = "[%s] [%s] [%s] %s" % [timestamp, level_name, system, message]

	print(log_line)

	if log_file:
		log_file.store_line(log_line)
		log_file.flush()

func log_function_entry(system: String, function_name: String, parameters: String = ""):
	var message = "ENTER: " + function_name
	if parameters != "":
		message += " | Params: " + parameters
	log_debug(system, message)

func log_player_action(action: String, details: String = ""):
	var message = "Player Action: " + action
	if details != "":
		message += " | " + details
	log_info("PlayerAction", message)

func log_game_state_change(old_state: String, new_state: String):
	log_info("GameState", "State change: " + old_state + " -> " + new_state)

func log_scene_change(from_scene: String, to_scene: String):
	log_info("SceneManager", "Scene change: " + from_scene + " -> " + to_scene)

func close_log():
	if log_file:
		log_info("Logger", "=== Session Ended ===")
		log_file.close()

func _exit_tree():
	close_log()