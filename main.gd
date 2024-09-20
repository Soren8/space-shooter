# main.gd
extends Node2D

# ---- Variables ----
var score: int = 0
var level: int = 1
var lives: int = 3
var asteroids_count = 0

# ---- Preloads ----
@onready var PlayerScene: PackedScene = preload("res://player/player.tscn")
@onready var BulletScene: PackedScene = preload("res://bullet/bullet.tscn")
@onready var AsteroidScene: PackedScene = preload("res://asteroid/asteroid.tscn")

# ---- Nodes ----
var player_instance: Area2D
var bullets_node: Node2D
var asteroids_node: Node2D
var hud_node: CanvasLayer

# ---- Ready Function ----
func _ready():
	# Initialize Nodes
	bullets_node = get_node("Bullets")
	asteroids_node = get_node("Asteroids")
	hud_node = get_node("HUD")

	# Instantiate Player
	player_instance = PlayerScene.instantiate()
	add_child(player_instance)
	player_instance.position = get_viewport().size / 2
	player_instance.connect("shoot_bullet", Callable(self, "_on_Player_shoot_bullet"))
	# Removed: player_instance.connect("body_entered", Callable(self, "_on_Player_body_entered"))

	# Spawn Initial Asteroids
	spawn_asteroids(7)

# ---- Player Shooting Bullet ----
func _on_Player_shoot_bullet(position: Vector2, rotation: float):
	print("Bullet emitted from position:", position, "with rotation:", rotation)  # Debug statement
	var bullet = BulletScene.instantiate()
	bullet.position = position
	bullet.rotation = rotation
	bullets_node.add_child(bullet)
	
	# No need to connect signals here as collisions are handled within Bullet and Asteroid scripts
	print("Bullet instantiated at position:", bullet.position, "with velocity:", bullet.velocity)  # Debug statement

# ---- Spawn Asteroids Function ----
func spawn_asteroids(num: int):
	asteroids_count += num
	var screen_size = get_viewport().size
	for i in range(num):
		var asteroid = AsteroidScene.instantiate()
		asteroids_node.add_child(asteroid)
		
		# Random position at edges
		var edge = randi() % 4
		match edge:
			0:
				asteroid.position = Vector2(0, randf() * screen_size.y)  # Left edge
			1:
				asteroid.position = Vector2(screen_size.x, randf() * screen_size.y)  # Right edge
			2:
				asteroid.position = Vector2(randf() * screen_size.x, 0)  # Top edge
			3:
				asteroid.position = Vector2(randf() * screen_size.x, screen_size.y)  # Bottom edge
		
		# Random movement direction
		var angle = randf() * PI * 2
		asteroid.velocity = Vector2(cos(angle), sin(angle)) * asteroid.speed
		
		# Connect asteroid to its signals
		asteroid.connect("asteroid_destroyed", Callable(self, "_on_Asteroid_destroyed"))
		asteroid.connect("player_hit", Callable(self, "_on_Player_hit"))

# ---- Process Function ----
func _physics_process(delta: float):
	# Update HUD
	hud_node.get_node("ScoreLabel").text = "Score: %d" % score
	hud_node.get_node("LivesLabel").text = "Lives: %d" % lives
	hud_node.get_node("LevelLabel").text = "Level: %d" % level

# ---- Asteroid Destroyed Signal Handler ----
func _on_Asteroid_destroyed(size: float, parent_position: Vector2):
	score += 10 * size
	var new_size = size - 1
	if new_size > 0:
		spawn_smaller_asteroids(new_size, parent_position)
	# Check if it was the last asteroid
	asteroids_count -= 1  # Decrement the count when an asteroid is destroyed
	if asteroids_count <= 0:
		win_game()

# ---- Player Hit Signal Handler ----
func _on_Player_hit():
	lives -= 1
	print("Player hit! Lives remaining:", lives)  # Debug statement
	if lives <= 0:
		game_over()
	else:
		player_instance.respawn()

# ---- Spawn Smaller Asteroids Function ----
func spawn_smaller_asteroids(new_size: float, parent_position: Vector2):
	var screen_size = get_viewport().size
	for i in range(3):
		print("Spawning small asteroid ", i + 1, " with size ", new_size)  # Debug print
		asteroids_count += 1
		var asteroid = AsteroidScene.instantiate()
		asteroids_node.add_child(asteroid)  # Removed call_deferred
		
		asteroid.position = parent_position  # Set to parent asteroid's position
		asteroid.set_size(new_size)  # Removed call_deferred
		
		# Assign random movement direction
		var angle = randf() * PI * 2
		asteroid.velocity = Vector2(cos(angle), sin(angle)) * asteroid.speed
		
		# Connect asteroid to its signals
		asteroid.connect("asteroid_destroyed", Callable(self, "_on_Asteroid_destroyed"))
		asteroid.connect("player_hit", Callable(self, "_on_Player_hit"))


# ---- Game Over Handling ----
func game_over():
	get_tree().paused = true
	
	var game_over_label = $HUD/GameOverLabel
	game_over_label.text = "GAME OVER\nFinal Score: %d" % score
	game_over_label.position = get_viewport().size / 2
	game_over_label.show()
	
	print("Game Over! Final Score: ", score)

func win_game():
	get_tree().paused = true  # Pause the game
	var win_label = $HUD/WinLabel
	var viewport_size = get_viewport().size
	var label_half_width = win_label.size.x / 2
	win_label.position = Vector2(viewport_size.x / 2 - label_half_width, viewport_size.y / 2)
	win_label.show()
