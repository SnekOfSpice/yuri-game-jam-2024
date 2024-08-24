extends Control

@export var skip := false


@onready var logo_tex : Sprite2D = $Logo
@onready var char_tex : Sprite2D = $Character
@onready var name_tex : RichTextLabel = $Name

var start_positions = {}

signal chapter_intro_finished()

func _ready() -> void:
	visible = false
	modulate.a = 0
	
	start_positions[logo_tex] = logo_tex.position
	start_positions[char_tex] = char_tex.position
	start_positions[name_tex] = name_tex.position
	

func set_chapter_cover(pov_name: String, bottom_text:String):
	if skip:
		emit_signal("chapter_intro_finished")
		return
	var logo_tween = create_tween()
	var char_tween = create_tween()
	var name_tween = create_tween()
	
	match  pov_name:
		"anhedonia":
			char_tex.texture = load("res://game/characters/sprites/anhedonia-neutral.png")
		"one":
			char_tex.texture = load("res://game/characters/sprites/one-neutral.png")
	
	logo_tween.set_parallel()
	char_tween.set_parallel()
	name_tween.set_parallel()
	
	if bottom_text == "EMPTY":
		name_tex.text = ""
		#name_tex.position = start_positions[name_tex]
	else:
		name_tex.text = str("[right]", bottom_text)
	name_tex.position = start_positions[name_tex]
	logo_tex.position = start_positions[logo_tex]
	char_tex.position = start_positions[char_tex]
	
	logo_tex.modulate.a = 0
	char_tex.modulate.a = 0
	name_tex.modulate.a = 0
	
	var black_delay := 0.0
	if Parser.page_index == 0:
		$Black.visible = true
		var black_tween = create_tween()
		black_tween.set_parallel()
		black_delay = 4.0 + 3
		black_tween.tween_property($Black, "modulate:a", 0.0, black_delay).set_delay(3.0)
		GameWorld.stage_root.set_background(CONST.BACKGROUND_FIELD, 0.0)
	else:
		$Black.visible = false
	
	var logo_delay := 0.8 + black_delay
	var char_delay := 4.0 + black_delay
	var name_delay := 6.7 + black_delay
	
	logo_tween.tween_property(logo_tex, "position", logo_tex.position + Vector2(0, -30), 5.0).set_delay(logo_delay).set_ease(Tween.EASE_OUT)
	char_tween.tween_property(char_tex, "position", char_tex.position + Vector2(0, -30), 2.0).set_delay(char_delay).set_ease(Tween.EASE_OUT)
	name_tween.tween_property(name_tex, "position", name_tex.position + Vector2(0, -30), 4.0).set_delay(name_delay).set_ease(Tween.EASE_OUT)
	logo_tween.tween_property(logo_tex, "modulate:a", 1, 1.0).set_delay(logo_delay + 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	char_tween.tween_property(char_tex, "modulate:a", 1, 3.0).set_delay(char_delay + 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	name_tween.tween_property(name_tex, "modulate:a", 1, 3.0).set_delay(name_delay + 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	
	
	
	visible = true
	
	var mod_tween = create_tween()
	mod_tween.finished.connect(start_fade_timer)
	mod_tween.tween_property(self, "modulate:a", 1, 0.3)
	mod_tween.set_parallel()
	mod_tween.tween_property(self, "modulate:a", 0, 2.4).set_delay(max(max(logo_delay, char_delay), name_delay) + 2)
	
	

func start_fade_timer():
	get_tree().create_timer(2).timeout.connect(emit_signal.bind("chapter_intro_finished"))
