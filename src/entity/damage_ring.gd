extends Node3D
class_name DamageRing

@onready var ripple : Sprite3D = get_node("Ripple")
@onready var anim : AnimationPlayer = get_node("Animation")
@onready var hitbox : CollisionShape3D = get_node("Area3D/CollisionShape3D")

@export var speed : float = 1.0
@export var radius : float = 10.0

@export var hitbox_radius : float = 0.0

const RIPPLE_PIXEL_SIZE : float = 0.062

func _ready() -> void:
	anim.speed_scale = speed
	ripple.pixel_size = RIPPLE_PIXEL_SIZE * radius
	anim.play("explode")
	hitbox.shape = hitbox.shape.duplicate()

func _process(_delta: float) -> void:
	hitbox.shape.radius = hitbox_radius * radius
	
func animation_tree_animation_finished(anim_name: StringName) -> void:
	if anim_name == "explode": queue_free.call_deferred()
