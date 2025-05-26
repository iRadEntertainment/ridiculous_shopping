extends RigidBody3D
class_name Trolley


var bean: BeanPlayer:
	set(val):
		bean = val
		if val:
			add_collision_exception_with(bean)
