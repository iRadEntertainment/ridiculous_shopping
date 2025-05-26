extends MeshInstance3D
class_name CashRegister


func _on_area_3d_body_entered(_body: Node3D) -> void:
	if Mng.trolley.is_shopping_complete():
		Mng.entrance.lock_exit(false)
		Mng.trolley.puff()
	
