extends Node3D
class_name WorldTextPopup

@export var text: String = "Hello"
@export var big : bool = false
@export var normal_set : LabelSettings
@export var big_set : LabelSettings
@export var alpha_curve : Curve

@export_category("movement")
@export var fall_speed: float = 19.0
@export var bounciness: float = 0.5

@onready var text_object : Label = get_node("WorldTo2D/Text")
@onready var timer : Timer = get_node("Timer")

const FORCE_MULT : float = 6.0

var _speed : float = 1.0
var _settled: bool = false
var _was_on_floor : bool
var _vel : Vector3 = Vector3.ZERO
var _initial_vel : Vector3 = Vector3.UP
const INVERT_SHADER : ShaderMaterial = preload("res://material/ui_invert.tres")

func _ready() -> void:
	text_object.material = INVERT_SHADER.duplicate()
	text_object.text = text
	text_object.label_settings = big_set if big else normal_set
	_initial_vel = Vector3(randf_range(-1.0, 1.0), randf_range(0.0, 1.0), randf_range(-1.0, 1.0)).normalized()
	timer.start()

func _physics_process(delta: float) -> void:
	_vel = _initial_vel
	var life_time : float = 1.0 - (timer.time_left / timer.wait_time)
	_speed = 0.1 * (1.0 - life_time)
	text_object.material.set_shader_parameter("alpha", alpha_curve.sample(life_time))
	global_position += _vel * _speed

func timer_timeout() -> void:
	queue_free.call_deferred()
