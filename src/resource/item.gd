extends Resource
class_name Item

enum TYPE {
	COMMON = 0, # 5 - 4 w
	UNCOMMON = 1, # 4 - 3 w
	RARE = 2, # 3 - 2
	LEGENDARY = 3, # 2 - 1
	BOSS = 4,
}

@export var item_name : String = "Placeholder Item"
@export var item_script : Script = null
@export var type : TYPE = TYPE.COMMON

@export_category("pool info")

@export var weight : float = 1.0
@export var remove_from_pool : bool = true
@export var shop_cost : int = 1000

@export_category("info")

@export var image : Texture = load("res://images/item/passive/item_p0.png")
@export_multiline var item_description : String = "This item shouldn't be here!"

@export_category("other")


#@export var special_cost : float = 5.0
#@export var tags : Array[String] = []
