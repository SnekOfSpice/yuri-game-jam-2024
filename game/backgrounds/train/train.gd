extends Node2D

var direction := 1

func _ready() -> void:
	set_direction(1)
	get_tree().create_timer(randf_range(5.0, 20.0)).timeout.connect(bump_carriages)

func bump_carriages():
	var carriages = $Train.get_children()
	if direction == -1:
		carriages.reverse()
	var cumulative_delay = 0.0
	for carriage : Sprite2D in carriages:
		if cumulative_delay == 0:
			carriage.position.y = 10
		else:
			get_tree().create_timer(cumulative_delay).timeout.connect(bump_carriage.bind(carriage))
		get_tree().create_timer(0.4 + cumulative_delay).timeout.connect(reset_carriage.bind(carriage))
		cumulative_delay += 0.1
	get_tree().create_timer(randf_range(5.0, 20.0)).timeout.connect(bump_carriages)

func bump_carriage(carriage:Node2D):
	carriage.position.y = 10

func reset_carriage(carriage:Node2D):
	carriage.position.y = 0

func set_direction(value:int):
	direction = sign(value)
	
	for child in get_children():
		if child is Parallax2D:
			child.autoscroll.x = abs(child.autoscroll.x) * direction
	
	find_child("Train").scale.x = direction
