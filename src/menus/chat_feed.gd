extends Control
class_name ChatFeed

@onready var message_container : Node = $MessageContainer
@onready var audio_player : AudioStreamPlayer = $AudioStreamPlayer

const MAX_MESSAGES : int = 5
const LABEL : PackedScene = preload("res://prefab/menus/chat_text.tscn")
const LABEL_WIDTH : float = 270.0

var message_history : Array = []

func add_message(text : String, color : Color = Color.WHITE) -> void:
	message_history.push_back([text, color])
	audio_player.pitch_scale = randf_range(0.5, 1.0)
	audio_player.play()
	_show_message(text, color)

func _show_message(text : String, color : Color = Color.WHITE) -> void:
	var label : Node = LABEL.instantiate()
	label.text = text
	label.color = color
	label.size.x = LABEL_WIDTH
	message_container.add_child(label)
	
	if message_container.get_child_count() > MAX_MESSAGES:
		message_container.get_child(0).queue_free()

func _process(_delta : float) -> void:
	if message_history.size() > MAX_MESSAGES:
		message_history.pop_front()

func _show_last_messages() -> void:
	for child : Node in message_container.get_children():
		child.queue_free()
	
	for msg : Array in message_history:
		_show_message(msg[0], msg[1])
