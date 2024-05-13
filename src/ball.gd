extends CSGSphere3D

var freq : float = 3.0
var amp : float = 2.0

func _ready():
	freq = randf_range(1.50, 4.00)
	amp = randf_range(1.50, 3.00)

func _process(delta):
	global_position.y += global.sine_movement(amp, freq) * delta
