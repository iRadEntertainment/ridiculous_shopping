extends Node3D
class_name Interactible

@export_flags_3d_physics var collision_mask = 0xFFFFFFFF


var parent: PhysicsBody3D
var mesh_instance: MeshInstance3D
var next_pass_material: ShaderMaterial

var cam: Camera3D

var is_hovered := false:
	set(val):
		if is_hovered == val:
			return
		is_hovered = val
		highlight(is_hovered)


func _ready() -> void:
	# Guard statements
	parent = get_parent()
	if not parent is PhysicsBody3D:
		printerr("Interactible: assigned to a node that doesn't extends PhysicsBody3D")
		queue_free()
		return
	
	parent.add_to_group("interactibles", true)
	mesh_instance = find_first_mesh_in_node_3D(parent)
	
	# load and apply next pass material for the highlight
	next_pass_material = preload("res://assets/meshes/outline_next_pass.tres").duplicate(true)
	mesh_instance.mesh.surface_get_material(0).next_pass = next_pass_material
	next_pass_material.set_shader_parameter("outline_color", Color.TRANSPARENT)


func highlight(toggle: bool) -> void:
	if not mesh_instance: return
	next_pass_material.set_shader_parameter("outline_color", Color.RED if toggle else Color.TRANSPARENT)


static func find_first_mesh_in_node_3D(node: Node3D, exclude: Array = []) -> MeshInstance3D:
	for child in node.get_children():
		if child is MeshInstance3D:
			if !child in exclude:
				return child
		if child.get_child_count() != 0:
			var found = find_first_mesh_in_node_3D(child, exclude)
			if found:
				return found
	return null


static func get_children_recursive(node: Node) -> Array[Node]:
	var found: Array[Node] = []
	for child in node.get_children():
		found.append(child)
		if child.get_child_count() != 0:
			found.append_array(get_children_recursive(child))
	return found
