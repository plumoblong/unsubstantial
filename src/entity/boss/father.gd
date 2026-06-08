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

# father only
@onready var spawner1 : EnemySpawner = $EnemySpawner
@onready var spawner2 : EnemySpawner = $EnemySpawner2
@onready var crown: Sprite3D = $Crown
const DISTANCE_TO_CLOSE : float = 10.0

const KNOCK_DEFAULT : float = 0.5
const KNOCK_STOMP : float = 0.0

const DEFENSE_DEFAULT : float = 12.0
const DEFENSE_STOMP : float = 10.0

const JUMP_DISTANCE : float = 32.0

const ENEMY_SPAWN_POSITIONS : Array[Vector3] = [
	Vector3(-4.0, 1.0, -4.0),
	Vector3(4.0, 1.0, -4.0),
]

const ENEMY_SPAWN_POSITION_ALT : Array[Vector3] = [
	Vector3(-4.0, 1.0, 4.0),
	Vector3(4.0, 1.0, 4.0),
]

const ENEMY_SPAWNLIST_LUT : Array[String] = [
	"enemy_small;enemy;",
	"enemy_small;enemy_melee;",
	"enemy_melee;enemy;",
	"enemy_melee;enemy;",
	"enemy;enemy_triple;",
	"enemy_melee;guardian;",
	"guardian;enemy_triple;",
	"guardian;enemy_triple;"
]

var close_to_player : bool = false
var _can_spawn : bool = true
var _can_shoot : bool = false

var _center : Vector3

var spawner_difficulty : int = 0

func _ready() -> void:
	enemy.setup()
	shoot_component.config.damage = enemy.damage
	spawner1._func_godot_build_complete()
	spawner2._func_godot_build_complete()
	boss_setup()

func _physics_process(delta : float) -> void:
	if not enemy.update(delta, movement_component): return
	
	shoot_component.enabled = current_phase == "shoot"
	
	close_to_player = global_position.distance_to(_G.player.global_position) < DISTANCE_TO_CLOSE
	healthbar.update($Sprite3D.modulate)
	
	$Label.visible = _T.debug_flags[3]
	$Label.text = str(velocity) + "\nphase: " + current_phase + "\nfirerate: " + str(shoot_component.config.fire_rate) + "\nflags: shoot: " + str(_can_shoot) + " spawn: " + str(_can_spawn)
	
	phase_time_mult = clamp(essence_component.ratio, 0.4, 1.0)
	shoot_component.config.fire_rate = 0.8 + (essence_component.ratio * 0.8)
	
	spawner_difficulty = int(round(1.0 - essence_component.ratio) * 4.0)
	
	match current_phase:
		"shoot":
			if chase_component.attacking and _G.player.can_control:
				if _can_shoot: enemy.shoot_to_player(shoot_component, 1.8, 0.5)
			chase_component.attack_distance = 30.0
			chase_component.enabled = true
			essence_component.defense = DEFENSE_DEFAULT
			knockback_component.multiplier = KNOCK_DEFAULT
		"stomp":
			chase_component.enabled = true
			movement_component.jump()
			#movement_component.direction = get_random_player_position(5.0)
			essence_component.defense = DEFENSE_STOMP
			knockback_component.multiplier = KNOCK_STOMP
		"spawn":
			chase_component.enabled = false
			essence_component.defense = DEFENSE_DEFAULT
			knockback_component.multiplier = KNOCK_DEFAULT
			
	chase_component.update(_G.player.target.get_pos_multiplied(2.0), movement_component, agent)
	
func _exit_tree() -> void:
	enemy.cleanup()
	
func movement_just_landed() -> void:
	if current_phase == "stomp":
		_G.game.create_exposilon_ring(global_position + (Vector3.UP * 0.5), 16.0, 1.0)
		var distance : float = JUMP_DISTANCE * 0.2 if close_to_player else JUMP_DISTANCE
		var dir : Vector3 = global_position.direction_to(chase_component.get_random_position(chase_component.start_position, 10.0)) * distance
		movement_component.vel.x += dir.x
		movement_component.vel.z += dir.z

func on_phase_changed(current: String) -> void:
	if current == "spawn":
		_can_shoot = false
		var current_spawn = clampi((spawner_difficulty * 2), 0, 6)
		spawner1.func_godot_properties["enemy"] = ENEMY_SPAWNLIST_LUT[current_spawn]
		spawner1.func_godot_properties["enemy"] = ENEMY_SPAWNLIST_LUT[current_spawn + 1]
		spawner1.position = ENEMY_SPAWN_POSITIONS.pick_random()
		spawner2.position = ENEMY_SPAWN_POSITION_ALT.pick_random()
		if not _can_spawn: 
			return
		spawner1.do_spawn()
		spawner2.do_spawn()
		_T.say("hi")
		_can_spawn = false
	elif current == "shoot":
		_can_spawn = true
		if not _can_shoot: 
			await get_tree().create_timer(0.5).timeout
			_can_shoot = true
	else:
		_can_spawn = true
		_can_shoot = false
