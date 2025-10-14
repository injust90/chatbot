extends Node2D

@onready var image_display = $TextureRect
@onready var input_field = $LineEdit
@onready var feedback_label = $Label

var current_word = ""
var flashcards = [
	{"image": "res://Art/cat.png", "word": "ねこ"},
	{"image": "res://Art/dog.png", "word": "いぬ"},
	{"image": "res://Art/mountain.png", "word": "やま"},
	{"image": "res://Art/まいにち.png", "word": "まいにち"},
	{"image": "res://Art/ひと.png", "word": "ひと"},
	{"image": "res://Art/いち.png", "word": "いち"}
]

var index = 0
var busy = false  # prevents multiple submits while feedback shows

func _ready():
	load_flashcard(index)
	input_field.call_deferred("grab_focus")
	input_field.connect("text_submitted", Callable(self, "_on_text_submitted"))
	input_field.connect("focus_exited", Callable(self, "_refocus_lineedit"))

func load_flashcard(i):
	input_field.keep_editing_on_text_submit = true
	var data = flashcards[i]
	image_display.texture = load(data["image"])
	current_word = data["word"]
	input_field.text = ""
	feedback_label.text = ""
	busy = false

func _on_text_submitted(text: String):
	#if busy:
		#return  # ignore input while waiting
	#busy = true

	if text == current_word:
		feedback_label.text = "✅ Correct!"
		feedback_label.add_theme_color_override("font_color", Color(0, 1, 0))  # green
		index = (index + 1) % flashcards.size()		
		await get_tree().create_timer(0.6).timeout  # short delay to show feedback
		load_flashcard(index)
	else:
		input_field.clear()
		feedback_label.text = "❌ Try again!"
		feedback_label.add_theme_color_override("font_color", Color(1, 0, 0))  # red
		busy = false  # allow retry immediately
