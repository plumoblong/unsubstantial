extends Resource
class_name StatShardPool

const WEIGHT_MULTIPLIER : int = 20

@export var pool_id           : int    = 0
@export var pool_name         : String = "Common Shard Pool"
@export var pool_crystal_color: Color  = Color.WHITE

@export var common_weight    : float = 3.0
@export var uncommon_weight  : float = 2.0
@export var epic_weight      : float = 1.0
@export var legendary_weight : float = 0.3
@export var mythic_weight    : float = 0.01

@export var shards            : Array[StatShard] = []

## Builds and returns a weighted shard table ready for random selection.
func build_pool() -> Dictionary[StatShard, int]:
	var pool : Dictionary[StatShard, int] = {}

	for shard: StatShard in shards:
		var weight := int(shard.weight * float(WEIGHT_MULTIPLIER))
		pool[shard] = weight
		_T.say(
			"%s: shard '%s' — weight %d" % [pool_name, shard.stat_name, weight],
			Color.YELLOW, true
		)

	return pool
