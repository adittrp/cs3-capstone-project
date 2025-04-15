extends VBoxContainer

# Preload or load your audio files
var sound1 = preload("res://audios/click-buttons-ui-menu-sounds-effects-button-13-205396.mp3")  # Hover
var sound2 = preload("res://audios/computer-processing-sound-effects-short-click-select-01-122134.mp3")  # Pressed

func _ready():
	# Connect the hover signal for all buttons
	for btn in [$Button, $Button2, $Button3]:
		btn.mouse_entered.connect(on_button_hover.bind(sound1))
		btn.pressed.connect(on_button_pressed)

func on_button_hover(sound: AudioStream):
	$AudioStreamPlayer2D.stream = sound
	$AudioStreamPlayer2D.volume_db = 6  # Increase volume (0 is default)
	$AudioStreamPlayer2D.play()

func on_button_pressed():
	$AudioStreamPlayer2D.stream = sound2
	$AudioStreamPlayer2D.volume_db = 10  # Same boost
	$AudioStreamPlayer2D.play()
