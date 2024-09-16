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

func _process(delta: float) -> void:
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0, fade * delta)
		
	offset = lerp(
		offset,
		get_random_offset() + Vector2(
			(sin(Time.get_ticks_msec() / 660.0) - 0.5) * sway_intensity,
			(cos(Time.get_ticks_msec() / 660.0) - 0.5) * sway_intensity),
		1 if screen_shake_hard else 0.02)

var screen_shake_hard_timer:SceneTreeTimer

func apply_shake(strength:float):
	shake_strength = strength
	
	if screen_shake_hard_timer:
		screen_shake_hard_timer.queue_free()
	screen_shake_hard_timer = get_tree().create_timer(fade)
	screen_shake_hard = true
	screen_shake_hard_timer.timeout.connect(set.bind("screen_shake_hard", false))

func get_random_offset() -> Vector2:
	return Vector2(randf_range(-shake_strength, shake_strength), randf_range(-shake_strength, shake_strength))

func get_screen_container() -> Control:
	return find_child("ScreenContainer")

func zoom_to(value:float, duration:float):
	if zoom_tween:
		zoom_tween.kill()
	zoom_tween = create_tween()
	zoom_tween.tween_property(self, "zoom", Vector2(value, value), duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
