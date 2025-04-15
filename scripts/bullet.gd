extends Area2D

@export var speed := 800.0
var direction: Vector2 = Vector2.ZERO

func _physics_process(delta):
	position += direction * speed * delta

func _ready():
	await get_tree().create_timer(3.0).timeout
	queue_free()




func _on_body_entered(body: Node2D) -> void:
	queue_free()
	print("ARWA") # Replace with function body.
