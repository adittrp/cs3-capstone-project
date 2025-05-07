extends Control


func _ready():
	for button in get_children():
		if button is Button:
			button.connect("gui_input", Callable(self, "_on_button_gui_input").bind(button))
			button.connect("mouse_entered", Callable(self, "_on_button_hovered").bind(button))
			button.connect("mouse_exited", Callable(self, "_on_button_unhovered").bind(button))

func _on_button_hovered(button):
	var icon = button.get_node("TextureRect")
	if icon:
		icon.modulate.a = 0.5

func _on_button_unhovered(button):
	var icon = button.get_node("TextureRect")
	if icon:
		icon.modulate.a = 1.0

func _on_button_gui_input(event, button):
	var icon = button.get_node("TextureRect")
	print(str(icon) + " icon!")
	if icon:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				icon.modulate.a = 0.3  # press effect
			else:
				# check if still hovered
				icon.modulate.a = 0.5 if button.get_rect().has_point(button.get_local_mouse_position()) else 1.0
