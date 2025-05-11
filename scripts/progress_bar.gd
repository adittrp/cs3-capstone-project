extends ProgressBar

# tweak this until the bar sits exactly where you want it
@export var offset: Vector2 = Vector2(-28, -75)

# this is the exact filepath from the ProgressBar node back up to Enemy
@onready var enemy := get_node("../../") as CharacterBody2D

func _ready():
	if enemy == null:
		push_error("ProgressBar.gd: failed to find Enemy at '../../'")

func _process(_delta: float) -> void:
	if enemy == null:
		return

	# Snap to the enemy’s world‐space position + offset
	global_position = enemy.global_position + offset

	# Cancel out any rotation from Enemy.look_at()
	rotation = -enemy.global_rotation

	# Ensure no weird scaling inheritance
	scale = Vector2.ONE
