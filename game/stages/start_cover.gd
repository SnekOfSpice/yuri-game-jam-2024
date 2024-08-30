extends ColorRect


func _ready() -> void:
	visible = Parser.page_index == 0
	ParserEvents.new_line_read.connect(on_new_line_read)

func on_new_line_read(index:int):
	if index >= 0:
		get_tree().create_timer(1).timeout.connect(set.bind("visible", false))
