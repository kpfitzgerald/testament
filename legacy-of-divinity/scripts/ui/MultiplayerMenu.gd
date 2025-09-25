extends Control

@onready var address_input = $VBoxContainer/AddressInput
@onready var port_input = $VBoxContainer/PortInput

func _ready():
	address_input.text = "127.0.0.1"
	port_input.text = "7777"

func _on_host_button_pressed():
	var port = int(port_input.text) if port_input.text.is_valid_int() else 7777

	if NetworkManager.start_server(port):
		print("Server hosted successfully on port ", port)
		# Go to game world as host
		get_tree().change_scene_to_file("res://scenes/world/GameWorld.tscn")
	else:
		print("Failed to host server")

func _on_join_button_pressed():
	var address = address_input.text if address_input.text != "" else "127.0.0.1"
	var port = int(port_input.text) if port_input.text.is_valid_int() else 7777

	if NetworkManager.connect_to_server(address, port):
		print("Attempting to join server at ", address, ":", port)
		# Wait for connection confirmation before changing scenes
		NetworkManager.connected_to_server.connect(_on_connected_to_server)
		NetworkManager.connection_failed.connect(_on_connection_failed)
	else:
		print("Failed to connect to server")

func _on_connected_to_server():
	print("Connected to server successfully")
	get_tree().change_scene_to_file("res://scenes/world/GameWorld.tscn")

func _on_connection_failed():
	print("Connection to server failed")
	# Could show error dialog here

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main/MainMenu.tscn")