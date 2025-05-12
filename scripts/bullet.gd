extends Area2D

# Projectile speed
@export var speed := 4500.0
# Amount of damage this projectile deals
var shotPower: int

# Direction the projectile will move in
var direction: Vector2 = Vector2.ZERO

func _physics_process(delta):
	# Move the projectile in the specified direction every frame
	position += direction * speed * delta


func _on_body_entered(body: Node2D) -> void:
	# Remove the projectile when it hits something
	queue_free()
	
	# If the object hit is an enemy, apply damage
	if body.is_in_group("Enemies"):
		body.shot_at(shotPower)
		
func bullet_lifetime(time: float):
	await get_tree().create_timer(time).timeout
	queue_free()
