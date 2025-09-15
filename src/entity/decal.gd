extends Decal

var images : Array[String] = [
	"res://images/splatter0.png",
	"res://images/splatter1.png",
	"res://images/splatter2.png"
]
var perm : bool = true
var can_fade : bool = false
var life_time : float = 10.0
var damage : int = 0
var color : Color = Color.WHITE

func _ready() -> void:
	_G.game.level_changing.connect(delete)
	texture_emission = load(images.pick_random())
	modulate = color
	size = Vector3(randf_range(2.0, 4.0), randf_range(2.0, 4.0), randf_range(2.0, 4.0))
	$Hazard/Area3D.shape.size = size
	
	rotation_degrees.y = randf_range(1.0, 4.0) * 90.0

func _process(delta : float) -> void:
	$Hazard.damage = damage
	if not can_fade:
		emission_energy += delta * life_time
		if emission_energy >= 1:
			can_fade = true
	else:
		emission_energy -= delta / 5.0
		if emission_energy <= 0:
			delete()
func delete() -> void:
	queue_free()
