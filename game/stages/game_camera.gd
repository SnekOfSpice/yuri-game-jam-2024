extends Camera2D
class_name GameCamera

@export var fade = 5.0

var rng = RandomNumberGenerator.new()

var shake_strength := 0.0

var zoom_tween:Tween

var sway_intensity := 0.0
var sway_speed := 1.0

var screen_shake_hard := false

var start_position := Vector2.ZERO

func _ready() -> void:
	GameWorld.camera = self
	start_position = position
	#sway()
#
#func sway():
	#var tween = create_tween()
	#var target_position = start_position + Vector2.ONE.rotated(randi_range(0, TAU)) * sway_intensity
	#tween.tween_property(self, "position", target_position, sway_speed).set_ease(Tween.EASE_IN_OUT)
	#tween.finished.connect(sway)

func set_sway_intensity(value:float):
	sway_intensity = value

func _process(delta: float) -> void:
	screen_shake_hard_time_left -= delta
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0, fade * delta)
	
	var x:float
	if randf() < 0.5:
		x = asin(Time.get_ticks_msec() / 660.0) - 0.5
	else:
		x = acos(Time.get_ticks_msec() / 660.0) - 0.5
	var y:float
	if randf() < 0.5:
		y = sin(Time.get_ticks_msec() / 660.0) - 0.5
	else:
		y = cos(Time.get_ticks_msec() / 660.0) - 0.5
	
	offset = lerp(
		offset,
		get_random_offset() + Vector2(
			x * sway_intensity,
			y * sway_intensity),
		1 if screen_shake_hard_time_left > 0.0 else 0.02)

var screen_shake_hard_time_left = 0.0

func apply_shake(strength:float):
	shake_strength = strength
	
	screen_shake_hard_time_left = max(0.03 * strength, 0.5)

func get_random_offset() -> Vector2:
	return Vector2(randf_range(-shake_strength, shake_strength), randf_range(-shake_strength, shake_strength))

func get_screen_container() -> Control:
	return find_child("ScreenContainer")

func zoom_to(value:float, duration:float):
	if zoom_tween:
		zoom_tween.kill()
	zoom_tween = create_tween()
	zoom_tween.tween_property(self, "zoom", Vector2(value, value), duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
