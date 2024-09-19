# asteroid.gd

extends Area2D

# ---- Signals ----
signal asteroid_destroyed(size)
signal player_hit()

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
	add_to_group("Asteroid")
	initialize_velocity()

# ---- Set Size Function ----
func set_size(new_size: float):
	size = clamp(new_size, MIN_SIZE, MAX_SIZE)
	var sprite = $Sprite2D
	var collision_shape = $CollisionShape2D

	if sprite and collision_shape:
		# Resize the sprite
		sprite.scale = Vector2(size, size)
		
		# Resize the collision shape
		var shape = collision_shape.shape
		if shape:
			if shape is RectangleShape2D:
				shape.extents = Vector2(size * 16, size * 16)  # Adjust based on base size
			elif shape is CircleShape2D:
				shape.radius = size * 8  # Adjust based on base radius
			collision_shape.shape = shape
		else:
			push_error("CollisionShape2D has no shape assigned.")
		
		# Adjust speed inversely based on size
		speed = BASE_SPEED / size
		velocity = velocity.normalized() * speed
		
		print("Asteroid size set to:", size, "Speed set to:", speed)
	else:
		push_error("Sprite2D or CollisionShape2D node not found in Asteroid scene.")

# ---- Initialize Velocity Function ----
func initialize_velocity():
	# Assign a random direction
	var angle = rng.randf_range(0, PI * 2)
	velocity = Vector2(cos(angle), sin(angle)) * speed

# ---- Process Function ----
func _process(delta):
	move_and_wrap(delta)

# ---- Movement and Wrapping ----
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

# ---- Collision Handling ----
func _on_body_entered(body):
	if body.is_in_group("Bullet"):
		print("Asteroid collided with Bullet:", body)
		emit_signal("asteroid_destroyed", size)
		body.queue_free()
		destroy_asteroid()
	elif body.is_in_group("Player"):
		print("Asteroid collided with Player:", body)
		emit_signal("player_hit")
		destroy_asteroid()

# ---- Destroy Asteroid Function ----
func destroy_asteroid():
	# Implement destruction logic (e.g., splitting into smaller asteroids)
	queue_free()
