extends Character


var blink_intervals := []
var eyelids := []
var eye_progress := 0

var blink_range := Vector2(2, 4)

func _ready() -> void:
	blink_intervals.clear()
	eyelids.clear()
	for eye : Sprite2D in $Eyes.get_children():
		for eyelid in eye.get_children():
			blink_intervals.append(randf_range(blink_range.x, blink_range.y))
			eyelids.append(eyelid)
			eyelid.visible = false
		eye.visible = false
	set_eye_progress(2)

func _process(delta: float) -> void:
	var blink_index := 0
	while blink_index < blink_intervals.size():
		blink_intervals[blink_index] -= delta
		if blink_intervals[blink_index] <= 0:
			blink_intervals[blink_index] = randf_range(blink_range.x, blink_range.y)
			var eyelid : Sprite2D = eyelids[blink_index]
			eyelid.visible = true
			var t = get_tree().create_timer(randf_range(0.25, 0.35))
			t.timeout.connect(eyelid.set.bind("visible", false))
		blink_index += 1

func serialize() -> Dictionary:
	var character_data = super.serialize()
	
	character_data["eye_progress"] = eye_progress
	
	return character_data

func deserialize(data:Dictionary):
	super.deserialize(data)
	set_eye_progress(data.get("eye_progress", 0))

func set_eye_progress(progress:int):
	progress = min(progress, $Eyes.get_child_count() - 1)
	for i in $Eyes.get_child_count():
		$Eyes.get_child(i).visible = progress >= i
	eye_progress = progress
