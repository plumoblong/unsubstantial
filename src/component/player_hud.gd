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

var score_lerp : float = 0.0
var health_lerp : float = 0.0

func update(viewbob : Vector2, spd : float) -> void:
	hitmarker.material.set_shader_parameter("alpha", hitmarker_alpha)
	$MovementInfo.visible = show_movement_info
	$Weapon.modulate = get_parent().stats.bullet.color
	$Weapon.offset.x = ((viewbob.x * 24) * spd)
	$Weapon.offset.y = ((viewbob.y * 32) * spd) + (clamp(get_parent().camera.height_offset * 0.5, -1.0, 2.0) * 32.0)
	
	#bar code. went deprecated in 0.96 dev 05.08.25
	
	#$Bars/Level/Bar/Sprite2D2.visible = get_parent().level_component.locked
	#$Bars/Level/Bar.size.x = lerp($Bars/Level/Bar.size.x, get_parent().level_component.ratio * 116.0, 0.1)
	#$Bars/Level/Level.text = "LEVEL  " + str(get_parent().level_component.level)
	#$Bars/Level/XP.text = "XP   " + str(get_parent().level_component.xp) + "/" + str(get_parent().level_component.max_xp)
	#$Bars/Essence/Bar.size.x = lerp($Bars/Essence/Bar.size.x, get_parent().essence_component.ratio * 119.0, 0.1)
	#$Bars/Essence/Text.text = str(get_parent().essence_component.essence) + "  ESSENCE"
	#$Bars/Level.visible = get_parent().level_component.enabled
	#$Bars/Essence.visible = get_parent().essence_component.enabled
	
	$Vignette.modulate.a = 1.0 - get_parent().essence_component.ratio
	score_lerp = lerpf(score_lerp, float(_G.current_run.score), 0.1)
	$Info/Score.text = "[b]" + str(int(round(score_lerp))) + "[/b] pts"
	
	$Info/EssenceIcon.speed_scale = 1.25 - get_parent().essence_component.ratio
	$Info/EssenceIcon/Essence.text = "[b]" + str(get_parent().essence_component.essence) + "[/b]esc"
	#$Info/LevelIcon/Xp.text = str(snappedf(get_parent().level_component.ratio * 100.0, 0.1)) + "%"
	#$Info/LevelIcon/Xp.text = str(get_parent().level_component.xp) + "/" + str(get_parent().level_component.max_xp) + " XP"
	#$Info/LevelIcon/Level.text = "[b]" + str(get_parent().level_component.level)+ "[/b]  " + str(int(get_parent().level_component.xp)) + "/" + str(int(get_parent().level_component.max_xp)) + "xp"
	
	$InteractionTooltip.visible = get_parent().can_interact
	$InteractionTooltip.text = "[center]" + get_parent().interact_tooltip
	$InteractionTooltip/Description.text = "[center]" +  get_parent().interact_description.to_upper()
	
	$Debug.visible = _G.debug_mode
	$MovementInfo/Label2.visible = show_movement_var
	
	if Engine.get_physics_frames() % 4 == 0:
		$MovementInfo/Label2.text = "BASIS: " + str(_G.vector_to_string(-get_parent().camera.head.global_transform.basis.z)) + "\nDASH VECTOR: " + _G.vector_to_string(get_parent().dash_component.final_vector) + "\nVEL: " + _G.vector_to_string(get_parent().velocity) + "\nCAN JUNP: " + str(get_parent().movement_component.can_jump).to_upper() + "\nDASHING: " + str(get_parent().dash_component.dashing).to_upper()
		$MovementInfo/Label.text = str(snappedf((get_parent().velocity * Vector3(1.0, 0.0, 1.0)).length(), 0.01)) + "\n m/s"
	
	$MovementInfo/Key1.visible = Input.is_action_pressed("up")
	$MovementInfo/Key2.visible = Input.is_action_pressed("right")
	$MovementInfo/Key3.visible = Input.is_action_pressed("down")
	$MovementInfo/Key4.visible = Input.is_action_pressed("left")
	$MovementInfo/Key5.visible = Input.is_action_pressed("jump")
	


func hitmark() -> void:
	hitmarker_alpha = 1.0
	$HitmarkerSFX.pitch_scale = randf_range(0.8, 0.9)
	$HitmarkerSFX.play()
	_G.game.wait()
	_G.tween(self, "hitmarker_alpha", 0, 0.7)
	#var cw : float = crosshair_width
	#var cwm : float = cw * 1.5
	#crosshair_width = lerp(cwm * 1.5, cw, 0.5)
	#await get_tree().create_timer(0.5).timeout
	#return
	#if not crosshair_tween_active:
		#crosshair_tween_active = true
		#var cw : float = crosshair_width
		#var cwm : float = cw * 1.5
		#crosshair_width = cwm
		#_G.tween(self, "crosshair_width", cw, 0.5, 0, Tween.EASE_OUT)
		#await get_tree().create_timer(0.5).timeout
		#crosshair_tween_active = false
		#return
	#else:
		#return
		
func hide_hand(speed : float = 0.25) -> void:
	hand_hidden = true
	_G.tween($Weapon, "position", Vector2($Weapon.position.x, 336.0), speed * get_parent().stats.bullet.fire_rate * get_parent().stats.bullet.fire_rate_mult, Tween.TRANS_SINE)
	await get_tree().create_timer(speed * get_parent().stats.bullet.fire_rate * get_parent().stats.bullet.fire_rate_mult).timeout
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
