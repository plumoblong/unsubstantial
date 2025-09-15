extends Node3D
class_name Room

var id : int = 0

func _process(delta : float) -> void:
	$ID.text = str(id)
	$ID.visible = _G.debug_mode

#func volume_area_entered(area : Area3D):
	#if area.name == "Volume":
		#$Walls.visible = false
		#$Volume.monitoring = false
		#$LeftQuery.monitoring = false
		#$RightQuery.monitoring = false
		#$BackQuery.monitoring = false
		#$ForwardQuery.monitoring = false
		#$Tile.visible = false
		#$ID.modulate = Color.YELLOW

func forward_query_area_entered(area : Area3D) -> void:
	if area != self:
		$Walls/Forward.hide()

func back_query_area_entered(area : Area3D) -> void:
	if area != self:
		$Walls/Back.hide()

func right_query_area_entered(area : Area3D) -> void:
	if area != self:
		$Walls/Right.hide()

func left_query_area_entered(area : Area3D) -> void:
	if area != self:
		$Walls/Left.hide()

func forward_query_area_exited(area : Area3D) -> void:
	if area != self:
		$Walls/Forward.show()

func back_query_area_exited(area : Area3D) -> void:
	if area != self:
		$Walls/Back.show()

func right_query_area_exited(area : Area3D) -> void:
	if area != self:
		$Walls/Right.show()

func left_query_area_exited(area : Area3D) -> void:
	if area != self:
		$Walls/Left.show()
