extends Node3D
class_name VisualBullet

@export var shoot_component : ShootComponent
@export var no_depth_test : bool = false
@export var auto_rotate : bool = true
@export var reset_time_offset_mult : float = 0.75

@export_category("animation only")
@export var scale_mult : Vector3 = Vector3.ONE

var bounciness : Vector2 = Vector2.ZERO

const SIZE_CLAMP_MIN : float = 34.0
const SIZE_CLAMP_MAX : float = 1000.0

var _config : BulletSettings

@onready var sprite : Sprite3D = get_node("Sprite")
@onready var animation : AnimationPlayer = get_node("AnimationPlayer")

const BOUNCINESS_SPEED : float = 4.0

var can_setup : bool = false

func _ready() -> void:
	can_setup = true

func setup(config : BulletSettings) -> void:
	can_setup = true
	shoot_component.shooted.connect(shooted)
	_config = config

func _setup_animation() -> void:
	animation.speed_scale  = _config.fire_rate * _config.fire_rate_mult

func _update_animation(delta) -> void:
	bounciness.x = _G.sine_movement(BOUNCINESS_SPEED * _config.life_time * 2.0, min(0.25 + _config.bounciness, 1.5), delta)
	bounciness.y = _G.sine_movement(BOUNCINESS_SPEED * _config.life_time * 2.0, min(0.25 + _config.bounciness, 1.5), delta, BOUNCINESS_SPEED * _config.life_time * 2.0)
	scale_mult = Vector3.ONE + Vector3(bounciness.x, bounciness.y, 0.0)
	sprite.global_position = lerp(sprite.global_position, self.global_position, _config.init_speed * 1.25 * delta)
	_update_rotation_to_velocity()

func _update_rotation_to_velocity() -> void:
	if not auto_rotate: return
	#this is used in case where the parent node position is 0.0.0 but 
	#the visual bullet position z is offset 
	var p : Node3D = get_parent()
	p.look_at(_G.player.global_position)
	p.rotation_degrees.x = 0.0

func _setup_texture() -> void:
	sprite.modulate = _config.color
	if _config.sprite_override == null: return
	sprite.texture = _config.sprite_override

func _setup_scale() -> void:
	var clamped_damage : float = clampf(shoot_component.config.damage, Bullet.SIZE_CLAMP_MIN, Bullet.SIZE_CLAMP_MAX)
	var size: float = Bullet.BASE_SIZE + clampf(clamped_damage / Bullet.SIZE_DIVISOR, 0.0, 3.0)
	scale = Vector3.ONE * size * _config.size_mult

func _physics_process(delta: float) -> void:
	_update_animation(delta)
	sprite.scale *= scale_mult
	if not can_setup: return
	sprite.no_depth_test = no_depth_test
	_setup_animation()
	_setup_texture()
	_setup_scale()

func shooted() -> void:
	hide_anim()
	await get_tree().create_timer((_config.fire_rate * _config.fire_rate_mult) * reset_time_offset_mult).timeout
	reset()
	
func reset() -> void:
	_setup_animation()
	_setup_texture()
	_setup_scale()
	show_anim()

func hide_anim() -> void:
	animation.play("fade")
	
func show_anim() -> void:
	animation.play_backwards("fade")
