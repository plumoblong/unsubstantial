extends CharacterBody3D
class_name EnemyHuman

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
	knockback_component.knock(Vector3(randf_range(-1.0, 1.0), 0.0, randf_range(-1.0, 1.0)), 1.0)
	shoot_component.config.damage = enemy.damage
	
func _exit_tree() -> void:
	enemy.cleanup()

func _physics_process(delta : float) -> void:
	if not enemy.update(delta, movement_component): return

	if chase_component.attacking and _G.player.can_control:
		enemy.shoot_to_player(shoot_component, 1.5, 0.5)
	chase_component.update(_G.player.target.get_pos_multiplied(0.3 + enemy.random_factor), movement_component, agent)

func shoot_component_shooted() -> void:
	shoot_sfx.play()
