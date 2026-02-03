extends Component
class_name ItemPoolManager

@export var item_pools : Array[ItemPool]

const FALLBACK_ITEM : StatShard = preload("res://res/shards/attack_speed.tres")

enum Pool {
	default, boss, shop
}

func _ready() -> void:
	for i in item_pools:
		i.initialize_pool()

func pick_an_item(pool : Pool) -> StatShard:
	var chosen_pool = item_pools[pool].final_pool
	var i : StatShard = _G.choose_from_chance(chosen_pool)
	if i != null:
		if i.remove_from_pool:
			for p in item_pools:
				p.final_pool.erase(i)
		return i
	else:
		return FALLBACK_ITEM
