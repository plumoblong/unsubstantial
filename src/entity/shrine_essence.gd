extends Interaction
@export var init_cost : int = 100

var current_cost : int
var times_played : int = 0

@export var pool : Dictionary = {
	"nothing" : 5,
	"xp" : 5,
	"speed" : 3,
	"damage" : 2,
	"hp" : 1,
}

var close_chance : int = 0
var closed : bool = false
var can_use : bool = true


	
func _physics_process(_delta: float) -> void:
	enabled = not closed and can_use
	current_cost = int(float(init_cost + (times_played * 50) * _G.player.stats.defense))
	if can_interact and not closed and can_use:
		_G.player.interact_tooltip = "Shrine of ESSENCE."
		_G.player.interact_description = "Sacrifice " + str(int(current_cost)) + " ESSENCE"
	$CSGCombiner3D/Eye.visible = closed
	
func on_interacted() -> void:
	if not can_use: return
	$CSGCombiner3D/Eye.play("default")
	_G.current_run.die_reason = "You got too greedy."
	_G.player.essence_component.fracture(current_cost)
	var result : String = _G.choose_from_chance(pool)
	payout(result)
	times_played += 1
	if not closed:
		can_use = false
		await get_tree().create_timer(1.0).timeout
		can_use = true
		
@warning_ignore("unreachable_pattern")
func payout(result : String) -> void:
	if closed: return
	if result == "xp":
		_G.player.level_component.gain_xp(int(_G.player.level_component.max_xp / 5.0))
		_G.game.chat.add_message("You got rewarded with experience.", Color.CYAN)
		close_chance += 5
	elif result == "hp":
		_G.player.stats.esc_max += 50
		_G.game.chat.add_message("You got rewarded with essence.", Color.CYAN)
		close_chance += 25
	elif result == "speed":
		_G.player.stats.speed += 1.5
		_G.game.chat.add_message("You got rewarded with speed.", Color.CYAN)
		close_chance += 10
	elif result == "damage":
		_G.player.stats.damage += 10
		_G.game.chat.add_message("You got rewarded with power.", Color.CYAN)
		close_chance += 20
	else:
		_G.game.chat.add_message("You aren't worthy.", Color.ORANGE_RED)
		close_chance += 1
	print(result)
	var c : int = randi_range(0, 99)
	if c < close_chance:
		_G.game.chat.add_message("The shrine has closed.", Color.ORANGE_RED)
		closed = true
