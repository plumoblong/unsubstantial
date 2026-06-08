extends AnimatedSprite3D

var use_sound : bool = true

func _ready() -> void:
	play("default")
	if not use_sound: return
	$AudioStreamPlayer3D.pitch_scale = randf_range(0.45, 0.55)
	$AudioStreamPlayer3D.play()

func animation_finished() -> void:
	queue_free.call_deferred()
