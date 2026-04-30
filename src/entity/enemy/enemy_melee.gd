extends CharacterBody3D
class_name EnemyMelee

@onready var movement_component : MovementComponent = $MovementComponent
@onready var chase_component : ChaseComponent = $ChaseComponent
@onready var essence_component : EssenceComponent = $EssenceComponent
@onready var dash_component : DashComponent = $DashComponent
@onready var knockback_component : KnockbackComponent = $KnockbackComponent
@onready var agent : NavigationAgent3D = $GroundEnemyNav
@onready var enemy : EnemyComponent = $EnemyComponent
@onready var light : OmniLight3D = $OmniLight3D
@onready var hit_sfx : AudioStreamPlayer3D = $HitSFX
@onready var shoot_sfx : AudioStreamPlayer3D = $ShootSFX
@onready var dash_query : Node = $DashQuery
@onready var dash_hitbox : CollisionShape3D = $DashQuery/Hitbox
@onready var query : Area3D = $Query

var _target_pos : Vector3

func _ready() -> void:
	enemy.setup(essence_component, chase_component, query, knockback_component, movement_component)
	knockback_component.knock(Vector3(randf_range(-1.0, 1.0), 0.5, randf_range(-1.0, 1.0)), 1.0)
	dash_query.damage = enemy.damage

func _exit_tree() -> void:
	enemy.cleanup()

func _physics_process(delta : float) -> void:
	if not enemy.update(delta, movement_component): return
	
	_target_pos = _G.player.target.get_pos_multiplied(0.5 + enemy.random_factor)
	chase_component.min_distance = 0.0 if dash_component.dashing else 7.0
	dash_hitbox.disabled = not dash_component.dashing

	if is_on_floor():
		dash_component.allow_dash(true)

	if _G.player.can_control and chase_component.attacking:
		if dash_component.can_dash and not dash_component.dashing:
			dash_component.dash(movement_component, global_position.direction_to(_target_pos))
			shoot_sfx.play()
			
	chase_component.update(_target_pos, movement_component, agent)

func dashed() -> void:
	enemy.pulse(enemy.color, 0.3, 0.3, Color.DIM_GRAY)
	shoot_sfx.play()

func dash_query_body_entered(body : Node3D) -> void:
	if body is not Player: return
	knockback_component.knock(_G.player.global_position, 20.0)
