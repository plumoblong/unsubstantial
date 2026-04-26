extends CharacterBody3D
class_name EnemySmall

@onready var movement_component : MovementComponent = $MovementComponent
@onready var enemy : EnemyComponent = $EnemyComponent
@onready var chase_component : ChaseComponent = $ChaseComponent
@onready var essence_component : EssenceComponent = $EssenceComponent
@onready var knockback_component : KnockbackComponent = $KnockbackComponent
@onready var agent : NavigationAgent3D = $GroundEnemyNav
@onready var query : Area3D = $Query
@onready var light : OmniLight3D = $OmniLight3D
@onready var hit_sfx : AudioStreamPlayer3D = $HitSFX
@onready var shoot_sfx : AudioStreamPlayer3D = $ShootSFX

var player_can_control : bool
var y_boundary : float

func _ready() -> void:
	enemy.setup(essence_component, chase_component)
	knockback_component.knock(Vector3(randf_range(-1.0, 1.0), 0.5, randf_range(-1.0, 1.0)), 0.4)
	query.damage = enemy.damage
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
	movement_component.can_jump = is_on_floor()
	chase_component.enabled = player_can_control
	hit_sfx.pitch_scale = clamp(hit_sfx.pitch_scale, 1.0, 1.5)
	chase_component.update(_G.player.global_position, movement_component, agent)
	
	velocity = movement_component.vel * float(player_can_control)
	
	if chase_component.attacking and is_on_floor():
		movement_component.jump()
	
	move_and_slide()
	

func query_area_entered(area : Area3D) -> void:
	enemy.handle_query(area, essence_component, knockback_component)
