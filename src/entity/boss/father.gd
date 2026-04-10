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
@onready var crown: Sprite3D = $Crown

var y_boundary : float

# father only
const DISTANCE_TO_CLOSE : float = 10.0

var close_to_player : bool = false

func _ready() -> void:
	enemy.setup(essence_component, chase_component)
	shoot_component.config.damage = enemy.damage
	boss_setup()

func _physics_process(delta : float) -> void:
	agent.debug_enabled = _G.debug_mode
	y_boundary = _G.game.chapter.current.y_boundary
	
	if global_position.y <= y_boundary:
		essence_component.die()
	
	movement_component.update(delta, is_on_ceiling_only())
	essence_component.update()
	movement_component.enabled = _G.player.can_control
	chase_component.enabled = _G.player.can_control
	shoot_component.enabled = current_phase == "shoot"
	hit_sfx.pitch_scale = clamp(hit_sfx.pitch_scale, 0.4, 0.9)
	
	close_to_player = global_position.distance_to(_G.player.global_position) < DISTANCE_TO_CLOSE
	healthbar.update($Sprite3D.modulate)
	
	velocity = movement_component.vel * float(_G.player.can_control)
	move_and_slide()
	
	match current_phase:
		"shoot":
			if chase_component.attacking and _G.player.can_control:
				enemy.shoot_to_player(shoot_component, 1.8, 0.5)
			chase_component.attack_distance = 30.0
			chase_component.enabled = true
		_:
			chase_component.enabled = false
			movement_component.jump(movement_component.jump_speed)
		#_:
			#pass
			
	chase_component.update(_G.player.target.get_pos_multiplied(2.0), movement_component, agent)
	

func query_area_entered(area : Area3D) -> void:
	enemy.handle_query(area, essence_component, knockback_component)

func essence_component_died(combo : bool) -> void:
	enemy.handle_death()

func essence_component_fractured(amount : int, i_time : float) -> void:
	enemy.handle_fracture(amount, i_time, movement_component)
