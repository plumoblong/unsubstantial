extends Node2D
class_name PlayerHUD

@onready var crosshair : Node2D = $Crosshair
@onready var hitmarker : Sprite2D = $Hitmarker

var hitmarker_alpha : float = 0.0

var hand_hidden : bool = false
var punchhand_hidden : bool = true
var crosshair_tween_active : bool = false
var show_movement_info : bool = false
var show_movement_var : bool = false

var interact_tooltip : String = ""
var interact_description : String = ""

var score_lerp : float = 0.0
var health_lerp : float = 0.0

var last_hitmarker_tween : Tween

func update(viewbob : Vector2, spd : float) -> void:
	hitmarker.material.set_shader_parameter("alpha", hitmarker_alpha)
	$MovementInfo.visible = show_movement_info
	$Weapon.modulate = get_parent().stats.bullet.color
	$Weapon.offset.x = ((viewbob.x * 24) * spd)
	$Weapon.offset.y = ((viewbob.y * 32) * spd) + (clamp(get_parent().camera.height_offset * 0.5, -1.0, 2.0) * 32.0)
	
	$Vignette.modulate.a = (get_parent().movement_component.speed_bonus - 0.9)
	score_lerp = lerpf(score_lerp, float(_G.current_run.score), 0.1)
	$Info/Score.text = "[b]" + str(int(round(score_lerp))) + "[/b] pts"
	
	#$Info/EssenceIcon.speed_scale = pow(1.1 - get_parent().essence_component.ratio, 2)
	$Info/EssenceIcon/Essence.text = "[b]" + str(get_parent().essence_component.essence) + "[/b]/" + str(get_parent().essence_component.max_essence) + "esc"
	$Info/CrystalIcon/Crystal.text = "[b]" + str(_G.current_run.crystals_collected) + "[/b]"
	$InteractionTooltip.visible = get_parent().can_interact
	$InteractionTooltip.text = interact_tooltip
	$InteractionTooltip/Description.text = interact_description
	
	$Debug.visible = _G.debug_mode
	$MovementInfo/Label2.visible = show_movement_var

	if Engine.get_physics_frames() % 3 == 0:
		$MovementInfo/Label2.text = "BASIS: " + str(_G.vector_to_string(-get_parent().camera.head.global_transform.basis.z)) + "\nDASH VECTOR: " + _G.vector_to_string(get_parent().dash_component.final_vector) + "\nVEL: " + _G.vector_to_string(get_parent().velocity) + "\nCAN JUNP: " + str(get_parent().movement_component.can_jump).to_upper() + "\nDASHING: " + str(get_parent().dash_component.dashing).to_upper()
		$MovementInfo/Label.text = str(snappedf((get_parent().velocity * Vector3(1.0, 0.0, 1.0)).length(), 0.01)) + " m/s\n" + str(snappedf(get_parent().movement_component.speed_bonus, 0.01)) + "  BONUS"
	
	$MovementInfo/Key1.visible = Input.is_action_pressed("up")
	$MovementInfo/Key2.visible = Input.is_action_pressed("right")
	$MovementInfo/Key3.visible = Input.is_action_pressed("down")
	$MovementInfo/Key4.visible = Input.is_action_pressed("left")
	$MovementInfo/Key5.visible = Input.is_action_pressed("jump")

func hitmark() -> void:
	if last_hitmarker_tween: last_hitmarker_tween.kill()
	hitmarker_alpha = 1.0
	$HitmarkerSFX.pitch_scale = randf_range(0.8, 1.0)
	get_parent().movement_component.speed_bonus *= 1.1
	$HitmarkerSFX.play()
	#_G.game.wait()
	last_hitmarker_tween = _G.tween(self, "hitmarker_alpha", 0, 0.7 / get_parent().stats.actual_atkspd)
		
func hide_hand(speed : float = 0.25) -> void:
	hand_hidden = true
	_G.tween($Weapon, "position", Vector2($Weapon.position.x, 336.0), speed, Tween.TRANS_SINE)
	await get_tree().create_timer(speed).timeout
	$Weapon.visible = false
	return

func show_hand(speed : float = 0.25) -> void:
	hand_hidden = false
	$Weapon.visible = true
	_G.tween($Weapon, "position", Vector2($Weapon.position.x, 256.0), speed * get_parent().stats.bullet.fire_rate * get_parent().stats.bullet.fire_rate_mult, Tween.TRANS_SINE)
	return

#func hide_punchhand(speed : float = 0.2) -> void:
	#returnd
	#punchhand_hidden = true
	#_G.tween($PunchHand, "position", Vector2($PunchHand.position.x, 350), speed * clamp(get_parent().stat.dash.cooldown[0], 0.8, 1.0), Tween.TRANS_SINE, Tween.EASE_IN)
	#return
	
#func show_punchhand(speed : float = 0.1) -> void:
	#return
	#punchhand_hidden = false
	#_G.tween($PunchHand, "position", Vector2($PunchHand.position.x, 280), speed * clamp(get_parent().stat.dash.cooldown[0], 0.8, 1.0), Tween.TRANS_SINE, Tween.EASE_IN)
	#return
