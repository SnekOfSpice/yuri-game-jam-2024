@tool
extends Control
class_name TextContent

signal drop_focus()

const WORD_SEPARATORS :=  ["[", "]", "{", "}", ">", "<", ".", ",", "|", " ", "-", ":", ";", "#", "*", "+", "~", "'"]
#var use_dialog_syntax := true
var active_actors := [] # list of character names
var active_actors_title := ""

var entered_arguments := 0
var used_arguments := []

var text_box : CodeEdit

var control_sequences := ["lc", "ap", "mp", "var", "func", "name", "fact", "strpos", "call", "advance"]

func get_text_before_caret(length:int):
	var line : String = text_box.get_line(text_box.get_caret_line())
	if text_box.get_caret_column() <= length:
		return line.substr(0, length)
	return line.substr(text_box.get_caret_column() - length, length)
	
func get_text_after_caret(length:int):
	var line : String = text_box.get_line(text_box.get_caret_line())
	if line.length() - text_box.get_caret_column() <= length:
		return line.substr(text_box.get_caret_column())
	return line.substr(text_box.get_caret_column(), length)

func init() -> void:
	text_box = find_child("TextBox")
	await get_tree().process_frame
	
	fill_active_actors()
	set_page_view(Pages.editor.get_selected_page_view())
	set_use_dialog_syntax(Pages.use_dialog_syntax)
	
	# these are  the symbols that need to wrap any position where code completion
	# should be able to be triggered /on both sides/
	var a : PackedStringArray = [">", "{", "<", "|", "}", ",", ":", "[", "]"]
	for actor in active_actors:
		a.append(actor[actor.length() - 1])
	text_box.code_completion_prefixes = a
	
	await get_tree().process_frame
	text_box.grab_focus()
	text_box.cancel_code_completion()

func set_use_dialog_syntax(value:bool):
	#use_dialog_syntax = value
	find_child("ActiveActorsLabel").visible = value

func serialize() -> Dictionary:
	var result := {}
	
	result["content"] = text_box.text
	#result["use_dialog_syntax"] = use_dialog_syntax
	result["active_actors"] = active_actors
	result["active_actors_title"] = active_actors_title
	
	return result

func deserialize(data: Dictionary):
	text_box.text = data.get("content", "")
	active_actors = data.get("active_actors", [])
	active_actors_title = data.get("active_actors_title", "")
	fill_active_actors()
	set_use_dialog_syntax(data.get("use_dialog_syntax", Pages.use_dialog_syntax))

func set_page_view(view:DiisisEditor.PageView):
	find_child("DialogSyntaxContainer").visible = view == DiisisEditor.PageView.Full
	if not text_box:
		return
	match view:
		DiisisEditor.PageView.Full:
			text_box.custom_minimum_size.y = 100
			text_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
			text_box.scroll_fit_content_height = true
		DiisisEditor.PageView.Truncated:
			text_box.custom_minimum_size.y = 25
			text_box.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
			text_box.scroll_fit_content_height = true
		DiisisEditor.PageView.Minimal:
			text_box.custom_minimum_size.y = 25
			text_box.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
			text_box.scroll_fit_content_height = false


var caret_movement_to_do := 0
func _process(delta: float) -> void:
	if caret_movement_to_do != 0:
		move_caret(caret_movement_to_do)
		caret_movement_to_do = 0

func get_word_under_caret() -> String:
	var line := text_box.get_line(text_box.get_caret_line())
	var start_position := text_box.get_caret_column()
	var i := start_position-1
	var character_at_position := line[i]
	var word := ""
	while not (character_at_position in WORD_SEPARATORS) and i >= 0:
		character_at_position = line[i]
		if character_at_position in WORD_SEPARATORS:
			break
		word = character_at_position + word
		
		i -= 1
	i = start_position + 1
	while not (character_at_position in WORD_SEPARATORS) and i < line.length():
		character_at_position = line[i]
		if character_at_position in WORD_SEPARATORS:
			break
		word += character_at_position
		
		i += 1
	
	return word

func _find_position_under_caret(back_to_front:bool) -> int:
	var line := text_box.get_line(text_box.get_caret_line())
	var start_position := text_box.get_caret_column()
	var found_position:int
	if back_to_front:
		found_position = -1
	else:
		found_position = line.length()
	for separator in WORD_SEPARATORS:
		var separator_position:int
		if back_to_front:
			separator_position = line.rfind(separator, start_position)
			if separator_position > found_position:
				found_position = separator_position
		else:
			separator_position = line.find(separator, start_position)
			if separator_position < found_position and separator_position != -1:
				found_position = separator_position
	return found_position

func get_start_position_of_word_under_caret() -> int:
	return _find_position_under_caret(true)

func get_end_position_of_word_under_caret() -> int:
	return _find_position_under_caret(false)

func get_separator_character_before_word_under_caret() -> String:
	var line := text_box.get_line(text_box.get_caret_line())
	var pos := get_start_position_of_word_under_caret()
	if pos == -1:
		return ""
	return line[pos]

func get_separator_character_after_word_under_caret() -> String:
	var line := text_box.get_line(text_box.get_caret_line())
	var pos := get_end_position_of_word_under_caret()
	if pos == line.length():
		return ""
	return line[pos]

func is_current_line_empty():
	return text_box.get_line(text_box.get_caret_line()).is_empty()

func _on_text_box_caret_changed() -> void:
	if text_box.get_caret_column() == 0:
		var is_line_empty = text_box.get_line(text_box.get_caret_line()).is_empty()
		if Pages.use_dialog_syntax and is_line_empty:
			prepare_line_for_text_insertion()
	
	
	var full_actor_before_caret := false
	for actor:String in active_actors:
		if is_text_before_caret(actor):
			full_actor_before_caret = true
			break
		
	if is_text_before_caret("[]>"):
		for actor in active_actors:
			text_box.add_code_completion_option(CodeEdit.KIND_PLAIN_TEXT, actor, str(actor, ":"))

		text_box.update_code_completion_options(true)

	elif is_text_before_caret("{"):
		if Pages.dropdown_dialog_arguments.is_empty():
			Pages.editor.notify("No Dialog Arguments set.\nGo to Setup > Dropdowns to change this.")
		for actor in Pages.dropdown_dialog_arguments:
			text_box.add_code_completion_option(CodeEdit.KIND_PLAIN_TEXT, actor, str(actor, "|}"))
		text_box.update_code_completion_options(true)
	elif get_text_before_caret(1) == "," and get_text_after_caret(1) == "}":
		var used_args = get_used_dialog_args_in_line()
		for arg in Pages.dropdown_dialog_arguments:
			if arg in used_args:
				continue
			text_box.add_code_completion_option(CodeEdit.KIND_PLAIN_TEXT, arg, str(arg, "|"))
		text_box.update_code_completion_options(true)
	elif get_text_before_caret(1) == "<":
		# duplicated because some tags have a : and some just end with >
		for a in ["ap>", "lc>", "mp>", "func:>", "var:>", "name:>", "fact:>", "strpos>", "call:>", "advance>"]:
			text_box.add_code_completion_option(CodeEdit.KIND_PLAIN_TEXT, a, a)
		text_box.update_code_completion_options(true)
	elif get_text_before_caret(1) == "|":
		for a in Pages.dropdowns.get(Pages.auto_complete_context, []):
			text_box.add_code_completion_option(CodeEdit.KIND_PLAIN_TEXT, a, a)
		text_box.update_code_completion_options(true)
	elif full_actor_before_caret and get_text_after_caret(1) == ":":
		text_box.add_code_completion_option(CodeEdit.KIND_PLAIN_TEXT, "a", "a")
		text_box.update_code_completion_options(true)
	elif is_text_before_caret(":") and is_text_after_caret(">"):
		if is_text_before_caret("func:") or is_text_before_caret("call:"):
			for method in Pages.get_evaluator_methods():
				text_box.add_code_completion_option(CodeEdit.KIND_PLAIN_TEXT, method, method)
		elif is_text_before_caret("var:"):
			for property in Pages.get_evaluator_properties():
				text_box.add_code_completion_option(CodeEdit.KIND_PLAIN_TEXT, property, property)
		elif is_text_before_caret("fact:"):
			for fact in Pages.facts.keys():
				text_box.add_code_completion_option(CodeEdit.KIND_PLAIN_TEXT, fact, fact)
		text_box.update_code_completion_options(true)
	elif is_text_before_caret("["):
		for tag in ["b", "i", "u", "s"]:
			var display_text:String
			match tag:
				"b":
					display_text = "bold"
				"i":
					display_text = "italics"
				"u":
					display_text = "underline"
				"s":
					display_text = "strikethrough"
			text_box.add_code_completion_option(CodeEdit.KIND_PLAIN_TEXT, display_text, str(tag, "][/", tag, "]"))
		text_box.update_code_completion_options(true)

func update():
	fill_active_actors()

func get_used_dialog_args_in_line() -> Array:
	var line : String = text_box.get_line(text_box.get_caret_line())
	if not line.begins_with("[]>"):
		return []
	if not line.contains("}:"):
		return []
	
	var beginning := line.split(":")[0]
	beginning = beginning.trim_prefix("[]>")
	for actor in active_actors:
		beginning = beginning.trim_prefix(actor)
	beginning = beginning.trim_prefix("{")
	beginning = beginning.trim_suffix("}")
	var arg_pairs := beginning.split(",")
	var args := []
	for pair in arg_pairs:
		if not pair.contains("|"):
			continue
		var arg_name = pair.split("|")[0]
		args.append(arg_name)
	
	return args

func prepare_line_for_text_insertion():
	if not text_box.get_selected_text().is_empty():
		return
	used_arguments.clear()
	entered_arguments = 0
	text_box.insert_text_at_caret("[]>")

func fill_active_actors():
	var title = Pages.dropdown_title_for_dialog_syntax
	active_actors.clear()
	for v in Pages.dropdowns.get(title, []):
		active_actors.append(v)
	active_actors_title = title
	find_child("ActiveActorsLabel").text = ", ".join(active_actors)


func _on_text_box_focus_entered() -> void:
	if text_box.text.is_empty() and Pages.use_dialog_syntax:
		prepare_line_for_text_insertion()


func _on_text_box_text_changed() -> void:
	var line_index = text_box.get_caret_line()
	var col_index = text_box.get_caret_column()
	var last_char : String
	if col_index > 0:
		last_char = get_text_before_caret(1)
	else:
		last_char = ""

func move_caret(amount: int):
	text_box.set_caret_column(text_box.get_caret_column() + amount)

func is_text_before_caret(what:String):
	return get_text_before_caret(what.length()) == what

func is_text_after_caret(what:String):
	return get_text_after_caret(what.length()) == what

func _on_text_box_code_completion_requested() -> void:
	for arg_name in Pages.dropdown_dialog_arguments:
		if is_text_before_caret(str(arg_name, "|}")):
			Pages.auto_complete_context = arg_name
			caret_movement_to_do = -1
		elif is_text_before_caret(str(arg_name, "|")):
			Pages.auto_complete_context = arg_name
		elif is_text_after_caret("|"):
			caret_movement_to_do = 1

	for control in ["func", "name", "var", "fact", "call"]:
		if is_text_before_caret(str("<", control, ":>")):
			prints("before cartet", control)
			caret_movement_to_do = -1
			Pages.auto_complete_context = control
			break
	
	for tag in ["b", "i", "u", "s"]:
		if is_text_before_caret(str("[/", tag, "]")):
			caret_movement_to_do = -str("[/", tag, "]").length()
			break


func _on_text_index_pressed(index: int) -> void:
	match index:
		0:
			text_box.text = Pages.capitalize_sentence_beginnings_str(text_box.text)
