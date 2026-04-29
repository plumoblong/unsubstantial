extends CharacterBody3D
class_name WorldTextPopup

@export var text: String = "Hello"
@export var big : bool = false
@export var normal_set : LabelSettings
@export var big_set : LabelSettings

@export var alpha_curve : Curve

@export_category("movement")
@export var fall_speed: float = 19.0
@export var bounciness: float = 0.5
@export var initial_force : Vector3 = Vector3.UP

@onready var text_object : Label = get_node("WorldTo2D/Text")
@onready var timer : Timer = get_node("Timer")

const FORCE_MULT : float = 6.0
const MIN_BOUNCE_VELOCITY: float = 0.25  # below this speed, stop bouncing

var _settled: bool = false
var _was_on_floor : bool

const INVERT_SHADER : ShaderMaterial = preload("res://material/ui_invert.tres")

func _ready() -> void:
	text_object.material = INVERT_SHADER.duplicate()
	text_object.text = text
	text_object.label_settings = big_set if big else normal_set
	velocity = initial_force * FORCE_MULT
	timer.start()

func _physics_process(delta: float) -> void:
	if is_on_floor():
		velocity = velocity * -bounciness * FORCE_MULT
	else:
		velocity.y -= fall_speed * delta
	move_and_slide()
	text_object.material.set_shader_parameter("alpha", alpha_curve.sample(timer.time_left / timer.wait_time))
	

func timer_timeout() -> void:
	queue_free.call_deferred()
