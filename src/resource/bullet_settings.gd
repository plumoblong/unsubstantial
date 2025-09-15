extends Resource
class_name BulletSettings

@export var bullet_scene : PackedScene = preload("res://prefab/entity/bullet.tscn")
@export_subgroup("cosmetic")
@export var color : Color = Color.WHITE
@export var sprite_override : Texture2D
@export var size_mult : float = 1.0

@export_subgroup("meta")
@export var damage : int = 75
@export var fire_rate : float = 0.9
@export var fire_rate_mult : float = 1.0

@export_subgroup("shooting")
@export var shoot_offset : Vector3 = Vector3.ZERO
@export var shots : int = 1
@export var spread_angle : float = 30.0
@export var knockback : float = 24.0

@export_subgroup("other funny properties")
@export var piercing : bool = false
@export var homing : float = 0.0
@export var homing_on_player : bool = false
@export var homing_interlpolation : float = 0.75
@export var bouncy : bool = false
@export var spectral : bool = false
@export var stun : float = 0.1

@export_subgroup("object to spawm when the bullet destroys")
@export var destroy_object_enabled : bool = false
@export var destroy_on_life_time_end : bool = true
@export var destroy_object_amount : int = 1
@export var destroy_object : PackedScene
@export var destroy_object_properties : Dictionary = {}

@export_subgroup("speed")
@export var init_speed : float = 48.0
@export var fall_speed : float = 2.0
@export var life_time : float = 1.0

@export_subgroup("parrying")
@export var can_parry : bool = true
@export var parried_speed_multiplier : float = 0.75 

@export_subgroup("depracated. use if you want to set the position manually")
@export var bypass : bool = false
