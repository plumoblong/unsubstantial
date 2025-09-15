extends Control
class_name ChatFeed

@onready var message_container = $MessageContainer

const MAX_MESSAGES := 6
const LABEL : PackedScene = preload("res://prefab/menus/chat_text.tscn")
var message_history: Array = []

func add_message(text: String, color : Color = Color.WHITE) -> void:
	message_history.push_back([text, color])
	$AudioStreamPlayer.pitch_scale = randf_range(0.5, 1.0)
	$AudioStreamPlayer.play()
	_show_message(text, color)
	
func _show_message(text: String, color : Color = Color.WHITE) -> void:
	var label = LABEL.instantiate()
	label.text = text
	label.color = color
	label.size.x = 256.0
	message_container.add_child(label)
	
	if message_container.get_child_count() > MAX_MESSAGES:
		message_container.get_child(0).queue_free()

func _process(delta : float) -> void:
	if Input.is_action_just_pressed("chat"):
		_show_last_messages()

	if message_history.size() > MAX_MESSAGES:
		message_history.pop_front()

func _show_last_messages() -> void:
	for child: Node in message_container.get_children():
		child.queue_free()

	for msg in message_history:
		_show_message(msg[0], msg[1])
		print(msg[0], msg[1])
