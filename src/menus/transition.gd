extends CanvasLayer

var can_change_scene : bool = false

#func _ready() -> void:
	#if _G.game == null:
		#ascend_in()

func ascend_in(hide_bg : bool = false) -> void:
	_G.game.in_transition = true
	$GPUParticles2D2.visible = not hide_bg
	$GPUParticles2D3.visible = not hide_bg
	_G.flare_screen(Color(1, 1, 1, 0), Color(1, 1, 1, 1), 0.75)
	
	if _G.debug_mode:
		await get_tree().create_timer(1.5).timeout
	else:
		await get_tree().create_timer(0.75).timeout
	$AnimationPlayer.play("transition")
	if _G.config.ui_dark_mode: _G.shader_inverted = true
	else: _G.shader_inverted = false
	show()
	


func ascend_out() -> void:
	#$AnimationPlayer.play("transition_out")
	#await get_tree().create_timer(1.5).timeout
	_G.shader_inverted = false
	_G.flare_screen(Color.WHITE, Color(1, 1, 1, 0), 0.75)
	hide()
	_G.game.ending_level = false
	_G.game.in_transition = false
	can_change_scene = false
	_G.player.start_immunity(2)


func animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "transition":
		await get_tree().create_timer(0.3).timeout
		can_change_scene = true
		ascend_out()
