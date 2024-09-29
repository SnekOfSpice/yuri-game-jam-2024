extends InstructionHandler


signal start_black_fade(
	fade_in:float,
	hold_time:float,
	fade_out:float,
	hide_characters:bool,
	new_background:String,
	new_bgm:String)

signal start_show_cg(
	cg_name:String,
	fade_in:float,
	on_top:bool)

signal start_hide_cg()
signal start_chapter_cover(pov_name:String)

func play_sfx(_name:String):
	Sound.play_sfx(_name)
	return false

func set_bgm(_name:String, fade_in:float):
	Sound.play_bgm(_name, fade_in)
	return false

func set_text_style(style: String) -> bool:
	if style == "ToBottom":
		GameWorld.game_stage.set_text_style(GameStage.TextStyle.ToBottom)
	elif style == "ToCharacter":
		GameWorld.game_stage.set_text_style(GameStage.TextStyle.ToCharacter)
	return false

func black_fade(fade_in:float, hold_time:float, fade_out:float, hide_characters:bool, new_background:String, new_bgm:String):
	var bg = new_background
	if new_background == "none":
		bg = GameWorld.background
	
	var bgm = new_bgm
	if not bg:
		push_warning(str("COULDN'T FIND MUSIC ", new_bgm, "!"))
		bgm = "main_menu"
	if new_bgm == "none" or new_bgm == "null":
		bgm = Sound.bgm_key
	
	emit_signal("start_black_fade",
	fade_in,
	hold_time,
	fade_out,
	hide_characters,
	bg,
	bgm,
	)
	return true


func hide_all_characters() -> bool:
	for character: Character in get_tree().get_nodes_in_group("character"):
		character.visible = false
	return false


func show_cg(_name:String, fade_in_time:float, continue_dialog_through_cg:bool):
	emit_signal("start_show_cg",
	_name,
	fade_in_time,
	not continue_dialog_through_cg
	)
	return true

func hide_cg():
	emit_signal("hide_cg")
	return false

func set_background(_name:String, fade_time:float):
	GameWorld.stage_root.set_background(
				_name,
				fade_time
			)
	return false


func play_chapter_intro(pov_name: String, bottom_text: String, new_background: String, zoom: float, bgm: String) -> bool:
	if bgm == "null":
		bgm = Sound.bgm_key
	emit_signal("start_chapter_cover", pov_name, bottom_text, new_background, zoom, bgm)
	return true

func zoom_to(value: float, duration:float) -> bool:
	GameWorld.camera.zoom_to(value, duration)
	return false

func splatter_blood(amount: float) -> bool:
	print_rich("[color=#ff0000][b]BLOOD BLOOD BLOOD[/b][/color]")
	# Return true if you want the LineReader to wait until its InstructionHandler has emitted instruction_completed.
	# (Needs to be called by your code from somewhere.)
	return false

func set_emotion(actor_name: String, emotion_name: String) -> bool:
	for character : Character in get_tree().get_nodes_in_group("character"):
		if character.character_name == actor_name:
			character.set_emotion(emotion_name)
	return false

func show_character(character_name: String, clear_others: bool) -> bool:
	for character : Character in get_tree().get_nodes_in_group("character"):
		if character.character_name == character_name:
			character.visible = true
		elif clear_others:
			character.visible = false
	return false


func shake_camera(strength: float) -> bool:
	if GameWorld.camera:
		GameWorld.camera.apply_shake(strength)
	return false


func set_x_position(character_name: String, index: float, time: float, wait_for_reposition: bool) -> bool:
	if GameWorld.game_stage:
		var character : Character = GameWorld.game_stage.get_character(character_name)
		character.set_x_position(int(index), time)
	# Return true if you want the LineReader to wait until its InstructionHandler has emitted instruction_completed.
	# (Needs to be called by your code from somewhere.)
	return wait_for_reposition

func show_letter() -> bool:
	if GameWorld.game_stage:
		GameWorld.game_stage.show_letter()
		return true
	return false
