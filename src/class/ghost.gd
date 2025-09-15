extends Sprite3D
class_name Ghost


@export var sprite : Texture2D = load("res://images/entity/human.png")
@export var lifetime : float = 0.5
@export var sound_pitch : float = 1.0
@export var sound : AudioStream = load("res://sfx/death.wav")

var t : int

func _ready() -> void:
	texture = sprite
	_G.player.camera.tween_camera_fov(15, 1.7)
	_G.tween(self, "modulate", Color.TRANSPARENT, lifetime)
	$SFX.pitch_scale = randf_range(0.90, 1.1)
	$SFX.play()

func sfx_finished() -> void:
	queue_free()
