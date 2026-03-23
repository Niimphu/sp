extends Control

@export var main: Control
@export var play_menu: Control
@export var setup_menu: Control
@export var lobby_screen: Control

@export var play_button: Button
@export var options_button: Button
@export var quit_button: Button


func _ready() -> void:
	play_menu.visible = false
	setup_menu.visible = false
	lobby_screen.visible = false


func _process(delta: float) -> void:
	pass


func _on_play_button_pressed() -> void:
	main.visible = false
	play_menu.visible = true
	setup_menu.visible = true


func _on_options_button_pressed() -> void:
	pass # Replace with function body.


func _on_quit_button_pressed() -> void:
	get_tree().quit()
