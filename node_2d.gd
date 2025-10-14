extends Node2D
var _pressed: bool = false
var _current_line: Line2D = null

func _input(event: InputEvent) -> void:
	# Mouse pressed
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_pressed = event.pressed

		if _pressed:
			# Start new line
			_current_line = Line2D.new()
			_current_line.width = 4
			_current_line.default_color = Color.BLUE
			add_child(_current_line)
			
			# Use local mouse position
			_current_line.add_point(get_local_mouse_position())
		else:
			_current_line = null

	# Mouse drag
	if event is InputEventMouseMotion and _pressed:
		if _current_line:
			_current_line.add_point(get_local_mouse_position())
