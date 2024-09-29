extends Node2D
class_name Character

@export var character_name := ""
var emotion := ""

var target_x := 0

signal repositioned()

func _ready():
	ParserEvents.dialog_line_args_passed.connect(on_dialog_line_args_passed)
	add_to_group("character")
	target_x = position.x
	
	if character_name == "anhedonia":
		set_x_position(1)
	elif character_name == "one":
		set_x_position(1)
	elif character_name == "spectra":
		set_x_position(7)
	elif character_name == "torturer":
		set_x_position(7)
	elif character_name == "interrogator":
		set_x_position(6)
	elif character_name == "one+anhedonia":
		set_x_position(4)
	

func set_x_position(idx:int, time := 0, advance_instruction_after_reposition:=false):
	var positions := [
		-120,
		0,
		240,
		307,
		475,
		960.0 / 2.0,
		960 - 475,
		960 - 307,
		960 - 240,
		960,
		960 + 120
	]
	
	target_x = positions[idx + 2]
	var t = create_tween()
	t.tween_property(self, "position:x", target_x, time)
	
	if advance_instruction_after_reposition and Parser.line_reader:
		t.finished.connect(Parser.line_reader.instruction_handler.instruction_completed.emit.bind())

func serialize() -> Dictionary:
	var result := {}
	
	result["visible"] = visible
	result["emotion"] = emotion
	result["target_x"] = target_x
	
	return result

func deserialize(data: Dictionary):
	visible = data.get("visible", false)
	set_emotion(data.get("emotion", "neutral"))
	position.x = data.get("target_x", position.x)

func on_dialog_line_args_passed(actor_name: String, dialog_line_args: Dictionary):
	var new_modulate:float
	if actor_name == character_name:
		new_modulate = 1.0
	else:
		new_modulate = 0.8
	modulate.v = new_modulate
	if dialog_line_args.has(str(character_name, "-emotion")):
		var emotion : String = dialog_line_args.get(str(character_name, "-emotion"))
		emotion = emotion.trim_suffix("-emotion")
		set_emotion(emotion)

func set_emotion(emotion_name:String):
	emotion = emotion_name
	print(character_name, " gets emotion \"", emotion_name, "\".")
	if emotion_name == "invisible":
		visible = false
		return
	visible = true
	find_child("Sprite").texture = load(str("res://game/characters/sprites/", character_name, "-", emotion, ".png"))
