extends Panel

func _ready():
	var overlay = $ColorRect
	overlay.color = Color(0, 0, 0, 0.8)  # Black with 50% opacity

	# Start playing video
	$VideoStreamPlayer.play()
