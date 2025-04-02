extends CharacterBody2D



func _process(delta):
	look_at(get_global_mouse_position())
	
@export var speed := 500.0  # Movement speed

func _physics_process(delta):
	var direction := Vector2.ZERO
	
	if Input.is_action_pressed("move_up"):
		direction.y -= 1
	if Input.is_action_pressed("move_down"):
		direction.y += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_right"):
		direction.x += 1

	direction = direction.normalized()
	velocity = direction * speed
	move_and_slide()
