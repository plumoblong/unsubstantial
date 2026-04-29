extends Resource
class_name StatShard

@export var stat_name  : String  = ""
@export var image      : Texture

@export_category("Pool Info")
@export var weight     : float   = 1.0
@export var shop_cost  : int     = 25
## shop_cost * rarity when shard_collectable isnt free and has no price override
@export var shop_rarity_price_multipliers : Array[float] = [
	1.0, 2.0, 4.0, 6.0, 8.0
]

@export_group("Stat Exclusion")
@export var exclusion_enabled  : bool  = false
@export var exclusion_stat     : String = ""        # e.g. "health", "speed"
@export var exclusion_min      : float = 0.0       # exclude if stat < this
@export var exclusion_max      : float = INF        # exclude if stat > this

## Modulate → base weight. Rarity filtering and luck scaling are handled
## by ShardPickerComponent, not here.
@export_group("Modulate Pools")
@export var common_modulates : Array[Modulate]
@export var uncommon_modulates : Array[Modulate]
@export var rare_modulates : Array[Modulate]
@export var legendary_modulates : Array[Modulate]
@export var mythical_modulates : Array[Modulate]

func is_excluded(stat_owner: Object) -> bool:
	if not exclusion_enabled or exclusion_stat.is_empty():
		return false
	if not stat_owner.get(exclusion_stat) != null:
		_T.say("StatShard: exclusion_stat '%s' not found on %s" % [exclusion_stat, stat_owner])
		return false
	var value: float = float(stat_owner.get(exclusion_stat))
	return value < exclusion_min or value > exclusion_max

func get_random_modulate(rarity : Modulate.RARITY) -> Modulate:
	var lut : Array[Array] = [
		common_modulates, uncommon_modulates, rare_modulates, legendary_modulates, mythical_modulates
	]
	
	var m_array : Array[Modulate] = lut[rarity]
	var m : Modulate = m_array.pick_random()
	
	return m
	
func get_price(rarity : Modulate.RARITY) -> float:
	return shop_cost * shop_rarity_price_multipliers[rarity]
