extends Area2D

@export var value: int = 1
@onready var sfx := $AudioStreamPlayer2D
@onready var sprite   := $Sprite2D
@onready var collider := $CollisionShape2D

func _on_body_entered(body):
	if body.name == "Player":
		get_node("/root/World").add_coin(value)
		sfx.play()
		sprite.visible = false
		collider.disabled = true
		
		await sfx.finished
		queue_free()
