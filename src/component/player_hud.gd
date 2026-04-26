extends Node2D
class_name PlayerHUD

@onready var crosshair : Node2D = $Crosshair
@onready var hitmarker : Sprite2D = $Hitmarker
@onready var movement_info : Node = $MovementInfo
@onready var info_score : RichTextLabel = $Info/Score
@onready var info_essence : RichTextLabel = $Info/EssenceIcon/Essence
@onready var info_crystal : RichTextLabel = $Info/CrystalIcon/Crystal
@onready var info : Node2D = $Info
@onready var eye : AnimatedSprite2D = $Eye
@onready var interaction_tooltip : Control = $InteractionOffset/InteractionTooltip
@onready var interaction_description : RichTextLabel = $InteractionOffset/InteractionTooltip/Description
@onready var debug_panel : Node2D = $Debug
@onready var hitmarker_sfx : AudioStreamPlayer = $HitmarkerSFX

# Movement info nodes
@onready var movement_label : Label = $MovementInfo/Label
@onready var movement_label2 : Label = $MovementInfo/Label2
@onready var movement_keys : Array = [
	$MovementInfo/Key1,
	$MovementInfo/Key2,
	$MovementInfo/Key3,
	$MovementInfo/Key4,
	$MovementInfo/Key5
]

var hitmarker_alpha : float = 0.0

var hand_hidden : bool = false
var hand_offset : int = 0

var crosshair_tween_active : bool = false
var show_movement_info : bool = false
var show_movement_var : bool = false

var interact_tooltip : String = ""
var interact_description : String = ""

var score_lerp : float = 0.0
var health_lerp : float = 0.0

var last_hitmarker_tween : Tween

# Cached parent references
var player : Player
var player_camera : Camera3D
var player_essence : EssenceComponent
var player_movement : PlayerMoveComponent
var player_stats : ItemStats
var player_dash : DashComponent

# Cached strings to reduce allocations
const BOLD_START : String = "[b]"
const BOLD_END : String = "[/b]"
const PTS_SUFFIX : String = " pts"
const ESC_SUFFIX : String = "esc"
const SHARD_SINGULAR : String = "soul"
const SHARDS_PLURAL : String = "souls"

func _ready() -> void:
	await get_tree().create_timer(0.1).timeout
	player = get_parent()
	player_camera = player.camera
	player_essence = player.essence_component
	player_movement = player.movement_component
	player_stats = player.stats
	player_dash = player.dash_component

func update(viewbob : Vector2, spd : float) -> void:
	if player == null: return
	hitmarker.material.set_shader_parameter("alpha", hitmarker_alpha)
	movement_info.visible = show_movement_info
	score_lerp = lerpf(score_lerp, float(_G.current_run.score), 0.1)
	info_score.text = BOLD_START + str(int(round(score_lerp))) + BOLD_END + PTS_SUFFIX
	
	info_essence.text = BOLD_START + str(player_essence.essence) + BOLD_END + "/" + str(player_essence.max_essence) + ESC_SUFFIX
	
	info_crystal.text = str(int(round(player.money))) + "soul"
		
	interaction_tooltip.visible = player.can_interact
	interaction_tooltip.text = interact_tooltip
	interaction_description.text = interact_description
	
	debug_panel.visible = _T.debug_flags[2]
	movement_label2.visible = show_movement_var
	
	if Engine.get_physics_frames() % 3 == 0:
		movement_label2.text = "BASIS: " + str(_G.vector_to_string(-player_camera.head.global_transform.basis.z)) + "\nDASH VECTOR: " + _G.vector_to_string(player_dash.final_vector) + "\nVEL: " + _G.vector_to_string(player.velocity) + "\nCAN JUNP: " + str(player_movement.can_jump).to_upper() + "\nDASHING: " + str(player_dash.dashing).to_upper()
		movement_label.text = str(snappedf((player.velocity * Vector3(1.0, 0.0, 1.0)).length(), 0.01)) + " m/s\n" + str(snappedf(player_movement.speed_bonus, 0.01)) + "  BONUS"
	
	# Update movement keys visibility
	movement_keys[0].visible = Input.is_action_pressed("up")
	movement_keys[1].visible = Input.is_action_pressed("right")
	movement_keys[2].visible = Input.is_action_pressed("down")
	movement_keys[3].visible = Input.is_action_pressed("left")
	movement_keys[4].visible = Input.is_action_pressed("jump")
	
	_update_positions()

func _update_positions() -> void:
	movement_info.position = _R.get_center()
	$InteractionOffset.position = _R.get_bottom_center()
	crosshair.position = _R.get_center()
	info.position = _R.get_bottom_left(false, 4, 4)
	eye.position = _R.get_top_center(false, 16)
	
func hitmark() -> void:
	if last_hitmarker_tween:
		last_hitmarker_tween.kill()
	hitmarker_alpha = 1.0
	hitmarker_sfx.pitch_scale = randf_range(0.8, 1.0)
	player_movement.speed_bonus *= 1.05
	hitmarker_sfx.play()
	last_hitmarker_tween = _G.tween(self, "hitmarker_alpha", 0, 0.7 / player_stats.actual_atkspd)

#func hide_hand(speed : float = 0.25) -> void:
	#hand_hidden = true
	#_G.tween(self, "hand_offset", 128, speed, Tween.TRANS_SINE)
	#await get_tree().create_timer(speed).timeout
	#weapon.visible = false
#
#func show_hand(speed : float = 0.25) -> void:
	#hand_hidden = false
	#weapon.visible = true
	#_G.tween(self, "hand_offset", -16, speed * player_stats.bullet.fire_rate * player_stats.bullet.fire_rate_mult, Tween.TRANS_SINE)


func eye_animation_finished() -> void:
	if eye.animation == "open":
		eye.play("default")
