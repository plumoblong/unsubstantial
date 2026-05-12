extends Node3D
class_name DamageRing

@onready var ripple : Sprite3D = get_node("Ripple")
@onready var anim : AnimationPlayer = get_node("Animation")
@onready var sfx : AudioStreamPlayer3D = get_node("SFX")
@onready var hitbox : CollisionShape3D = get_node("Area3D/CollisionShape3D")

@export var speed : float = 1.0
@export var radius : float = 10.0

@export var hitbox_radius : float = 0.0

const RIPPLE_PIXEL_SIZE : float = 0.062

func _ready() -> void:
	anim.speed_scale = speed
	ripple.pixel_size = RIPPLE_PIXEL_SIZE * radius
	sfx.pitch_scale = randf_range(1.5, 1.6)
	anim.play("explode")
	#hitbox.shape = hitbox.shape.duplicate()

func _process(_delta: float) -> void:
	hitbox.scale = Vector3.ONE * hitbox_radius * radius

func sfx_finished() -> void:
	queue_free.call_deferred()
