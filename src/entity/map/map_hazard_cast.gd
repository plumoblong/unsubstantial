extends RayCast3D
class_name MapHazardCast

@export var esc : EssenceComponent
var damages : bool = true

var last_damage_got : int = 50
var die_reason : String = ""

func _physics_process(_delta: float) -> void:
	if not is_colliding(): return
	var collider : Node3D = get_collider()
	if collider is SolidHazard:
		if Engine.get_physics_frames() % collider.func_godot_properties["cooldown"] == 0:
			esc.fracture(collider.func_godot_properties["damage"])
			if get_parent() is Player:
				_G.current_run.die_reason = collider.func_godot_properties["die_reason"]
