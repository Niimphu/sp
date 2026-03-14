extends Node2D

var lobby_id: int = 0
var peer : SteamMultiplayerPeer
@export var player_scene: PackedScene
var is_host: bool = false
var is_joining: bool = false

@onready var host_button: Button = $host_button
@onready var join_button: Button = $join_button
@onready var id_prompt: LineEdit = $id_prompt

func _ready():
	print("Steam initialised:", Steam.steamInit(480, true))
	Steam.initRelayNetworkAccess()
	Steam.lobby_created.connect(_on_lobby_created)
	Steam.lobby_joined.connect(_on_lobby_join)

func host_lobby():
	Steam.createLobby(Steam.LobbyType.LOBBY_TYPE_PUBLIC, 2)
	is_host = true

func _on_lobby_created(result: int, lobby_id: int):
	if result == Steam.Result.RESULT_OK:
		self.lobby_id = lobby_id
		
		peer = SteamMultiplayerPeer.new()
		peer.server_relay = true
		peer.create_host()
		
		multiplayer.multiplayer_peer = peer
		multiplayer.peer_connected.connect(_add_player)
		multiplayer.peer_disconnected.connect(_remove_player)
		_add_player()
		
		print("Lobby created with ID: ", lobby_id)
		var current_clipboard = DisplayServer.clipboard_get()
		DisplayServer.clipboard_set(str(lobby_id))


func _join_lobby(lobby_id: int):
	is_joining = true
	Steam.joinLobby(lobby_id)


func _on_lobby_join(lobby_id: int, permissions: int, locked: bool, response: int):
	if !is_joining:
		return
	
	self.lobby_id = lobby_id
	peer = SteamMultiplayerPeer.new()
	peer.server_relay = true
	peer.create_client(Steam.getLobbyOwner(lobby_id))
	multiplayer.multiplayer_peer = peer
	
	is_joining = false


func _add_player(id: int = 1):
	var player = player_scene.instantiate()#
	player.name = str(id)
	call_deferred("add_child", player)


func _remove_player(id: int):
	if !self.has_node(str(id)):
		return
	
	self.get_node(str(id)).queue_free()


func _on_host_button_pressed() -> void:
	host_lobby()


func _on_id_prompt_text_changed(new_text: String) -> void:
	join_button.disabled = new_text.length() < 1


func _on_join_button_pressed() -> void:
	_join_lobby(id_prompt.text.to_int())
