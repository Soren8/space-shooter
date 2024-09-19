# main.gd
extends Node2D

# ---- Variables ----
var score: int = 0
var level: int = 1
var lives: int = 3

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
    spawn_asteroids(5)

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
        
        # Set asteroid size randomly between 0.2 and 1.0
        var asteroid_size = randf_range(0.2, 1.0)
        asteroid.set_size(asteroid_size)
        
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
func _on_Asteroid_destroyed(size: float):
    score += 10 * size
    print("Score updated to:", score)  # Debug statement
    var new_size = size - 1
    if new_size > 0:
        spawn_smaller_asteroids(new_size)

# ---- Player Hit Signal Handler ----
func _on_Player_hit():
    lives -= 1
    print("Player hit! Lives remaining:", lives)  # Debug statement
    if lives <= 0:
        game_over()
    else:
        player_instance.respawn()

# ---- Spawn Smaller Asteroids Function ----
func spawn_smaller_asteroids(new_size: float):
    var screen_size = get_viewport().size
    for i in range(2):  # Spawn two smaller asteroids
        var asteroid = AsteroidScene.instantiate()
        asteroids_node.add_child(asteroid)
        asteroid.position = player_instance.position  # Or choose appropriate position
        asteroid.set_size(new_size)
        
        # Assign random movement direction
        var angle = randf() * PI * 2
        asteroid.velocity = Vector2(cos(angle), sin(angle)) * asteroid.speed
        
        # Connect asteroid to its signals
        asteroid.connect("asteroid_destroyed", Callable(self, "_on_Asteroid_destroyed"))
        asteroid.connect("player_hit", Callable(self, "_on_Player_hit"))

# ---- Game Over Handling ----
func game_over():
    get_tree().paused = true
    var game_over_label = Label.new()
    game_over_label.text = "GAME OVER\nFinal Score: %d" % score
    
    # Set alignment properties for Godot 4
    game_over_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    game_over_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    
    # Position the label at the center of the viewport
    game_over_label.rect_position = get_viewport().size / 2
    game_over_label.rect_pivot_offset = game_over_label.rect_size / 2
    
    # Customize appearance (optional)
    # Uncomment and set the correct path to your font if desired
    # game_over_label.add_font_override("font", load("res://path_to_font.tres"))
    # game_over_label.set("custom_colors/font_color", Color(1, 0, 0))  # Example: Red font
    
    # Add the label to the HUD
    hud_node.add_child(game_over_label)
    print("Game Over! Final Score:", score)  # Debug statement
