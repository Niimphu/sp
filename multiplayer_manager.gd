extends Node

const APP_ID = 480
const MAX_CODE_ATTEMPTS = 10

var lobby_id: int = 0
var pending_code: String = ""
var join_code: String = ""
var peer : SteamMultiplayerPeer
var is_host: bool = false
var is_joining: bool = false
var creating_lobby: bool = false
var code_attempts: int = 0

var player_one: int = 0
var player_two: int = 0


enum { FAIL, SUCCESS }
signal code_created(status)
signal player_joined_lobby(player)


func _ready():
	randomize()
	print("Steam initialised:", Steam.steamInit(APP_ID, true))

	Steam.initRelayNetworkAccess()
	Steam.lobby_created.connect(_on_lobby_created)
	Steam.lobby_joined.connect(_on_lobby_join)
	Steam.lobby_match_list.connect(_on_lobby_match_list)
	multiplayer.peer_connected.connect(_on_player_join_lobby)
	
	code_created.connect(_on_code_created)


func generate_code() -> String:
	var chars = "ABCDEFGHJKLMNPQRSTUVWXYZ1234567890"
	var code = ""
	for i in 5:
		code += chars[randi() % chars.length()]
	return code


func host_lobby():
	if lobby_id:
		return
	_try_create_code()
	is_host = true


func _try_create_code():
	pending_code = generate_code()
	_check_code()


func _check_code():
	Steam.addRequestLobbyListStringFilter(
		"join_code",
		pending_code,
		Steam.LobbyComparison.LOBBY_COMPARISON_EQUAL
	)
	
	Steam.requestLobbyList()


func _on_lobby_match_list(lobbies: Array):
	if is_joining:
		attempt_join_lobby(lobbies)
	else:
		attempt_create_join_code(lobbies)


func attempt_join_lobby(lobbies: Array):
	if lobbies.size() == 0:
		print("Lobby not found")
	else:
		Steam.joinLobby(lobbies[0])


func attempt_create_join_code(lobbies: Array):
	if (creating_lobby and lobbies.size() > 1) or lobbies.size() > 0:
		code_attempts += 1
		if code_attempts >= MAX_CODE_ATTEMPTS:
			code_attempts = 0
			pending_code = ""
			creating_lobby = false
			code_created.emit(FAIL)
		else:
			_try_create_code()
	else:
		code_created.emit(SUCCESS)


func _on_code_created(status: int):
	match status:
		FAIL:
			if creating_lobby:
				_leave_lobby()
		SUCCESS:
			if creating_lobby:
				return
			Steam.createLobby(Steam.LobbyType.LOBBY_TYPE_PUBLIC, 2)


func _on_lobby_created(result: int, lobby_id: int):
	if result == Steam.Result.RESULT_OK:
		self.lobby_id = lobby_id
		Steam.setLobbyData(lobby_id, "join_code", pending_code)
		
		creating_lobby = true
		
		_check_code()
		await code_created
		join_code = pending_code
		Steam.setLobbyData(lobby_id, "join_code", pending_code)
		
		if not creating_lobby:
			return
		creating_lobby = false
		
		
		peer = SteamMultiplayerPeer.new()
		peer.server_relay = true
		peer.create_host()
		
		multiplayer.multiplayer_peer = peer
		
		pending_code = ""
		var check = Steam.getLobbyData(lobby_id, "join_code")
		print("JOIN CODE SET:", join_code, " | READ BACK:", check)
		print("Lobby created with ID: ", lobby_id, " join code: ", join_code)
	else:
		print("Steam failge: createLobby")


func join_lobby(_join_code: String):
	if lobby_id:
		return
	
	is_joining = true
	
	join_code = _join_code.strip_edges().to_upper()
	print(join_code)
	
	Steam.addRequestLobbyListStringFilter(
		"join_code",
		join_code,
		Steam.LOBBY_COMPARISON_EQUAL)
	
	Steam.requestLobbyList()


func debug_lobby_list():
	Steam.addRequestLobbyListStringFilter(
		"join_code",
		"",
		Steam.LobbyComparison.LOBBY_COMPARISON_NOT_EQUAL
	)
	
	Steam.requestLobbyList()


func _on_lobby_join(lobby_id: int, permissions: int, locked: bool, response: int):
	if !is_joining:
		return
	
	if response != Steam.Result.RESULT_OK:
		print("Failed to join lobby")
		is_joining = false
		return
	
	self.lobby_id = lobby_id
	is_joining = false
	
	peer = SteamMultiplayerPeer.new()
	peer.server_relay = true
	peer.create_client(Steam.getLobbyOwner(lobby_id))
	
	multiplayer.multiplayer_peer = peer
	
	print("Joined lobby: ", lobby_id)


func _on_player_join_lobby(id: int):
	pass


func _leave_lobby():
	Steam.leaveLobby(lobby_id)
	lobby_id = 0
	join_code = ""


func join_player_one(id: int):
	if player_one:
		pass
	else:
		player_one = id


func join_player_two(id: int):
	if player_two:
		pass
	else:
		player_two = id
