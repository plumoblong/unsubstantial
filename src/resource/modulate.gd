extends Resource
class_name Modulate

enum OP {
	ADD,
	SUBTRACT,
	MULTIPLY,
	SET,
}

enum RARITY {
	COMMON    = 0,
	UNCOMMON  = 1,
	EPIC      = 2,
	LEGENDARY = 3,
	MYTHIC    = 4,
}

## Difficulty multipliers applied when this modulate is appended.
const RARITY_DIFFICULTY : Dictionary = {
	RARITY.COMMON    : 1.005,
	RARITY.UNCOMMON  : 1.01,
	RARITY.EPIC      : 1.025,
	RARITY.LEGENDARY : 1.05,
	RARITY.MYTHIC    : 1.1,
}

## Display name shown in the UI (e.g. "Damage", "Fire Rate").
@export var stat_name     : String = "Damage"
## The actual property name on ItemStats or its bullet resource.
@export var statistic     : String = "damage"
## If true, reads and writes from stats_component.bullet instead of stats_component.
@export var bullet_set    : bool   = false

@export var operator      : OP
@export var value         : float  = 1.0
@export var rarity        : RARITY = RARITY.COMMON
## When true, the description reads "Get <stat_name>" instead of showing a number.
@export var dont_number_stat : bool = false

var pre_append_value
var post_append_value
var stat_appended : bool = false

func _get_target() -> Object:
	return _G.player.stats.bullet if bullet_set else _G.player.stats

func append() -> void:
	var target : Object = _get_target()
	
	pre_append_value = target.get(statistic)
	post_append_value = _get_modified_value(target.get(statistic))
	target.set(statistic, post_append_value)
	
	_G.game.difficulty_bonus *= RARITY_DIFFICULTY[rarity]
	stat_appended = true

func get_description() -> String:
	var result : String = "hej"
	if dont_number_stat or operator == OP.SET:
		result = "Get " + stat_name

	match operator:
		OP.ADD:
			var display := str(value) if value < 1.0 else str(int(value))
			result = "+ %s %s" % [display, stat_name]
		OP.SUBTRACT:
			result = "- %d %s" % [int(value), stat_name]
		OP.MULTIPLY:
			if value > 1.0:
				result = "+ %d%% %s" % [roundi((value - 1.0) * 100.0), stat_name]
			else:
				result = "- %d%% %s" % [roundi(value * 100.0), stat_name]
				
	return result

func _get_modified_value(property: Variant) -> Variant:
	match operator:
		OP.ADD:      return property + value
		OP.SUBTRACT: return property - value
		OP.MULTIPLY: return property * value
		OP.SET:      return value
	return property
