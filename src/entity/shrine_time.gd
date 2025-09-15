extends Interaction

@export var gate : Gate

#@export var init_cost : int = 50
#var current_cost : int = 100
#
#var times_played : int = 0
#
#@export var pool : Dictionary = {
	#"nothing" : 25,
	#"xp" : 25,
	#"hp" : 25,
	#"speed" : 15,
	#"damage" : 10
#}

#var close_chance : int = 0
var closed : bool = false
signal used

func on_interacted() -> void:
	_G.player.stats.esc_max /= 2
	used.emit()
	$Sprite3D.frame = 1
	gate.done = true
	closed = true
	_G.game.chat.add_message("An entry appeared...", Color.YELLOW)
	
func _physics_process(_delta: float) -> void:
	enabled = not closed
	if can_interact and not closed:
		_G.player.interact_tooltip = "Set the time."
		_G.player.interact_description = "Configure the clock?"

#@warning_ignore("unreachable_pattern")
#func payout(result : String) -> void:
	#if closed: return
	#if result == "xp":
		#_G.player.level_component.gain_xp(int(_G.player.level_component.max_xp / 10.0))
		#_G.player.alert("You've became wiser...")
		#close_chance += 2
	#elif result == "hp":
		#_G.player.stats.esc_max += 100
		#_G.player.essence_component.gain(100)
		#_G.player.alert("You've been blessed with essence...")
		#close_chance += 5
	#elif result == "speed":
		#_G.player.stats.speed += 1.5
		#_G.player.alert("You've been blessed with speed...")
		#close_chance += 5
	#elif result == "damage":
		#_G.player.stats.damage += 10
		#_G.player.alert("You've been blessed with power...")
		#close_chance += 10
	#else:
		#_G.player.alert("You aren't worthy...")
		#close_chance += 1
	#print(result)
	#var c : int = randi_range(0, 99)
	#if c < close_chance:
		#closed = true
