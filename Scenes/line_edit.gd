extends Node2D

@onready var image_display = $TextureRect
@onready var input_field = $LineEdit
@onready var feedback_label = $Label

var current_word = ""
var flashcards = [
	{"image": "res://images/cat.png", "word": "ねこ"},
	{"image": "res://images/dog.png", "word": "いぬ"},
	{"image": "res://images/mountain.png", "word": "やま"}
]
var index = 0

func _ready():
	load_flashcard(index)
	input_field.connect("text_submitted", Callable(self, "_on_text_submitted"))

func load_flashcard(i):
	var data = flashcards[i]
	image_display.texture = load(data["image"])
	current_word = data["word"]
	input_field.text = ""
	feedback_label.text = ""

func _on_text_submitted(text):
	if text == current_word:
		feedback_label.text = "✅ Correct!"
		index = (index + 1) % flashcards.size()
		await get_tree().create_timer(1.0).timeout
		load_flashcard(index)
	else:
		feedback_label.text = "❌ Try again!"
