extends Resource
class_name StatShardPool

const WEIGHT_MULTIPLIER : int = 20

@export var pool_id : int = 0
@export var pool_name : String = "Common Shard Pool"
@export var pool_crystal_color : Color = Color.WHITE
@export var shards : Array[StatShard] = []

func init_pool() -> Dictionary[StatShard, int]:
	var final_pool : Dictionary[StatShard, int] = {}
	for i in shards:
		final_pool[i] = int(i.weight * float(WEIGHT_MULTIPLIER))
		_T.say(pool_name + ": shard " + i.stat_name + " assigned a weight value of " + str(int(i.weight * float(WEIGHT_MULTIPLIER))), Color.YELLOW, true)
	return final_pool
