extends Component
class_name EssenceComponent

@export var start_essence : int = 300
@export var max_essence : int = 300
@export var die_threshold : int = 10
@export var set_max_essence_on_ready : bool = false

var essence : int
var heal_multiplier : float = 1.0
var alive : bool = true
var times_fractured : int = 0
var defense : float = 10.0
var ratio : float = 1.0
var immortal : bool = false

signal gained(amount : int)
signal fractured(amount : int, i_time : float, combo : bool)
signal died(combo : bool)

var damage_mult : float = 1.0

var last_frame_max_essence : int = 300

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if set_max_essence_on_ready:
		essence = start_essence
	return

func add_iframes(time : float = 0.2):
	damage_mult = 0.0
	_G.tween(self, "damage_mult", 1.0, time)
	return

func update() -> void:
	if not enabled: return
	if max_essence != last_frame_max_essence:
		essence = max_essence
	if essence <= die_threshold:
		die()
		
	essence = clampi(essence, 0, max_essence)
	ratio = float(essence) / float(max_essence)
	last_frame_max_essence = max_essence

func fracture(amount : int, combo : bool = false, i_time : float = 0.2) -> void:
	if get_parent() is Player:
		if not enabled or get_parent().god_mode: return
	if alive:
		var a : int = int(float(amount) * 10.0/defense * damage_mult)
		if essence > amount:
			essence -= a
			times_fractured += 1
			add_iframes(i_time)
		else:
			die()
		fractured.emit(a, i_time, combo)

func gain(amount : int) -> void:
	if not enabled: return
	if ratio >= 1.0: return
	essence += int(float(amount) * heal_multiplier)
	gained.emit(amount * heal_multiplier)
	return

func die() -> void:
	if alive:
		if not immortal:
			died.emit(false)
			#_T.say(get_parent().name +  " died :(")
			alive = false
	else:
		essence = 1
