extends Node3D
class_name VisualBullet

@export var shoot_component : ShootComponent
@export var no_depth_test : bool = false
@export var auto_rotate : bool = true
@export var reset_time_offset_mult  : float = 0.5

@export_category("animation only")
@export var scale_mult : Vector3 = Vector3.ONE

var _bounciness : Vector2 = Vector2.ZERO
var _bullet_size_mult : float = 1.0

const SIZE_CLAMP_MIN : float = 34.0
const SIZE_CLAMP_MAX : float = 1000.0

var _config : BulletSettings

@onready var sprite : Sprite3D = get_node("Sprite")
@onready var animation : AnimationPlayer = get_node("AnimationPlayer")

const BOUNCINESS_SPEED : float = 4.0

func _ready() -> void:
	show_anim()

func setup(config : BulletSettings) -> void:
	shoot_component.shooted.connect(shooted)
	_config = config

func _setup_animation() -> void:
	if not _config: return
	animation.speed_scale  = reset_time_offset_mult / (_config.fire_rate * _config.fire_rate_mult) * 2.0

func _update_animation(delta : float) -> void:
	if not _config: return
	var bounciness : float = min(0.5 + _config.bounciness, 2.0) * 6.0
	var b_speed : float = BOUNCINESS_SPEED * _config.life_time * 1.5
	_bounciness.x = _G.sine_movement(b_speed, bounciness, delta, b_speed * bounciness)
	_bounciness.y = _G.sine_movement(b_speed, bounciness, delta)
	sprite.scale = (scale_mult * _bullet_size_mult) + Vector3(_bounciness.x, _bounciness.y, 1.0)
	sprite.global_position = lerp(sprite.global_position, global_position, _config.init_speed * 1.25 * delta)
	_update_scale()
	_update_rotation_to_velocity()
	sprite.visible = bool(ceili(scale_mult.x))

func _update_rotation_to_velocity() -> void:
	if not _config: return
	if not auto_rotate: return
	#this is used in case where the parent node position is 0.0.0 but 
	#the visual bullet position z is offset 
	var p : Node3D = get_parent()
	p.look_at(_G.player.global_position)
	p.rotation_degrees.x = 0.0

func _setup_texture() -> void:
	if not _config: return
	sprite.modulate = _config.color
	if _config.sprite_override == null: return
	sprite.texture = _config.sprite_override

func _update_scale() -> void:
	if not _config: return
	var clamped_damage : float = clampf(shoot_component.config.damage, Bullet.SIZE_CLAMP_MIN, Bullet.SIZE_CLAMP_MAX)
	var size: float = Bullet.BASE_SIZE + clampf(clamped_damage / Bullet.SIZE_DIVISOR, 0.0, 3.0) * _config.size_mult
	_bullet_size_mult = size * _config.size_mult 
	
func _physics_process(delta: float) -> void:
	visible = shoot_component.enabled
	_update_animation(delta)

func shooted() -> void:
	if not _config: return
	hide_anim()
	await get_tree().create_timer(reset_time_offset_mult / (_config.fire_rate * _config.fire_rate_mult)).timeout
	reset()
	
func reset() -> void:
	if not _config: return
	_setup_animation()
	_setup_texture()
	show_anim()

func hide_anim() -> void:
	animation.play("fade")
	
func show_anim() -> void:
	animation.play_backwards("fade")
