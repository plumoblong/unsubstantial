extends Resource
class_name Modulate

enum OP {
	ADD,
	SUBTRACT,
	MULTIPLY,
	SET,
}

enum RARITY {
	COMMON,
	UNCOMMON,
	EPIC,
	LEGENDARY,
	MYTHIC
}
## Look to the ItemStats class to get the variable names (i know its a bad workaround but im too lazy)
@export var statistic : String = "damage"
@export var bullet_set : bool = false

@export var operator : OP
@export var value : float = 1.0
@export var rarity : RARITY = RARITY.COMMON
## Replaces the "+ value" with "Get" when returning description. 
## Meant to be used for (for example) "Get Exploding Bullets", "Get Additional Bullet", etc.
@export var dont_number_stat : bool = false

var stat_last_value
var stat_appended : bool = false

func append(stats_component : ItemStats) -> void:
	stat_last_value = stats_component.get(statistic)
	if bullet_set:
		match operator:
			OP.ADD:
				stats_component.bullet.set(statistic, stats_component.bullet.get(statistic) + value)
			OP.SUBTRACT:
				stats_component.bullet.set(statistic, stats_component.bullet.get(statistic) - value)
			OP.MULTIPLY:
				stats_component.bullet.set(statistic, stats_component.bullet.get(statistic) * value)
			OP.SET:
				stats_component.bullet.set(statistic, value)
	else:
		match operator:
			OP.ADD:
				stats_component.set(statistic, stats_component.get(statistic) + value)
			OP.SUBTRACT:
				stats_component.set(statistic, stats_component.get(statistic) - value)
			OP.MULTIPLY:
				stats_component.set(statistic, stats_component.get(statistic) * value)
			OP.SET:
				stats_component.set(statistic, value)
	match rarity:
		RARITY.COMMON:
			_G.game.difficulty_bonus *= 1.01
		RARITY.UNCOMMON:
			_G.game.difficulty_bonus *= 1.025
		RARITY.EPIC:
			_G.game.difficulty_bonus *= 1.05
		RARITY.LEGENDARY:
			_G.game.difficulty_bonus *= 1.075
		RARITY.MYTHIC:
			_G.game.difficulty_bonus *= 1.1
	stat_appended = true

func get_description(stat_name : String = " Statistic") -> String:
	var result : String = ""
	if dont_number_stat: return "Get " + stat_name
	match operator:
		OP.ADD:
			if value < 1.0:
				result = "+ " + str(value) + " " + stat_name
			else:
				result = "+ " + str(int(value)) + " " + stat_name
		OP.SUBTRACT:
			result = "- " + str(int(value)) + " " + stat_name
		OP.MULTIPLY:
			if value > 1.0:
				result = "+ " + str(roundi((value - 1)  * 100)) + "% " + stat_name
			else:
				result = "- " + str(roundi(value * 100)) + "% " + stat_name
	return result
