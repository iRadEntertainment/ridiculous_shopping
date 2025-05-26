extends RigidBody3D
class_name Trolley


var bean: BeanPlayer:
	get():
		return Mng.bean


func _ready() -> void:
	Mng.trolley = self
