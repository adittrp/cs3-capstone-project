extends Button

# Customize these in the Inspector if you like:
@export_range(0.0, 1.0, 0.01) var normal_alpha:  float = 1.0
@export_range(0.0, 1.0, 0.01) var hover_alpha:   float = 0.8
@export_range(0.0, 1.0, 0.01) var pressed_alpha: float = 0.5

# Cache the icon TextureRect
@onready var icon_rect: TextureRect = $TextureRect

func _ready() -> void:
	# Always process so we can catch mouse_up outside of the frame it happens
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Start in normal state
	icon_rect.modulate.a = normal_alpha

	# Connect signals using Godot 4’s Callable API
	connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	connect("mouse_exited",  Callable(self, "_on_mouse_exited"))
	connect("pressed",       Callable(self, "_on_pressed"))
	connect("button_up",     Callable(self, "_on_button_up"))

func _on_mouse_entered() -> void:
	icon_rect.modulate.a = hover_alpha

func _on_mouse_exited() -> void:
	icon_rect.modulate.a = normal_alpha

func _on_pressed() -> void:
	icon_rect.modulate.a = pressed_alpha

func _on_button_up() -> void:
	var lp = get_local_mouse_position()
	if get_rect().has_point(lp):
		icon_rect.modulate.a = hover_alpha
	else:
		icon_rect.modulate.a = normal_alpha
