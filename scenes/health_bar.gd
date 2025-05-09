extends ProgressBar

# Reference to the player to sync health values
@onready var player = get_node("/root/World/Player")

func _ready() -> void:
	# Set the health bar's maximum based on the player's max health
	max_value = player.maxHealth
