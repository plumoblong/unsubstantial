extends CharacterBody3D
class_name EnemyGuard

@onready var movement_component : MovementComponent = get_node("MovementComponent")
@onready var chase_component : ChaseComponent = get_node("ChaseComponent")
@onready var essence_component : EssenceComponent = get_node("EssenceComponent")
@onready var shoot_component : ShootComponent = get_node("ShootComponent")
@onready var knockback_component : KnockbackComponent = get_node("KnockbackComponent")
@onready var agent : NavigationAgent3D = get_node("NavigationAgent3D")
@onready var enemy : EnemyComponent = get_node("EnemyComponent")

func _ready() -> void:
	enemy.setup(essence_component)
	knockback_component.knock(Vector3(randf_range(-1.0, 1.0), 0.5, randf_range(-1.0, 1.0)), 16.0)
	shoot_component.config.fire_rate = randf_range(1.15, 1.3)
	shoot_component.config.damage = enemy.damage
	$OmniLight3D.light_color = enemy.color
	
func essence_component_died(combo : bool) -> void:
	enemy.handle_death()
	
func essence_component_fractured(amount : int, i_time : float) -> void:
	enemy.handle_fracture(amount, i_time, movement_component, $OmniLight3D)
	
func _physics_process(delta : float) -> void:
	# Add the gravity.
	agent.debug_enabled = _G.debug_mode
	if global_position.y <= _G.game.chapter.current.y_boundary:
		essence_component.die()
	$"3DBar".from_value = essence_component.ratio
	#$Label3D.text = str(snappedf(float(essence_component.essence) / float(essence_component.start_essence) * 100, 1)) + "%"
	#$Label3D.text = str(essence_component.essence)
	movement_component.on_floor = is_on_floor()
	movement_component.update(delta, is_on_ceiling_only())
	essence_component.update()
	movement_component.enabled = _G.player.can_control
	chase_component.enabled = _G.player.can_control
	$HitSFX.pitch_scale = clamp($HitSFX.pitch_scale, 1.0, 1.5)
	
	velocity = movement_component.vel * float(_G.player.can_control)
	
	move_and_slide()
	
	if chase_component.attacking and _G.player.can_control:
		shoot_component.shoot(global_position.direction_to(_G.player.target.get_pos_multiplied(1.4)), global_position + Vector3(0.0, 0.9, 0.0))
	
	chase_component.update(_G.player.target.get_pos_multiplied(2.3), movement_component, agent)


func query_area_entered(area : Area3D) -> void:
	enemy.handle_query(area, essence_component, knockback_component)
			
func shoot_component_shooted() -> void:
	$ShootSFX.play()
