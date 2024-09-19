# asteroid.gd

extends Area2D

# Constants for size ranges
const MIN_SIZE = 0.2
const MAX_SIZE = 1.0

# Base speed (modifiable based on design)
const BASE_SPEED = 100

# Random number generator for size assignment
var rng = RandomNumberGenerator.new()

# Variables
var size = 1.0  # Current size of the asteroid
var speed = BASE_SPEED  # Current speed based on size
var velocity = Vector2.ZERO  # Movement vector

func _ready():
	set_process(true)
	set_size(get_random_size())
	initialize_velocity()

func get_random_size() -> float:
	return rng.randf_range(MIN_SIZE, MAX_SIZE)

func set_size(new_size: float):
	size = new_size
	var sprite = $Sprite2D
	var collision_polygon = $CollisionPolygon2D
	if sprite and collision_polygon:
		sprite.scale = Vector2(size, size)
		collision_polygon.scale = Vector2(size, size)
		
		# Adjust speed inversely based on size
		speed = BASE_SPEED / size
		velocity = velocity.normalized() * speed
		
		print("Asteroid size set to:", size, "Speed set to:", speed)
	else:
		push_error("Sprite2D or CollisionPolygon2D node not found in Asteroid scene.")

func initialize_velocity():
	# Assign a random direction
	var angle = rng.randf_range(0, PI * 2)
	velocity = Vector2(cos(angle), sin(angle)) * speed

func _process(delta):
	move_and_wrap(delta)

func move_and_wrap(delta):
	position += velocity * delta
	var screen_size = get_viewport().size
	if position.x > screen_size.x:
		position.x = 0
	elif position.x < 0:
		position.x = screen_size.x
	if position.y > screen_size.y:
		position.y = 0
	elif position.y < 0:
		position.y = screen_size.y

func _on_body_entered(body):
	if body.is_in_group("Bullet"):
		destroy_asteroid()
	elif body.is_in_group("Player"):
		# Handle collision with player
		destroy_asteroid()

func destroy_asteroid():
	# Implement destruction logic (e.g., splitting, scoring)
	queue_free()
