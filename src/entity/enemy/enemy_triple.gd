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
@onready var query : Area3D = $Query

func _ready() -> void:
	enemy.setup()
	knockback_component.knock(Vector3(randf_range(-1.0, 1.0), 0.5, randf_range(-1.0, 1.0)), 2.0)
	#shoot_component.config.fire_rate = randf_range(1.0, 1.25)
	#shoot_component.config.size_mult = randf_range(0.95, 1.2)
	shoot_component.config.damage = enemy.damage

func _exit_tree() -> void:
	enemy.cleanup()

func _physics_process(delta : float) -> void:
	if not enemy.update(delta, movement_component): return
	
	if chase_component.attacking and _G.player.can_control:
		var _target_pos = _G.player.target.get_pos_multiplied(0.4)
		shoot_component.shoot(global_position.direction_to(_target_pos))
	
	chase_component.update(_G.player.target.get_pos_multiplied(0.6 + enemy.random_factor), movement_component, agent)
