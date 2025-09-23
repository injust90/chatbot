# ChatClient.gd
extends Node

@onready var http := $HTTPRequest
@onready var chat_label := $ChatLabel

func send_player_message(message: String):
	var body = {
		"messages": [
			{"role": "system", "content": "You are Maru, a wise shopkeeper."},
			{"role": "user", "content": message}
		]
	}
	var json_body = JSON.stringify(body)
	http.request(
		"http://localhost:3000/api/chat",  # Your backend endpoint
		["Content-Type: application/json"],
		HTTPClient.METHOD_POST,
		json_body
	)

func _on_HTTPRequest_request_completed(_result, response_code, _headers, body):
	if response_code == 200:
		var text = body.get_string_from_utf8()
		var data = JSON.parse_string(text)
		chat_label.text += "\nNPC: " + data["reply"]
