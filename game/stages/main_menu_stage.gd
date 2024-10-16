extends Control

signal start_game()
signal load_game()

func _ready() -> void:
	Sound.play_bgm("main_menu")
	find_child("QuitButton").visible = not OS.has_feature("web")
	find_child("LoadButton").visible = Options.does_savegame_exist()
	
	find_child("LoadButton").text = str("Load (", int(Parser.get_game_progress_from_file(Options.SAVEGAME_PATH) * 100), "%)")

	$Logo.visible = false
	$Planet.visible = false
	$PlanetBlast.visible = false
	$Blast.visible = false
	
	var logo_timer = get_tree().create_timer(1.5)
	logo_timer.timeout.connect($Logo.set.bind("visible", true))
	
	var planet_timer = get_tree().create_timer(2.5)
	planet_timer.timeout.connect($Planet.set.bind("visible", true))
	
	if GameWorld.just_finished_game:
		GameWorld.just_finished_game = false
		var blast_timer = get_tree().create_timer(4)
		blast_timer.timeout.connect($PlanetBlast.set.bind("visible", true))
		blast_timer.timeout.connect($Blast.set.bind("visible", true))
		

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if GameWorld.stage_root.get_node("ScreenContainer").get_child_count() == 0:
			GameWorld.stage_root.set_screen("")
		else:
			GameWorld.stage_root.set_screen(CONST.SCREEN_OPTIONS)

func _on_quit_button_pressed() -> void:
	Options.save_prefs()
	get_tree().quit()


func _on_options_button_pressed() -> void:
	GameWorld.stage_root.set_screen(CONST.SCREEN_OPTIONS)


func _on_credits_button_pressed() -> void:
	GameWorld.stage_root.set_screen(CONST.SCREEN_CREDITS)


func _on_cw_button_pressed() -> void:
	GameWorld.stage_root.set_screen(CONST.SCREEN_CONTENT_WARNING)


func _on_discord_button_pressed() -> void:
	OS.shell_open("https://discord.gg/jPU4RvmTvP")


func _on_git_hub_button_pressed() -> void:
	OS.shell_open("https://github.com/SnekOfSpice/dialog-editor")
