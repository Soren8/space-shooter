extends CanvasLayer

var is_paused: bool = false

func _ready():
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS

# ---- Pause Handling ----
func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause():
	is_paused = not get_tree().paused  # Toggle based on the tree's current paused state
	get_tree().paused = not get_tree().paused  # Flip the pause state of the tree
	if is_paused:
		get_node("/root/Main/HUD/PauseLabel").show()
		var viewport_size = get_viewport().size
		get_node("/root/Main/HUD/PauseLabel").position = viewport_size / 2
	else:
		get_node("/root/Main/HUD/PauseLabel").hide()
