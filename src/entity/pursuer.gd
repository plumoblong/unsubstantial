extends CharacterBody3D
class_name Pursuer

@onready var movement_component : MovementComponent = get_node("MovementComponent")
@onready var knock_component : KnockbackComponent = get_node("KnockbackComponent")

func _ready() -> void:
	_G.game.pursuer_spawned = true 
	$Ambience.pitch_scale = randf_range(0.75, 1.25)
	movement_component.max_speed = _G.player.movement_component.walk_speed - 5.0

func _physics_process(delta : float) -> void:
	$Area3D.damage = int(_G.player.stats.esc_max / 2.0)
	movement_component.update(delta)
	movement_component.direction = position.direction_to(_G.player.global_position + Vector3(0.0, 1.1, 0.0))
	velocity = movement_component.vel
	if _G.player.can_control: move_and_slide()
	
	if _G.game.ending_level:
		queue_free.call_deferred()
	

func area_3d_area_entered(area: Area3D) -> void:
	if area is Bullet:
		area.despawn()
		knock_component.knock(_G.player.global_position, 24.0)
		stun()
		
func stun() -> void:
	movement_component.speed = 10.0
	movement_component.air_friction = 0.01
	await get_tree().create_timer(1.5).timeout
	movement_component.max_speed =  _G.player.movement_component.walk_speed - 5.0
	movement_component.air_friction = 0.1


func area_3d_body_entered(_body : Player) -> void:
	knock_component.knock(_G.player.global_position, 32.0)
	stun()
