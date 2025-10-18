extends Node2D
#var flashcards := preload("res://MyDictionary.gd").flashcards
@export var flashcards: FlashcardsDictionary

@onready var image_display = $TextureRect
@onready var input_field = $LineEdit
@onready var feedback_label = $Label
@onready var finish_screen = $FinishScreen
@onready var english_word = $EnglishWord

var current_word = ""
var progress = {}
var save_path = "user://progress.save"
var tries = 0
var index = 0

func _ready():
	load_progress()
	save_progress()
	load_flashcard(index)
	debug_save()
	input_field.call_deferred("grab_focus")
	input_field.connect("text_submitted", Callable(self, "_on_text_submitted"))
	input_field.connect("focus_exited", Callable(self, "_refocus_lineedit"))

func save_progress():
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		file.store_var(progress)
		file.close()
		print("Progress saved!")		

func load_progress():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		progress = file.get_var()
		file.close()
		print("Progress loaded: ", progress)	
	else:
		progress = {}
		
func debug_save():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		var data = file.get_var()
		file.close()
		print("🧠 Save contents:", data)
	else:
		print("⚠️ No save file found at:", ProjectSettings.globalize_path(save_path))
		
# Loads flashcard into the screen
func load_flashcard(i):
	input_field.keep_editing_on_text_submit = true # keeps focus in window
	# If number of cards is still less than index AND cards are unanswered
	#if i < flashcards.size() && progress[current_word] == false:
	image_display.texture = load(flashcards.flashdict[i]["image"])
	current_word = flashcards.flashdict[i]["word"]
	input_field.text = ""
	feedback_label.text = ""
	# initialize the value in the dictionary for saving
	progress[current_word] = progress.get(current_word, 0)
	#else:
		#image_display.texture = null
		#finish_screen.text = "Finished!"
		#input_field.text = ""
		#feedback_label.text = ""
	english_word.set_text(flashcards.flashdict[i]["en-word"])
	
func _on_text_submitted(text: String):		
	if text == current_word:
		index = (index + 1) % flashcards.flashdict.size()
		#progress[current_word] = true # mark as completed
		progress[current_word] += 1
		save_progress() #save to file
		feedback_label.text = "✅ Correct!"
		feedback_label.add_theme_color_override("font_color", Color(0, 1, 0))  # green
		load_flashcard(index)
		tries = 0 # tries before hint system kicks in
		
	else:
		feedback_label.text = "❌ Try again!"
		feedback_label.add_theme_color_override("font_color", Color(1, 0, 0))  # red
		feedback_label.text = ""
		tries += 1
	
	if tries > 0:
		var hint_letter = ""
		hint_letter = flashcards.flashdict[index]["word"][tries - 1]
		input_field.text += hint_letter

func _on_reset_button_pressed() -> void:
	if FileAccess.file_exists(save_path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))
		progress.clear()
		index = 0
		load_flashcard(index)
		feedback_label.text = "Progress reset!"
		feedback_label.add_theme_color_override("font_color", Color(1, 0.5, 0))

	else:
		feedback_label.text = "No saved progress to reset."
		feedback_label.add_theme_color_override("font_color", Color(1, 0.5, 0))
