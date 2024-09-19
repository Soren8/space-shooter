extends Area2D

# Constants
const SPEED = 500
const LIFETIME = 1.0  # seconds

# Variables
var velocity = Vector2.ZERO
var lifetime = LIFETIME

func _ready():
	set_process(true)
	add_to_group("Bullet")

func _process(delta):
	position += velocity * delta
	lifetime -= delta
	if lifetime <= 0:
		queue_free()
	wrap_around()

func wrap_around():
	var screen_size = get_viewport_rect().size
	if position.x > screen_size.x:
		position.x = 0
	elif position.x < 0:
		position.x = screen_size.x
	if position.y > screen_size.y:
		position.y = 0
	elif position.y < 0:
		position.y = screen_size.y

# Collision Handling
func _on_body_entered(body: Node):
	if body.is_in_group("Asteroid"):
		body.queue_free()
		get_parent().score += 10 * body.size  # Assuming 'score' is accessible
		queue_free()
