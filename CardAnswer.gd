extends Resource

class_name CardAnswer

signal card_answered

@export var answered_card: bool

var current_value = false
func reset():
	current_value = true
	
func card_flipped():
	if answered:
		current_value = true
	else:
		current_value = false
