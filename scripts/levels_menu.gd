extends Node2D

const LEVELS_PER_PAGE := 20
const MAX_LEVEL := 100

@onready var level_grid = $VBoxContainer/Control2/GridContainer
@onready var prev_button = $VBoxContainer/Control3/HBoxContainer/Control/Button
@onready var next_button = $VBoxContainer/Control3/HBoxContainer/Control3/Button2
@onready var page_label = $VBoxContainer/Control3/HBoxContainer/Control2/Label


var current_page := 0



func _ready():
	prev_button.pressed.connect(_on_prev_page)
	next_button.pressed.connect(_on_next_page)
	update_grid()

func update_grid():
	# Clear old buttons
	for child in level_grid.get_children():
		level_grid.remove_child(child)
		child.queue_free()

	var start = current_page * LEVELS_PER_PAGE + 1
	var end = min(start + LEVELS_PER_PAGE - 1, MAX_LEVEL)

	for i in range(start, end + 1):
		var level_button = Button.new()
		level_button.text = "Level %d" % i
		level_button.custom_minimum_size = Vector2(240, 120)
		level_button.disabled = i > SaveData.MaxUnlockedLevel
		level_button.scale = Vector2.ONE  # Reset scale
		level_button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		
		# Mouse enter: grow
		level_button.mouse_entered.connect(func():
			var tween = level_button.create_tween()
			tween.tween_property(level_button, "scale", Vector2(1.1, 1.1), 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		)

		# Mouse exit: shrink back
		level_button.mouse_exited.connect(func():
			var tween = level_button.create_tween()
			tween.tween_property(level_button, "scale", Vector2.ONE, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		)

		level_button.pressed.connect(func(): _on_level_selected(i))
		level_grid.add_child(level_button)

	page_label.text = "Page %d / %d" % [current_page + 1, int(ceil(float(MAX_LEVEL) / LEVELS_PER_PAGE))]
	prev_button.disabled = current_page == 0
	next_button.disabled = (current_page + 1) * LEVELS_PER_PAGE >= MAX_LEVEL

func _on_prev_page():
	current_page = max(current_page - 1, 0)
	update_grid()

func _on_next_page():
	current_page += 1
	update_grid()

func _on_level_selected(level: int):
	SaveData.RoundLevel = level
	get_tree().change_scene_to_file("res://scenes/world.tscn")


		


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu_folder/main_menu.tscn")
