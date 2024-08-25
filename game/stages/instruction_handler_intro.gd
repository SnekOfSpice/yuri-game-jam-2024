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
	Sound.play_sfx(CONST.get(str("SFX_", _name.to_upper())))
	return false

func set_bgm(_name:String, fade_in:float):
	Sound.play_bgm(_name.to_upper(), fade_in)
	return false

func set_text_style(style: String) -> bool:
	if style == "ToBottom":
		GameWorld.game_stage.set_text_style(GameStage.TextStyle.ToBottom)
	elif style == "ToCharacter":
		GameWorld.game_stage.set_text_style(GameStage.TextStyle.ToCharacter)
	return false

func black_fade(fade_in:float, hold_time:float, fade_out:float, hide_characters:bool, new_background:String, new_bgm:String):
	var bg = CONST.get(str("BACKGROUND_", new_background.to_upper()))
	if not bg:
		push_warning(str("COULDN'T FIND BACKGROUND ", new_background, "!"))
		bg = "home_regular"
	if new_background == "none":
		bg = GameWorld.background
	
	var bgm = CONST.get(str("MUSIC_", new_bgm.to_upper()))
	if not bg:
		push_warning(str("COULDN'T FIND MUSIC ", new_bgm, "!"))
		bgm = "main_menu"
	if new_bgm == "none":
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
				CONST.get(str("BACKGROUND_", _name.to_upper())),
				fade_time
			)
	return false


func play_chapter_intro(pov_name: String, bottom_text:String) -> bool:
	emit_signal("start_chapter_cover", pov_name, bottom_text)
	return true
