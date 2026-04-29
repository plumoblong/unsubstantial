@icon("res://images/entity/human.png")
extends Component
class_name ShardPickerComponent

#properties for shard icon type stuff, or displaying the raritiess

const RARITY_COLOR : Array[Color] = [
	Color("ffc050ff"), # RARITY.COMMON
	Color("29b6ccff"), # RARITY.UNCOMMON
	Color("c24fc2ff"), # RARITY.EPIC
	Color("b3005fff"), # RARITY.LEGENDARY
	Color("ffffffff")  # RARITY.MYTHIC
]

@export var pools : Array[StatShardPool] = [
	preload("res://res/shardpool/common.tres")   ,  # id: 0
	preload("res://res/shardpool/attribute.tres"),  # id: 1
	preload("res://res/shardpool/shop.tres"),       # id: 2
]

@export var pool_weights : Dictionary[int, int] = {
	0 : 8, #common.tres
	1 : 1  #attribute.tres
}

## full picking pipeline: rarity → shard → modulate.
## zeroes out the chosen shard in the pool so it can't be picked again.
func pick(weighted_pool: Dictionary[StatShard, int], rarity : Modulate.RARITY = Modulate.RARITY.UNCOMMON) -> Array:
	
	var shard   : StatShard       = pick_shard(weighted_pool, rarity)
	var modulate: Modulate        = pick_modulate(shard, rarity)
	
	return [shard.duplicate(), modulate.duplicate()]


## Rolls a rarity tier based on luck-adjusted weights.
func pick_rarity(pool : StatShardPool, luck: int) -> Modulate.RARITY:
	var weights : Dictionary[Modulate.RARITY, float] = get_rarity_weights(pool, luck)
	var total   : float = weights.values().reduce(func(a, b): return a + b, 0.0)
	var roll    : float = randf() * total

	for rarity: Modulate.RARITY in weights:
		roll -= weights[rarity]
		if roll <= 0.0:
			return rarity

	return Modulate.RARITY.COMMON


## Picks a shard from the pool that matches the given rarity.
## Falls back to any available shard if none match.
## Zeroes out the chosen shard so it won't be picked again.
func pick_shard(weighted_pool: Dictionary[StatShard, int], rarity: Modulate.RARITY, stat_owner: Object = null) -> StatShard:
	var eligible_pool : Dictionary[StatShard, int] = {}

	for shard: StatShard in weighted_pool:
		if weighted_pool[shard] > 0 and _shard_has_rarity(shard, rarity):
			if stat_owner == null or not shard.is_excluded():
				eligible_pool[shard] = weighted_pool[shard]
 
	if eligible_pool.is_empty():
		_T.say(
			"%s: no shards available for rarity %d, falling back to any shard." % [name, rarity],
			Color.ORANGE, true
		)
		for shard: StatShard in weighted_pool:
			if weighted_pool[shard] > 0:
				eligible_pool[shard] = weighted_pool[shard]
 
	if eligible_pool.is_empty():
		_T.say("%s: pool is entirely empty, cannot pick a shard." % name, Color.RED, true)
		return null
 
	var chosen : StatShard = _G.choose_from_chance(eligible_pool)
	weighted_pool[chosen] = 0
	return chosen


## Picks a modulate from the shard's own modulate table.
func pick_modulate(shard : StatShard, rarity : Modulate.RARITY) -> Modulate:
	var mod : Modulate = shard.get_random_modulate(rarity)
	_T.say(name + ": Picked Modulate from " + str(shard) + ": " + str(mod), Color.NAVAJO_WHITE, true)
	return mod

## Returns the luck-adjusted weight table for all rarity tiers.
func get_rarity_weights(pool : StatShardPool, luck : float) -> Dictionary[Modulate.RARITY, float]:
	return {
		Modulate.RARITY.COMMON    : maxf(pool.common_weight    - luck * 0.5,        0),
		Modulate.RARITY.UNCOMMON  : maxf(pool.uncommon_weight  - luck * 0.25,  1),
		Modulate.RARITY.EPIC      : maxf(pool.epic_weight      + luck * 0.25,  0),
		Modulate.RARITY.LEGENDARY : maxf(pool.legendary_weight + luck * 0.10, 0),
		Modulate.RARITY.MYTHIC    : maxf(pool.mythic_weight    + luck * 0.01, 0),
	}
	
func _shard_has_rarity(shard : StatShard, rarity : Modulate.RARITY) -> bool:
	var lut : Array[Array] = [
		shard.common_modulates,
		shard.uncommon_modulates,
		shard.rare_modulates,
		shard.legendary_modulates,
		shard.mythical_modulates,
	]
	return not lut[rarity].is_empty()

## Live preview: current stat → what it will be after picking up.
## Used by ShardCollectable before the modulate is appended.
func get_stat_preview_text(m: Modulate) -> String:
	var target  : Object  = m._get_target()
	var current : Variant = target.get(m.statistic)
	var after   : Variant = m._get_modified_value(current)
	return str(snappedf(float(current), 0.01)) + " -> " + str(snappedf(float(after), 0.01))

## Frozen snapshot: what the stat was before and after this modulate was appended.
## Used by ShardIcon after pickup — values never change.
func get_stat_snapshot_text(m: Modulate) -> String:
	if not m.stat_appended:
		push_warning("get_stat_snapshot_text called before append() on %s" % m.stat_name)
		return "?"
	return str(snappedf(float(m.pre_append_value), 0.01)) + " -> " + str(snappedf(float(m.post_append_value), 0.01))
	
