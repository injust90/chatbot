extends Node2D
#var flashcards := preload("res://MyDictionary.gd").flashcards
@export var flashcards: FlashcardsDictionary

@onready var image_display = $TextureRect
@onready var input_field = $LineEdit
@onready var feedback_label = $Label
@onready var finish_screen = $FinishScreen
@onready var english_word = $EnglishWord
@onready var audio_stream = $AudioStreamPlayer

var voice = AudioServer.get_bus_index("Voice")

var current_word = ""
var progress = {}
var save_path = "user://progress.save"
var tries = 0
var index = 0
var hint = ""
# Card with the highest number of errors
var highest_error = 0
var rng = RandomNumberGenerator.new()

func _ready():
	load_progress()
	save_progress()
	# Initialize the card with the highest error
	load_flashcard(highest_error)
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

# Inspects and prints the contents of the saved data file in Godot
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
	# For printing the current save state, useful for debugging
	print("Current save state: ", progress)
	# keeps focus in window
	input_field.keep_editing_on_text_submit = true 
	image_display.texture = load(flashcards.flashdict[i]["image"])
	current_word = flashcards.flashdict[i]["word"]
	input_field.text = ""
	feedback_label.text = ""
	load_flashcard_index()	
	# English hint system
	english_word.set_text(flashcards.flashdict[i]["en-word"])
	# Audio/Voices
	audio_stream.stream = AudioStreamWAV.load_from_file(flashcards.flashdict[i]["voice"])
	audio_stream.play()
	
# Indexes all the cards into save progress. Goes through the entire list of words, and tries to "get".
# Get gets nothing, so therefore it sets the value to 0 because of the parameter
func load_flashcard_index():
	for i in flashcards.flashdict.size():
		progress[i] = progress.get(current_word, 0)

# When the player hits enter
func _on_text_submitted(text: String):
	# Checking if text is correct
	if text == current_word:
		# Clever way to index around the whole index without going past the indexer
		index = (index + 1) % flashcards.flashdict.size()
		save_progress()
		feedback_label.text = "✅ Correct!"
		feedback_label.add_theme_color_override("font_color", Color(0, 1, 0))  # green
		
		# If highest error value is equal to 0; to avoid reloading same card we randomize
		if progress.values().max() == 0:
			highest_error = rng.randi_range(0, progress.size() - 1)
			# Index set to current key/index so it doesn't overflow
			index = highest_error
			
		load_flashcard(index)
		# Load the card with the highest error because we want to repeat that card till the player
		# gets it right
		tries = 0 # indexer and when greater than 0 hint system kicks in
		hint = "" # hint set back to blank
		highest_error = 0
		
		print ("index ", index)

	else:
		progress[highest_error] += 1
		input_field.text = ""
		feedback_label.text = "❌ Try again!"
		feedback_label.add_theme_color_override("font_color", Color(1, 0, 0))  # red
		feedback_label.text = ""
		tries += 1
		highest_error = progress.find_key(progress.values().max())

	if tries > 0:
		var hint_letter = ""
		hint_letter = flashcards.flashdict[index]["word"][tries - 1]
		hint += hint_letter
		print(hint)
		input_field.text = hint

# Resets the file system on reset 
func _on_reset_button_pressed() -> void:
	if FileAccess.file_exists(save_path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))
		progress.clear()
		index = 0
		load_flashcard(index)
		highest_error = 0
		feedback_label.text = "Progress reset!"
		feedback_label.add_theme_color_override("font_color", Color(1, 0.5, 0))

	else:
		feedback_label.text = "No saved progress to reset."
		feedback_label.add_theme_color_override("font_color", Color(1, 0.5, 0))
