extends MeshInstance3D
class_name CashRegister


var mat: StandardMaterial3D:
	get():
		return %cash_reg_light.material_override

var tw_flash: Tween


func _ready() -> void:
	%cash_reg_light.hide()


func _on_area_3d_body_entered(_body: Node3D) -> void:
	if Mng.trolley.is_shopping_complete():
		flash(true)
		Mng.entrance.lock_exit(false)
		Mng.trolley.puff()
		Mng.gui.animate_wave_label("And now GET OUT!", 0.4)
	else:
		flash(false)


func flash(is_success: bool) -> void:
	mat.emission = Color("c7136a") if not is_success else Color("008555")
	%cash_reg_light.show()
	if tw_flash:
		tw_flash.kill()
	
	tw_flash = create_tween()
	tw_flash.set_ease(Tween.EASE_IN_OUT)
	tw_flash.set_trans(Tween.TRANS_EXPO)
	tw_flash.set_loops(6)
	tw_flash.tween_property(mat, ^"emission_energy_multiplier", 0.8, 0.1)
	tw_flash.tween_property(mat, ^"emission_energy_multiplier", 6, 0.1)
	await tw_flash.finished
	%cash_reg_light.hide()
