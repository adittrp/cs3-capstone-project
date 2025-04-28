# ProgressBar.gd
extends ProgressBar

# tweak this until the bar sits exactly where you want it
@export var offset: Vector2 = Vector2(-28, -75)

# this is the “exact filepath” from the ProgressBar node back up to your Enemy
@onready var enemy := get_node("../../") as CharacterBody2D

func _ready():
	if enemy == null:
		push_error("ProgressBar.gd: failed to find Enemy at '../../'")

func _process(delta: float) -> void:
	if enemy == null:
		return

	# 1) snap to the enemy’s world‐space position + offset
	global_position = enemy.global_position + offset

	# 2) cancel out any rotation from Enemy.look_at()
	rotation = -enemy.global_rotation

	# 3) ensure no weird scaling inheritance
	scale = Vector2.ONE
