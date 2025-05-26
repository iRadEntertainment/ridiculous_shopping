extends PanelContainer
class_name GameTimer


@onready var timer_label = $TimerLabel

var time_passed := 0.0
var running := false


func _process(delta: float) -> void:
	if running:
		time_passed += delta
		timer_label.text = format_time(time_passed)


func format_time(seconds: float) -> String:
	@warning_ignore("integer_division")
	var mins: int = int(seconds) / 60
	var secs: int = int(seconds) % 60
	var millis: int = int((seconds - int(seconds)) * 1000)
	return "[jiggle]%02d:%02d.%03d[/jiggle]" % [mins, secs, millis]


func start_timer() -> void:
	time_passed = 0.0
	running = true


func stop_timer() -> void:
	running = false


func reset_timer() -> void:
	time_passed = 0.0
	timer_label.text = format_time(time_passed)
