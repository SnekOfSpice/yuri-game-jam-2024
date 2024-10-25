extends Node


var states_by_page := {}

func _ready() -> void:
	ParserEvents.go_back_accepted.connect(on_go_back_accepted)
	ParserEvents.new_line_read.connect(on_new_line_read)

func on_new_line_read(line:int):
	line -= 1
	# save the state
	var state := {}
	
	var characters := {}
	for character : Character in get_tree().get_nodes_in_group("character"):
		characters[character.character_name] = character.serialize()
	state["characters"] = characters
	state["background"] = GameWorld.background
	state["bgm"] = Sound.bgm_key
	if is_instance_valid(GameWorld.camera):
		state["camera"] = GameWorld.camera.serialize()
	
	if states_by_page.has(Parser.page_index):
		states_by_page[Parser.page_index][line] = state
	else:
		states_by_page[Parser.page_index] = {line : state}
	
	prints("saving to ", Parser.page_index, line)

func on_go_back_accepted(page:int, line:int):
	if not states_by_page.has(page):
		return
	var prev_index = 0
	#for key in states_by_page[page].keys():
		#if key > prev_index and key < line:
			#prev_index = key
	if not states_by_page[page].has(line):
		return
	
	# handle payload
	var state : Dictionary = states_by_page[page][line]
	var characters : Dictionary = state.get("characters", {})
	for character : Character in get_tree().get_nodes_in_group("character"):
		character.deserialize(characters.get(character.character_name, {}))
	
	if is_instance_valid(GameWorld.stage_root):
		GameWorld.stage_root.set_background(state.get("background", ""))
	
	if is_instance_valid(GameWorld.camera):
		GameWorld.camera.deserialize(state.get("camera", {}))

	Sound.play_bgm(state.get("bgm", Sound.bgm_key))
	
	prints("restoring ", page, line)
