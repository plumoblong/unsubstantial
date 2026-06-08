extends Node
class_name SFXManager

@onready var music_player : AudioStreamPlayer = get_node("MusicPlayer")

var global_pitch : float = 1.0

func _ready() -> void:
	music_player.volume_linear = 0.0

func change_pitch(pitch : float = 1.0, time : float = 0.0) -> void:
	if time <= 0.0: 
		music_player.pitch_scale = pitch 
		return
	_G.tween(music_player, "pitch_scale", pitch, time)
	
func change_song(stream : AudioStream) -> void:
	
	if stream == music_player.stream: return
	music_player.stop()
	music_player.stream = stream
	music_player.play()

func _pause() -> void:
	music_player.stream_paused = not music_player.stream_paused
	
func fade_song(volume : float = 1.0, time : float = 0.5) -> void:
	if time <= 0.0: 
		music_player.volume_linear = volume 
		return
	_G.tween(music_player, "volume_linear", volume, time)
