extends Character


var blink_intervals = []

func _ready() -> void:
	for child in $EyesOpen.get_child_count():
		blink_intervals.append(randf_range(20, 25))
	for child : Sprite2D in $EyesClosed.get_children():
		child.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var blink_index := 0
	while blink_index < blink_intervals.size():
		blink_intervals[blink_index] -= delta
		if blink_intervals[blink_index] <= 0:
			blink_intervals[blink_index] = randf_range(20, 25)
			$EyesClosed.get_child(blink_index).visible = true
			var t = get_tree().create_timer(0.3)
			t.timeout.connect($EyesClosed.get_child(blink_index).set.bind("visible", false))
		blink_index += 1
