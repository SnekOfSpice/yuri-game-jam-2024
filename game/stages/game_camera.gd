extends Camera2D
class_name GameCamera

@export var fade = 5.0

var rng = RandomNumberGenerator.new()

var shake_strength := 0.0

var zoom_tween:Tween

func _ready() -> void:
	GameWorld.camera = self

func _process(delta: float) -> void:
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0, fade * delta)
		
		offset = get_random_offset()

func apply_shake(strength:float):
	shake_strength = strength

func get_random_offset() -> Vector2:
	return Vector2(randf_range(-shake_strength, shake_strength), randf_range(-shake_strength, shake_strength))

func get_screen_container() -> Control:
	return find_child("ScreenContainer")

func zoom_to(value:float, duration:float):
	if zoom_tween:
		zoom_tween.kill()
	zoom_tween = create_tween()
	zoom_tween.tween_property(self, "zoom", Vector2(value, value), duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
