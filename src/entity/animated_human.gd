extends Sprite3D
class_name AnimatedHuman

@export var speed_scale : float = 1.5
@onready var anim : AnimationPlayer = $Anim

var _enemy : CharacterBody3D

const SPEED_THRESHOLD : float = 0.06
const DORMANT_THRESHOLD : float = 0.05

var _enemy_vel : Vector3

func _ready() -> void:
	_enemy = get_parent()
	
func _process(_delta: float) -> void:
	_enemy_vel = _enemy.velocity
	var walking : float = _enemy_vel.length() * SPEED_THRESHOLD
	var falling : bool = _enemy_vel.y < 0
	
	if walking > DORMANT_THRESHOLD:
		if falling: anim.play("falling")
		else: anim.play("walking")
		anim.speed_scale = walking * speed_scale
	else:
		anim.play("stop")
