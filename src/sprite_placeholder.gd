extends Sprite3D
class_name SpritePlaceholder

func timer_timeout() -> void:
	delete()

func delete() -> void:
	queue_free.call_deferred()
