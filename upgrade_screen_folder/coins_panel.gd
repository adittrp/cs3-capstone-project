# panel_styled_tabcontainer.gd
# A TabContainer subclass styled to look like a PanelContainer,
# with customizable corner radius, border, and background color.

extends PanelContainer

@export var corner_radius: int    = 12                    # Radius of all four corners
@export var border_width:  int    = 2                     # Thickness of the border
@export var bg_color:       Color = Color(0.1, 0.1, 0.1, 0.8)  # Semi‑transparent background
@export var border_color:   Color = Color(0.5, 0.5, 0.5, 0.5)  # Semi‑transparent border

func _ready() -> void:
	# Build a StyleBoxFlat that will be used for each page's PanelContainer
	var panel_style := StyleBoxFlat.new()
	
	# Apply uniform corner radius
	panel_style.set_corner_radius_all(corner_radius)
	
	# Set background color (includes alpha for translucency)
	panel_style.bg_color = bg_color
	
	# Set border thickness and color
	panel_style.set_border_width_all(border_width)
	panel_style.border_color = border_color
	
	# Override the “panel” stylebox on this TabContainer.
	# TabContainer uses a PanelContainer under the hood for its pages,
	# and it looks for a stylebox named "panel" when drawing that child.
	add_theme_stylebox_override("panel", panel_style)
