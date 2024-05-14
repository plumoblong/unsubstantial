extends Area3D
class_name Checkpoint

var active : bool = false
@onready var activation_sfx := $ActivateSFX
@onready var ambience_sfx := $AmbienceSFX

func _ready():
	pass
	
func _process(_delta):
	$Sprite.play(str(active))
	$OmniLight3D.light_energy = 0.5 + (float(active) * 0.6)

func body_entered(body):
	if body is LocalPlayer:
		activate(body)
		
func area_entered(area):
	if area is Bullet:
		activate(area.creator)
		
func activate(body):
	if not active:
		active = true
		activation_sfx.play()
		ambience_sfx.play()
		body.start_position = global_position


