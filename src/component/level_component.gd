extends Component
class_name LevelComponent

@export var level : int = 1
@export var xp : int = 0
@export var max_xp : int = 10
@export var lock_after_level_up : bool = false
@export var xp_multiplier : float = 1.0

var locked : bool = false
var ratio : float = 0.0

signal leveled_up
signal xp_gained

func update() -> void:
	if not enabled: return
	#max_xp = int(float(level) * 80.0 - (float(level) * 16.0))
	max_xp = int(sqrt((5.0 * float(level))) * (20.0 + float(level) * 1.5))
	xp = clampi(xp, 0, max_xp)
	ratio = float(xp) / float(max_xp)
	if xp >= max_xp:
		level_up()
		
func level_up() -> void:
	level += 1
	xp = 0
	if lock_after_level_up:
		locked = true
	leveled_up.emit()

func gain_xp(amount : int = 1) -> void:
	if locked: return
	xp += int(float(amount) * xp_multiplier)
	xp_gained.emit()
