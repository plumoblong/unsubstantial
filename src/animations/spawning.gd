extends AnimatedSprite3D

func _ready() -> void:
	play("default")
	$AudioStreamPlayer3D.play()

func animation_finished() -> void:
	queue_free.call_deferred()
