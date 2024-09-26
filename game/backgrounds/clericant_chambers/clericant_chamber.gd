extends Node2D


func _ready() -> void:
	$AnimatedSprite2D.play("default")

func get_size():
	return $Sprite2D.texture.get_size() * $Sprite2D.scale

func _on_animated_sprite_2d_animation_finished() -> void:
	$AnimatedSprite2D.speed_scale *= -1
	$AnimatedSprite2D.play("default")
