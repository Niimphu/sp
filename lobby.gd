extends Control

@export var player_scene: PackedScene

@export var host_button: Button
@export var id_prompt: LineEdit
@export var join_button: Button
@export var log: RichTextLabel
@export var setup_menu: Control
@export var lobby_screen: Control
@export var player_one_label: Label
@export var player_two_label: Label


func _ready() -> void:
	multiplayer.peer_connected.connect(_on_player_join_lobby)
	Steam.lobby_created.connect(_on_lobby_created)
	Steam.lobby_joined.connect(_on_lobby_join)


func switch_to_lobby_screen():
	setup_menu.visible = false
	lobby_screen.visible = true


func _on_lobby_created(result: int, lobby_id: int):
	switch_to_lobby_screen()
	await MultiplayerManager.code_created
	log.text += "\nLobby created with code: " + MultiplayerManager.join_code


func _on_lobby_join(lobby_id: int, permissions: int, locked: bool, response: int):
	switch_to_lobby_screen()
	log.text += "\nYou create lobby"


func _add_player(id: int = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child", player)


func _on_player_join_lobby(id: int):
	print("Player joined with id: ", id)


func _remove_player(id: int):
	if !self.has_node(str(id)):
		return
	
	self.get_node(str(id)).queue_free()


func _on_host_button_pressed() -> void:
	MultiplayerManager.host_lobby()


func _on_id_prompt_text_changed(new_text: String) -> void:
	join_button.disabled = new_text.length() < 1


func _on_join_button_pressed() -> void:
	MultiplayerManager.join_lobby(id_prompt.text)


func _on_p1_join_button_pressed() -> void:
	player_one_label.text = Steam.getPersonaName()


func _on_p2_join_button_pressed() -> void:
	player_two_label.text = Steam.getPersonaName()
