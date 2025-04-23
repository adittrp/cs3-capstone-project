extends Area2D

@export var value: int = 1

func _on_body_entered(body):
	if body.name == "Player":
		get_node("/root/World").add_coin(value)
		queue_free()
