extends Control

@onready var http := $HTTPRequest
@onready var chat_label := $ChatLabel
@onready var input_box := $InputBox

# Keep conversation history
var conversation : Array = [
	{"role": "system", "content": "You are Maru, a wise and friendly shopkeeper in a fantasy village. Keep replies short."}
]

func _ready():
	# Connect the LineEdit signal
	input_box.connect("text_submitted", Callable(self, "_on_input_submitted"))

func _on_input_submitted(new_text: String):
	if new_text.strip_edges() == "":
		return

	# Add user message to conversation
	conversation.append({"role": "user", "content": new_text})
	chat_label.append_text("\n[Player]: " + new_text)
	chat_label.scroll_to_line(chat_label.get_line_count())
	input_box.text = ""

	# Send to backend
	var body = {"messages": conversation}
	var err = http.request(
		"http://localhost:3000/api/chat",
		["Content-Type: application/json"],
		HTTPClient.METHOD_POST,
		JSON.stringify(body)
	)
	if err != OK:
		push_error("HTTPRequest failed: %s" % err)

func _on_HTTPRequest_request_completed(_result, response_code, _headers, body):
	print("Callback fired!")
	print("Response code:", response_code)

	if response_code != 200:
		print("❌ Request failed")
		return

	var text = body.get_string_from_utf8()
	print("📩 Raw server response:", text)

	# Directly parse into a Dictionary
	var data : Dictionary = JSON.parse_string(text)  # returns Dictionary in Godot 4.2+
	print("Data type:", typeof(data))
	print("Data content:", data)

	if data.has("reply"):
		var npc_reply = data["reply"]
		chat_label.append_text("\n[NPC]: " + npc_reply)
		chat_label.scroll_to_line(chat_label.get_line_count())
	else:
		print("⚠️ No 'reply' field in response")
