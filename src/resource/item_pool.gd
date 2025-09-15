extends Resource
class_name ItemPool

@export var id : String = "Default Pool"
@export var items : Array[Item]

var final_pool : Dictionary[Item, int] = {}

const WEIGHT_MULT : int = 20

func initialize_pool() -> void:
	var final_dict : Dictionary[Item, int]
	for i in items:
		final_dict[i] = int(i.weight * float(WEIGHT_MULT))
		_T.say(id + ": Item " + i.item_name + " assigned a weight value of " + str(int(i.weight * float(WEIGHT_MULT))), Color.YELLOW, true)
	final_pool = final_dict
	_T.say("Pool " + id + " initialized")
	_T.say("Final Pool " + id + ": " + str(final_dict), Color.WHITE, true)
