extends CanvasLayer

var background : ColorRect

func _ready():
	background = ColorRect.new()
	background.color = Color.BLACK
	add_child(background)
	update_background_size()
	
	randomize()
	var star_count = randi() % 100 + 50

	for i in star_count:
		create_star()

func create_star():
	var star = ColorRect.new()
	star.color = Color.WHITE
	
	var star_size = 2
	star.rect_size = Vector2(star_size, star_size)
	
	var pos_x = randf() * get_viewport().size.x
	var pos_y = randf() * get_viewport().size.y
	star.rect_position = Vector2(pos_x, pos_y)
	
	var scale = randf_range(0.5, 1.5)
	star.rect_scale = Vector2(scale, scale)
	
	add_child(star)

func _notification(what):
	if what == NOTIFICATION_WM_SIZE_CHANGED:
		update_background_size()

func update_background_size():
	if is_instance_valid(background):
		background.rect_size = get_viewport().size
		background.rect_position = Vector2.ZERO

# If you want to update or regenerate stars on resize, you would handle it here or in a custom function
