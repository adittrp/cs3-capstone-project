extends TabContainer

@export var corner_radius: int = 12
@export var border_width: int = 2
@export var bg_color: Color = Color(0.1, 0.1, 0.1, 0.8)
@export var border_color: Color = Color(0.5, 0.5, 0.5, 0.5)

func _ready() -> void:
	var style_box := StyleBoxFlat.new()
	style_box.set_corner_radius_all(corner_radius)
	style_box.set_bg_color(bg_color)
	style_box.set_border_width_all(border_width)
	style_box.set_border_color(border_color)
	add_theme_stylebox_override("panel", style_box)
