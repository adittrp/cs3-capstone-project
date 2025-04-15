extends Area2D

@export var speed := 1600.0

var direction: Vector2 = Vector2.ZERO

func _physics_process(delta):
	position += direction * speed * delta

func _ready():
	await get_tree().create_timer(2.0).timeout
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	queue_free()
	if body.is_in_group("Enemies"):
		body.shot_at()
	else:
		body.queue_free() 
	print("ARWA") # Replace with function body.
