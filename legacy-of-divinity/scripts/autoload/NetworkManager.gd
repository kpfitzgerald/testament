extends Node

signal player_connected(peer_id)
signal player_disconnected(peer_id)
signal server_started
signal connected_to_server
signal connection_failed

const DEFAULT_PORT = 7777
const MAX_CLIENTS = 100

var multiplayer_peer: MultiplayerPeer
var players_data: Dictionary = {}

func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func start_server(port: int = DEFAULT_PORT) -> bool:
	multiplayer_peer = ENetMultiplayerPeer.new()
	var error = multiplayer_peer.create_server(port, MAX_CLIENTS)

	if error == OK:
		multiplayer.multiplayer_peer = multiplayer_peer
		GameManager.is_server = true
		print("Server started on port ", port)
		server_started.emit()
		return true
	else:
		print("Failed to start server: ", error)
		return false

func connect_to_server(address: String, port: int = DEFAULT_PORT) -> bool:
	multiplayer_peer = ENetMultiplayerPeer.new()
	var error = multiplayer_peer.create_client(address, port)

	if error == OK:
		multiplayer.multiplayer_peer = multiplayer_peer
		print("Attempting to connect to ", address, ":", port)
		return true
	else:
		print("Failed to connect to server: ", error)
		return false

func disconnect_from_server():
	if multiplayer_peer:
		multiplayer_peer.close()
		multiplayer_peer = null

	multiplayer.multiplayer_peer = null
	players_data.clear()
	GameManager.is_server = false
	print("Disconnected from server")

func _on_player_connected(peer_id: int):
	print("Player connected: ", peer_id)
	players_data[peer_id] = {
		"name": "Player_" + str(peer_id),
		"connected_at": Time.get_unix_time_from_system()
	}
	player_connected.emit(peer_id)

func _on_player_disconnected(peer_id: int):
	print("Player disconnected: ", peer_id)
	if players_data.has(peer_id):
		players_data.erase(peer_id)
	player_disconnected.emit(peer_id)

func _on_connected_to_server():
	print("Successfully connected to server")
	connected_to_server.emit()

func _on_connection_failed():
	print("Failed to connect to server")
	connection_failed.emit()

func _on_server_disconnected():
	print("Server disconnected")
	disconnect_from_server()

@rpc("any_peer", "call_local")
func sync_player_data(player_data: Dictionary):
	var sender_id = multiplayer.get_remote_sender_id()
	players_data[sender_id] = player_data
	print("Synced player data for peer: ", sender_id)