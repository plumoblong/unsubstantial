extends CharacterBody3D
class_name EnemySmall

@onready var movement_component : MovementComponent = $MovementComponent
@onready var enemy : EnemyComponent = $EnemyComponent
@onready var chase_component : ChaseComponent = $ChaseComponent
@onready var essence_component : EssenceComponent = $EssenceComponent
@onready var knockback_component : KnockbackComponent = $KnockbackComponent
@onready var agent : NavigationAgent3D = $GroundEnemyNav
@onready var query : Area3D = $Query
@onready var query_hitbox : CollisionShape3D = $Query/Hitbox
@onready var light : OmniLight3D = $OmniLight3D
@onready var hit_sfx : AudioStreamPlayer3D = $HitSFX
@onready var shoot_sfx : AudioStreamPlayer3D = $ShootSFX

func _ready() -> void:
	enemy.setup()
	knockback_component.knock(Vector3(randf_range(-1.0, 1.0), 0.5, randf_range(-1.0, 1.0)), 0.4)
	query.damage = enemy.damage
	movement_component.jump_speed = randf_range(8.0, 10.0)

func _exit_tree() -> void:
	enemy.cleanup()

func _physics_process(delta : float) -> void:
	if not enemy.update(delta, movement_component): return
	
	if chase_component.attacking and is_on_floor():
		movement_component.jump()
	#query_hitbox.disabled = not is_on_floor()
	chase_component.update(_G.player.target.get_pos_multiplied(2.5), movement_component, agent)
