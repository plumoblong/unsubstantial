extends Component
class_name EssenceComponent

@export var start_essence : int = 500
@export var max_essence : int = 750
@export var die_threshold : int = 10
@export var set_max_essence_on_ready : bool = true

var essence : int
var heal_multiplier : float = 1.0
var alive : bool = true
var times_fractured : int = 0
var defense : float = 1.0
var ratio : float = 1.0

signal gained(amount : int)
signal fractured(amount : int, i_time : float)
signal died(combo : bool)

var damage_mult : float = 1.0

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
	if essence <= die_threshold:
		die()
		alive = false
	essence = clampi(essence, 0, max_essence)
	ratio = float(essence) / float(max_essence)

func fracture(amount : int, combo : bool = false, i_time : float = 0.2) -> void:
	if get_parent() is Player:
		if not enabled or get_parent().god_mode: return
	if alive:
		if essence > amount:
			var a : int = int(float(amount) * defense * damage_mult)
			essence -= a
			times_fractured += 1
			fractured.emit(a, combo)
			add_iframes(i_time)
		else:
			die()

func gain(amount : int) -> void:
	if not enabled: return
	if essence >= max_essence: return
	essence += int(float(amount) * heal_multiplier)
	gained.emit(amount * heal_multiplier)
	return

func die() -> void:
	if alive:
		died.emit(false)
		#_T.say(get_parent().name +  " died :(")
		alive = false
