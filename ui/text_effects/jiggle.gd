extends RichTextEffect

@export var bbcode := "jiggle"


func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var t := Time.get_ticks_msec() / 1000.0
	
	var wave_amplitude_x := 5.0
	var wave_length := 5.0 
	var wave_amplitude_y := 2.0
	
	var x_offset = sin(t * 6.0 - char_fx.relative_index / wave_length) * wave_amplitude_x
	var y_offset = sin(t * 8.0 - char_fx.relative_index / (wave_length * 1.5)) * wave_amplitude_y
	
	char_fx.offset += Vector2(x_offset, y_offset)
	return true
