extends CharacterBody3D
class_name EnemyMelee

@onready var movement_component : MovementComponent = get_node("MovementComponent")
@onready var chase_component : ChaseComponent = get_node("ChaseComponent")
@onready var essence_component : EssenceComponent = get_node("EssenceComponent")
@onready var dash_component : DashComponent = get_node("DashComponent")
@onready var knockback_component : KnockbackComponent = get_node("KnockbackComponent")
@onready var agent : NavigationAgent3D = get_node("NavigationAgent3D")
@onready var enemy : EnemyComponent = get_node("EnemyComponent")

func _ready() -> void:
	enemy.setup(essence_component)
	knockback_component.knock(Vector3(randf_range(-1.0, 1.0), 0.5, randf_range(-1.0, 1.0)), 16.0)
	$DashComponent.cooldown = 1.5
	$DashQuery.damage = enemy.damage
	$OmniLight3D.light_color = enemy.color
	
func essence_component_died(combo : bool) -> void:
	
	enemy.handle_death()

func essence_component_fractured(amount : int, i_time : float) -> void:
	enemy.handle_fracture(amount, i_time, movement_component, $OmniLight3D)
	
func _physics_process(delta : float) -> void:
	# Add the gravity.
	
	look_at(_G.player.target.get_pos_multiplied(enemy.random_factor))
	if _G.player.can_control:
		if dash_component.can_dash and chase_component.attacking:
			dash_component.dash(movement_component)
	agent.debug_enabled = _G.debug_mode
	if global_position.y <= -20.0:
		essence_component.die()
	
	if not dash_component.can_dash:
		chase_component.min_distance = 12.0
	else:
		chase_component.min_distance = 0.0
	
	#$Label3D.text = str(snappedf(float(essence_component.essence) / float(essence_component.start_essence) * 100, 1)) + "%"
	#$Label3D.text = str(essence_component.essence)
	$"3DBar".from_value = essence_component.ratio
	movement_component.on_floor = is_on_floor()
	movement_component.update(delta, is_on_ceiling_only())
	essence_component.update()
	dash_component.update()
	movement_component.enabled = _G.player.can_control
	chase_component.enabled = _G.player.can_control
	$HitSFX.pitch_scale = clamp($HitSFX.pitch_scale, 1.0, 1.5)
	velocity = movement_component.vel * Vector3(_G.player.can_control, _G.player.can_control, _G.player.can_control)
	move_and_slide()
	chase_component.update(_G.player.target.get_pos_multiplied(.5 + enemy.random_factor), movement_component, agent)


func query_area_entered(area : Area3D) -> void:
	enemy.handle_query(area, essence_component, knockback_component)

func dashed() -> void:
	$ShootSFX.play()

func dash_query_body_entered(body : Player) -> void:
	knockback_component.knock(_G.player.global_position, 20)
	movement_component.speed *= 0.8
