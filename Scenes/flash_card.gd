extends Node2D

@onready var image_display = $TextureRect
@onready var input_field = $LineEdit
@onready var feedback_label = $Label

var current_word = ""
var flashcards = [
	#{"image": "res://Art/cat.png", "word": "ねこ"},
	#{"image": "res://Art/dog.png", "word": "いぬ"},
	#{"image": "res://Art/mountain.png", "word": "やま"},
	#{"image": "res://Art/まいにち.png", "word": "まいにち"},
	#{"image": "res://Art/ひと.png", "word": "ひと"},
	#{"image": "res://Art/いち.png", "word": "いち"},
	#{"image": "res://Art/まいにち.png", "word": "まいにち"},
	#{"image": "res://Art/ことし.png", "word": "ことし"},
	#{"image": "res://Art/だす.png", "word": "だす"},
	#{"image": "res://Art/こ.png", "word": "こ"},
	#{"image": "res://Art/なか.png", "word": "なか"},
	#{"image": "res://Art/ほん.png", "word": "ほん"},
	#{"image": "res://Art/みえる.png", "word": "みえる"},
	#{"image": "res://Art/くに.png", "word": "くに"},
	#{"image": "res://Art/うえ.png", "word": "うえ"},
	{"image": "res://Art/いく.png", "word": "いく"},
	{"image": "res://Art/ちゅうがくせい.png", "word": "ちゅうがくせい"},
	{"image": "res://Art/ぶん.png", "word": "ぶん"}
]

var tries = 0
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
		tries = 0
	else:
		input_field.clear()
		feedback_label.text = "❌ Try again!"
		feedback_label.add_theme_color_override("font_color", Color(1, 0, 0))  # red
		await get_tree().create_timer(1.0).timeout
		feedback_label.text = ""
		busy = false  # allow retry immediately
		tries += 1
	
	if tries == 3:
		input_field.text = flashcards[index]["word"]
