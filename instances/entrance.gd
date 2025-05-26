extends Node3D
class_name SupermarketEntrance


signal player_entered
signal player_exited


func _ready() -> void:
	Mng.entrance = self
	lock_exit(false)


func change_title(text: String) -> void:
	var tmesh: TextMesh = %mesh_title.mesh
	tmesh.text = text


func lock_entrance(val: bool) -> void:
	$start_door.lock_door(val)
	%coll_start.disabled = val


func lock_exit(val: bool) -> void:
	$exit_door.lock_door(val)
	%coll_exit.disabled = val


func move_trolley_to_start_pos(trolley: Trolley) -> void:
	trolley.set_deferred("freeze", true)
	trolley.set_deferred("global_transform", %Marker3D_trolley.global_transform)
	trolley.set_deferred("freeze", false)


func _on_area_3d_start_body_entered(_body: Node3D) -> void:
	player_entered.emit()
func _on_area_3d_exit_body_entered(body: Node3D) -> void:
	player_exited.emit()
