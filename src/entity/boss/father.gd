extends BossEnemy
class_name BossFather

@onready var movement_component : MovementComponent = $MovementComponent
@onready var enemy : EnemyComponent = $EnemyComponent
@onready var chase_component : ChaseComponent = $ChaseComponent
@onready var shoot_component : ShootComponent = $ShootComponent
@onready var knockback_component : KnockbackComponent = $KnockbackComponent
@onready var agent : NavigationAgent3D = $GroundEnemyNav
@onready var light : OmniLight3D = $OmniLight3D
@onready var hit_sfx : AudioStreamPlayer3D = $HitSFX
@onready var shoot_sfx : AudioStreamPlayer3D = $ShootSFX

@onready var query : Area3D = $Query

var y_boundary : float

# father only
@onready var crown: Sprite3D = $Crown
const DISTANCE_TO_CLOSE : float = 10.0

const KNOCK_DEFAULT : float = 0.75
const KNOCK_STOMP : float = 0.25

const DEFENSE_DEFAULT : float = 12.0
const DEFENSE_STOMP : float = 16.0

var close_to_player : bool = false

func _ready() -> void:
	enemy.setup(essence_component, chase_component, query, knockback_component, movement_component)
	shoot_component.config.damage = enemy.damage
	boss_setup()

func _physics_process(delta : float) -> void:
	if not enemy.update(delta, movement_component): return
	
	shoot_component.enabled = current_phase == "shoot"
	
	close_to_player = global_position.distance_to(_G.player.global_position) < DISTANCE_TO_CLOSE
	healthbar.update($Sprite3D.modulate)
	
	$Label.text = str(velocity) + "\nphase:" + current_phase
	
	match current_phase:
		"shoot":
			if chase_component.attacking and _G.player.can_control:
				enemy.shoot_to_player(shoot_component, 1.8, 0.5)
			chase_component.attack_distance = 30.0
			#chase_component.enabled = true
			essence_component.defense = DEFENSE_DEFAULT
			knockback_component.multiplier = KNOCK_DEFAULT
		_:
			#chase_component.enabled = false
			movement_component.jump()
			#movement_component.direction = get_random_player_position(5.0)
			essence_component.defense = DEFENSE_STOMP
			knockback_component.multiplier = KNOCK_STOMP
		#_:
			#chase_component.enabled = false
			#essence_component.defense = DEFENSE_STOMP
			#knockback_component.multiplier = KNOCK_STOMP
			
	chase_component.update(_G.player.target.get_pos_multiplied(2.0), movement_component, agent)
	
func _exit_tree() -> void:
	enemy.cleanup()
	
func movement_just_landed() -> void:
	if current_phase != "shoot":
		_G.game.create_exposilon_ring(global_position + (Vector3.UP * 0.5), 20.0, 0.75)
		var dir : Vector3 = global_position.direction_to(get_random_player_position(15.0)) * 25.0
		movement_component.vel.x += dir.x
		movement_component.vel.z += dir.z

func get_random_player_position(radius : float = 1.0) -> Vector3:
	var position : Vector3 = _G.player.global_position + Vector3(randf_range(-radius, radius), 1.0, randf_range(-radius, radius))
	return position
