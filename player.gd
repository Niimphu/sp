extends CharacterBody2D

@export var speed = 300.0

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())
	

func _physics_process(delta):
	if !is_multiplayer_authority():
		return
	
	var direction = Input.get_vector("left", "right", "up", "down")
	if direction:
		velocity = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.y = move_toward(velocity.y, 0, speed)
	move_and_slide()
	
