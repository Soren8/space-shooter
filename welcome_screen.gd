extends CanvasLayer

func _ready():
	set_process_input(true)  # Ensure _input is called
	center_labels()

func _input(event):
	if event is InputEventKey and event.pressed:
		start_game()

func start_game():
	# Load and instance the main game scene
	var main_game_scene = preload("res://main.tscn").instantiate()
	get_tree().root.add_child(main_game_scene)
	get_tree().current_scene = main_game_scene
	queue_free()  # Remove the welcome screen

	# Start the music here
	var audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	audio_player.stream = preload("res://audio/Galactic-Dreams.mp3")
	audio_player.play()

func center_labels():
	var viewport_size = get_viewport().size  # This will be Vector2i
	
	# Convert viewport_size to Vector2 for floating-point precision
	var viewport_size_vector2 = Vector2(viewport_size)

	# Center GameDescriptionLabel
	var game_desc_label = $GameDescriptionLabel
	game_desc_label.position = (viewport_size_vector2 - game_desc_label.size) / 2

	# Position StartInstructionLabel below GameDescriptionLabel
	var start_instr_label = $StartInstructionLabel
	start_instr_label.position = Vector2(
		(viewport_size.x - start_instr_label.size.x) / 2,
		game_desc_label.position.y + game_desc_label.size.y + 20  # 20 pixels below GameDescriptionLabel
	)
