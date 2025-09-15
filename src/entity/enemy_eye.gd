extends CharacterBody3D
class_name EnemyEye

@onready var mov : MovementComponent = get_node("MovementComponent")
@onready var esc : EssenceComponent = get_node("EssenceComponent")
@onready var knock : KnockbackComponent = get_node("KnockbackComponent")
@onready var sprite : Sprite3D = get_node("Sprite3D")

var random_y : float = 0.0
var color : Color
var stunned : bool = false

func _ready():
	random_y = randf_range(0.75, 1.25)
	esc.start_essence = _G.player.stats.damage * _G.player.stats.dash_damage_mult * _G.game.enemy_multiplier
	esc.essence = esc.start_essence
	color = _G.hsv_to_rgb(randf_range(0.0, 1.0), 1.0, 1.0)
	$OmniLight3D.light_color = color

func _physics_process(delta : float) -> void:

	mov.direction = global_position.direction_to(_G.player.global_position + Vector3(0.0, random_y, 0.0))
	$Label3D.text = str(esc.essence)
	esc.update()

	mov.enabled = _G.player.can_control
	mov.update_flying(delta)
	velocity = mov.vel
	move_and_slide()

func query_area_entered(area : Area3D) -> void:
	if area is Hazard:
		if area.damage < 1: return
		if area.get_parent() is EnemyEye or area.get_parent() is EnemyMelee or area.get_parent() is EnemyHuman: return
		if sprite.modulate != Color.WHITE: 
			esc.fracture(area.damage, area.crit)
			if area.get_parent() is Player: area.get_parent().hud.hitmark()
			knock.knock(area.get_parent().global_position, area.knockback_strength, area.knockback_y_strength)
			if area is Bullet: area.hit()

func essence_component_fractured(amount : int) -> void:
	
	var init_def = esc.defense
	esc.defense = 0.0
	sprite.modulate = Color.WHITE
	$OmniLight3D.light_color = Color.WHITE
	stunned = true
	_G.game.create_popup_text(global_position, str(amount))
	_G.tween(sprite, "modulate", Color("d4d4d4"), 0.2)
	_G.tween($OmniLight3D, "light_color", color, 0.2)
	_G.tween(esc, "defense", 1.0, 0.2)
	$HitSFX.pitch_scale = randf_range(0.9, 1.15)
	$HitSFX.play()
	await get_tree().create_timer(0.25).timeout
	stunned = false
	
func essence_component_died(combo : bool) -> void:
	
	_G.game.create_ghost(global_position, sprite.texture, sprite.pixel_size)
	_G.current_run.kills += 1
	_G.game.create_xporb(global_position, esc.start_essence / 50, 3.0)
	queue_free.call_deferred()
