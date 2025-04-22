extends ProgressBar

@onready var player = get_node("/root/World/Player")  # Adjust path if needed

func _ready() -> void:
	max_value = player.maxHealth
