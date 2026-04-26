extends Resource
class_name StatShard

@export var stat_name  : String  = ""
@export var image      : Texture

@export_category("Pool Info")
@export var weight     : float   = 1.0
@export var shop_cost  : int     = 25
## shop_cost * rarity
@export var shop_rarity_price_multipliers : Array[float] = [
	1.0, 2.0, 3.0, 6.0, 10.0
]
## Modulate → base weight. Rarity filtering and luck scaling are handled
## by ShardPickerComponent, not here.

@export var common_modulates : Array[Modulate]
@export var uncommon_modulates : Array[Modulate]
@export var rare_modulates : Array[Modulate]
@export var legendary_modulates : Array[Modulate]
@export var mythical_modulates : Array[Modulate]

func get_random_modulate(rarity : Modulate.RARITY) -> Modulate:
	var lut : Array[Array] = [
		common_modulates, uncommon_modulates, rare_modulates, legendary_modulates, mythical_modulates
	]
	
	var m_array : Array[Modulate] = lut[rarity]
	var m : Modulate = m_array.pick_random()
	
	return m
	
func get_price(rarity : Modulate.RARITY) -> float:
	return shop_cost * shop_rarity_price_multipliers[Modulate.RARITY]
