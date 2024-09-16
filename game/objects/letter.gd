extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Clean.text = $Handwriting.text


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_font_button_pressed() -> void:
	$Handwriting.visible = not $Handwriting.visible
	$Clean.visible = not $Clean.visible


func _on_read_button_pressed() -> void:
	if GameWorld.game_stage:
		GameWorld.game_stage.show_ui()
	if Parser.line_reader:
		Parser.line_reader.instruction_handler.instruction_completed.emit()
	queue_free()
