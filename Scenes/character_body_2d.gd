extends CharacterBody2D

@export var speed = 400
@onready var _animated_sprite = $AnimatedSprite2D

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed

func _process(_delta):
	if Input.is_action_pressed("right"):
		_animated_sprite.play("run_right")
	
	if Input.is_action_just_pressed("left"):
		_animated_sprite.play("run_left")
		
	if Input.is_action_just_pressed("up"):
		_animated_sprite.play("run_up")
	
	if Input.is_action_just_pressed("down"):
		_animated_sprite.play("run_down")
	else:
		_animated_sprite.stop()
	
func _physics_process(_delta):
	get_input()
	move_and_slide()
