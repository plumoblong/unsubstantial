extends Sprite3D
class_name SpritePlaceholder

func timer_timeout() -> void:
	queue_free.call_deferred()
