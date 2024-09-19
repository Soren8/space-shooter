extends Area2D

# Constants
const ACCELERATION = 200
const MAX_SPEED = 300
const ROTATION_SPEED = 5  # degrees per frame
const FRICTION = 0.98
const SHOOT_COOLDOWN = 0.25  # seconds
const INVINCIBILITY_TIME = 2  # seconds

# Variables
var velocity = Vector2.ZERO
var shoot_timer = 0.0
var invincible = false
var invincible_timer = 0.0

# Signals
signal shoot_bullet(position, rotation)

func _ready():
	set_process(true)
	$CollisionPolygon2D.disabled = true
	invincible = true
	invincible_timer = INVINCIBILITY_TIME

func _process(delta):
	handle_input(delta)
	move_and_wrap(delta)
	handle_invincibility(delta)

func handle_input(delta):
	# Rotation
	if Input.is_action_pressed("ui_left"):
		rotation_degrees -= ROTATION_SPEED
	if Input.is_action_pressed("ui_right"):
		rotation_degrees += ROTATION_SPEED

	# Acceleration
	if Input.is_action_pressed("ui_up"):
		var direction = Vector2.UP.rotated(rotation)
		velocity += direction * ACCELERATION * delta

	# Friction
	velocity *= FRICTION

	# Limit speed
	if velocity.length() > MAX_SPEED:
		velocity = velocity.normalized() * MAX_SPEED

	# Shooting
	shoot_timer -= delta
	if Input.is_action_pressed("ui_select") and shoot_timer <= 0:
		fire_bullet()  # Renamed function
		shoot_timer = SHOOT_COOLDOWN

func move_and_wrap(delta):
	position += velocity * delta
	var screen_size = get_viewport_rect().size
	if position.x > screen_size.x:
		position.x = 0
	elif position.x < 0:
		position.x = screen_size.x
	if position.y > screen_size.y:
		position.y = 0
	elif position.y < 0:
		position.y = screen_size.y

func fire_bullet():  # Renamed function
	emit_signal("shoot_bullet", position, rotation)

func handle_invincibility(delta):
	if invincible:
		invincible_timer -= delta
		if invincible_timer <= 0:
			invincible = false
			$CollisionPolygon2D.disabled = false
			$Sprite2D.modulate = Color(1, 1, 1, 1)  # Reset opacity
		else:
			# Blink effect
			$Sprite2D.modulate = Color(1, 1, 1, (sin(invincible_timer * 10) + 1) / 2)

func respawn():
	position = get_parent().get_viewport_rect().size / 2
	velocity = Vector2.ZERO
	rotation = 0
	invincible = true
	invincible_timer = INVINCIBILITY_TIME
	$CollisionShape2D.disabled = true
