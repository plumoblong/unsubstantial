extends CharacterBody3D
class_name EnemyMelee

@onready var movement_component : MovementComponent = $MovementComponent
@onready var chase_component : ChaseComponent = $ChaseComponent
@onready var essence_component : EssenceComponent = $EssenceComponent
@onready var dash_component : DashComponent = $DashComponent
@onready var knockback_component : KnockbackComponent = $KnockbackComponent
@onready var agent : NavigationAgent3D = $NavigationAgent3D
@onready var enemy : EnemyComponent = $EnemyComponent
@onready var bar_3d : Node = $"3DBar"
@onready var light : OmniLight3D = $OmniLight3D
@onready var hit_sfx : AudioStreamPlayer3D = $HitSFX
@onready var shoot_sfx : AudioStreamPlayer3D = $ShootSFX
@onready var dash_query : Node = $DashQuery
@onready var dash_hitbox : CollisionShape3D = $DashQuery/Hitbox

const Y_DEATH_BOUNDARY : float = -20.0

var player_can_control : bool
var target_pos : Vector3

func _ready() -> void:
	enemy.setup(essence_component)
	knockback_component.knock(Vector3(randf_range(-1.0, 1.0), 0.5, randf_range(-1.0, 1.0)), 16.0)
	dash_component.cooldown = 1.5
	dash_query.damage = enemy.damage
	light.light_color = enemy.color

func essence_component_died(combo : bool) -> void:
	enemy.handle_death()

func essence_component_fractured(amount : int, i_time : float) -> void:
	enemy.handle_fracture(amount, i_time, movement_component, light)

func _physics_process(delta : float) -> void:
	agent.debug_enabled = _G.debug_mode
	
	# Cache frequently used values
	player_can_control = _G.player.can_control
	target_pos = _G.player.target.get_pos_multiplied(0.5 + enemy.random_factor)
	
	if global_position.y <= Y_DEATH_BOUNDARY:
		essence_component.die()
	
	# Handle dash
	if player_can_control and dash_component.can_dash and chase_component.attacking:
		dash_component.dash(movement_component, global_position.direction_to(target_pos))
	
	chase_component.update(target_pos, movement_component, agent)
	
	# Update chase min_distance based on dash state
	var can_dash : bool = dash_component.can_dash
	chase_component.min_distance = 0.0 if dash_component.dashing else (5.0 if can_dash else 12.0)
	
	dash_hitbox.disabled = not dash_component.dashing
	bar_3d.from_value = essence_component.ratio
	
	# Update components
	movement_component.on_floor = is_on_floor()
	movement_component.update(delta, is_on_ceiling_only())
	essence_component.update()
	dash_component.update()
	movement_component.enabled = player_can_control
	chase_component.enabled = player_can_control
	hit_sfx.pitch_scale = clamp(hit_sfx.pitch_scale, 1.0, 1.5)
	
	velocity = movement_component.vel * float(player_can_control)
	move_and_slide()

func query_area_entered(area : Area3D) -> void:
	enemy.handle_query(area, essence_component, knockback_component)

func dashed() -> void:
	shoot_sfx.play()

func dash_query_body_entered(body : Player) -> void:
	knockback_component.knock(_G.player.global_position, 20)
	movement_component.speed *= 0.8
