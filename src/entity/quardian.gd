extends CharacterBody3D
class_name EnemyGuard

@onready var movement_component : MovementComponent = $MovementComponent
@onready var chase_component : ChaseComponent = $ChaseComponent
@onready var essence_component : EssenceComponent = $EssenceComponent
@onready var shoot_component : ShootComponent = $ShootComponent
@onready var knockback_component : KnockbackComponent = $KnockbackComponent
@onready var agent : NavigationAgent3D = $GroundEnemyNav
@onready var enemy : EnemyComponent = $EnemyComponent
@onready var light : OmniLight3D = $OmniLight3D
@onready var hit_sfx : AudioStreamPlayer3D = $HitSFX
@onready var shoot_sfx : AudioStreamPlayer3D = $ShootSFX

var y_boundary : float

func _ready() -> void:
	enemy.setup(essence_component, chase_component)
	knockback_component.knock(Vector3(randf_range(-1.0, 1.0), 0.5, randf_range(-1.0, 1.0)), 2.0)
	shoot_component.config.fire_rate = randf_range(1.15, 1.3)
	shoot_component.config.damage = enemy.damage
	light.light_color = enemy.color

func essence_component_died(combo : bool) -> void:
	enemy.handle_death()

func essence_component_fractured(amount : int, i_time : float) -> void:
	enemy.handle_fracture(amount, i_time, movement_component)

func _physics_process(delta : float) -> void:
	
	if global_position.y <= _G.game.chapter.current.y_boundary:
		essence_component.die()
	
	# Update components
	movement_component.update(delta, is_on_ceiling_only())
	essence_component.update()
	movement_component.enabled = _G.player.can_control
	chase_component.enabled = _G.player.can_control
	hit_sfx.pitch_scale = clamp(hit_sfx.pitch_scale, 1.0, 1.5)
	chase_component.update(_G.player.target.get_pos_multiplied(2.3), movement_component, agent)
	if chase_component.attacking and _G.player.can_control:
		enemy.shoot_to_player(shoot_component, 0.8, 0.9)
	velocity = movement_component.vel * float(_G.player.can_control)
	move_and_slide()
	

func query_area_entered(area : Area3D) -> void:
	enemy.handle_query(area, essence_component, knockback_component)

func shoot_component_shooted() -> void:
	shoot_sfx.play()
