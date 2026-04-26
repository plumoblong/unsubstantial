extends CharacterBody3D
class_name EnemyTriple

@onready var movement_component : MovementComponent = $MovementComponent
@onready var enemy : EnemyComponent = $EnemyComponent
@onready var chase_component : ChaseComponent = $ChaseComponent
@onready var essence_component : EssenceComponent = $EssenceComponent
@onready var shoot_component : ShootComponent = $ShootComponent
@onready var knockback_component : KnockbackComponent = $KnockbackComponent
@onready var agent : NavigationAgent3D = $GroundEnemyNav
@onready var light : OmniLight3D = $OmniLight3D
@onready var hit_sfx : AudioStreamPlayer3D = $HitSFX
@onready var shoot_sfx : AudioStreamPlayer3D = $ShootSFX

var player_can_control : bool
var target_pos : Vector3
var y_boundary : float

func _ready() -> void:
	enemy.setup(essence_component, chase_component)
	knockback_component.knock(Vector3(randf_range(-1.0, 1.0), 0.5, randf_range(-1.0, 1.0)), 2.0)
	shoot_component.config.fire_rate = randf_range(1.0, 1.25)
	shoot_component.config.size_mult = randf_range(0.95, 1.2)
	shoot_component.config.damage = enemy.damage
	light.light_color = enemy.color

func essence_component_died(combo : bool) -> void:
	enemy.handle_death()

func essence_component_fractured(amount : int, i_time : float) -> void:
	enemy.handle_fracture(amount, i_time, movement_component)

func _physics_process(delta : float) -> void:
	
	# Cache frequently used values
	player_can_control = _G.player.can_control
	y_boundary = _G.game.chapter.current.y_boundary
	
	if global_position.y <= y_boundary:
		essence_component.die()
	
	# Update components
	movement_component.update(delta, is_on_ceiling_only())
	essence_component.update()
	movement_component.enabled = player_can_control
	chase_component.enabled = player_can_control
	hit_sfx.pitch_scale = clamp(hit_sfx.pitch_scale, 0.75, 1.25)
	
	velocity = movement_component.vel * float(player_can_control)
	move_and_slide()
	
	if chase_component.attacking and player_can_control:
		target_pos = _G.player.target.get_pos_multiplied(0.4)
		shoot_component.shoot(global_position.direction_to(target_pos), global_position + Vector3(0.0, 0.2, 0.0))
	
	chase_component.update(_G.player.target.get_pos_multiplied(0.6 + enemy.random_factor), movement_component, agent)

func query_area_entered(area : Area3D) -> void:
	enemy.handle_query(area, essence_component, knockback_component)

func shoot_component_shooted() -> void:
	shoot_sfx.play()
