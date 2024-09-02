extends Control
class_name StageRoot

var stage := ""
var screen := ""

func _ready():
	change_stage(CONST.STAGE_MAIN)
	set_screen("")
	GameWorld.stage_root = self

#func _input(event: InputEvent) -> void:
	#if Input.is_action_just_pressed("ui_cancel") and $ScreenContainer.get_child_count() == 0:
		#set_screen(CONST.SCREEN_OPTIONS)
		#get_viewport().set_input_as_handled()

#func _gui_input(event: InputEvent) -> void:
	#printt(3, event)
	#if Input.is_action_just_pressed("ui_cancel") and $ScreenContainer.get_child_count() == 0:
		#set_screen(CONST.SCREEN_OPTIONS)

func set_screen(screen_path:String):
	if Parser.line_reader:
		if Parser.line_reader.is_input_locked:
			return
	
	var screen_container:Control
	if GameWorld.camera is GameCamera:
		screen_container = GameWorld.camera.get_screen_container()
	else:
		screen_container = $ScreenContainer
	
	if screen_path.is_empty():
		for c in screen_container.get_children():
			c.queue_free()
		screen_container.visible = false
		if $StageContainer.get_child_count() > 0:
			$StageContainer.get_child(0).grab_focus()
		screen = screen_path
		return
	var new_stage = load(str(CONST.SCREEN_ROOT, screen_path)).instantiate()
	screen_container.add_child(new_stage)
	screen_container.visible = true
	screen = screen_path

func set_background(background:String, fade_time:=0.0):
	print(str("BACKGROUND_", background.to_upper()))
	var path = str(CONST.BACKGROUND_ROOT, CONST.get(str("BACKGROUND_", background.to_upper())))
	if not path:
		push_warning(str("COULDN'T FIND BACKGROUND ", background, "!"))
		path = str(CONST.BACKGROUND_ROOT, CONST.BACKGROUND_HOME_REGULAR)
	var new_background:Node2D
	var old_backgrounds:=$Background.get_children()
	if path.ends_with(".png"):
		new_background = Sprite2D.new()
		new_background.texture = load(path)
		new_background.centered = false
	elif path.ends_with(".tscn"):
		new_background = load(path).instantiate()
	else:
		push_error(str("Background ", background, " does not end in .png or .tscn."))
		return
	new_background.modulate.a = 0.0
	$Background.add_child(new_background)
	
	var viewport_height = ProjectSettings.get_setting("display/window/size/viewport_height")
	var viewport_width = ProjectSettings.get_setting("display/window/size/viewport_width")
	var background_size := Vector2.ZERO
	if new_background is Sprite2D:
		background_size = new_background.texture.get_size()
	elif new_background.has_method("get_size"):
		background_size = new_background.get_size()
	
	if background_size.x > viewport_width and background_size.y > viewport_height and background_size != Vector2.ZERO:
		new_background.position = background_size * 0.5
		
	
	var fade_tween := get_tree().create_tween()
	fade_tween.tween_property(new_background, "modulate:a", 1.0, fade_time)
	for old_node : Node in old_backgrounds:
		fade_tween.finished.connect(old_node.queue_free)
	
	GameWorld.background = background

func new_gamestate():
	game_start_callable = Parser.reset_and_start
	change_stage(CONST.STAGE_GAME)
	#Parser.reset_and_start()

func load_gamestate():
	game_start_callable = Options.load_gamestate
	change_stage(CONST.STAGE_GAME)
	#Options.load_gamestate()
	#Parser.paused = false

var game_start_callable:Callable
func change_stage(stage_path:String):
	await get_tree().process_frame
	
	var new_stage = load(str(CONST.STAGE_ROOT, stage_path)).instantiate()
	
	if stage_path == CONST.STAGE_GAME:
		new_stage.callable_upon_blocker_clear = game_start_callable
	
	for child in $StageContainer.get_children():
		if new_stage != child:
			child.queue_free()
	$StageContainer.add_child(new_stage)
	
	
	match stage_path:
		CONST.STAGE_MAIN:
			new_stage.start_game.connect(new_gamestate)
			new_stage.load_game.connect(load_gamestate)
		#CONST.STAGE_GAME:
			#new_stage.blockers_cleared.connect(game_start_callable)
	
	stage = stage_path
	set_screen("")
	
