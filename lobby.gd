extends Control

@export var player_scene: PackedScene

@export var host_button: Button
@export var id_prompt: LineEdit
@export var join_button: Button


func _ready() -> void:
	multiplayer.peer_connected.connect(_on_player_join_lobby)


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
