extends BossEnemy
class_name BossFather

@onready var shoot_component : ShootComponent = get_node("ShootComponent")
@onready var essence_component : EssenceComponent = get_node("EssenceComponent")

func _ready() -> void:
	$Body.modulate = Color.from_hsv(randf_range(0.00, 1.00), randf_range(0.5, 1.0), randf_range(0.6, 1.0))
	$OmniLight3D.light_color = $Body.modulate

func _physics_process(delta: float) -> void:
	healthbar_color = $Body.modulate
	if shoot_component.can_shoot:
		shoot_component.shoot(global_position.direction_to(_G.player.global_position))
