extends Area2D


# --- EXPORTS ---
@export var health: int = 2
@export var move_speed: float = 150.0
@export var score_value: int = 100
@export var bullet_scene: PackedScene
@export var explosion_scene: PackedScene
@export var shoot_interval_min: float = 1.5
@export var shoot_interval_max: float = 3.0


# --- ENUM: MOVEMENT PATTERNS ---
# An enum defines named integer constants grouped under a namespace.
# MovementPattern.STRAIGHT == 0, SINE_WAVE == 1, DIAGONAL == 2
# You can also write: enum MovementPattern { STRAIGHT=0, SINE_WAVE=1, ... }
enum MovementPattern {
	STRAIGHT,       # Flies straight down
	SINE_WAVE,      # Oscillates left/right while descending
	DIAGONAL        # Descends at a diagonal angle
}

# @export with an enum creates a dropdown in the Inspector. Very useful.
@export var movement_pattern: MovementPattern = MovementPattern.STRAIGHT


# --- NODES ---
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var shoot_timer: Timer = $ShootTimer


# --- STATE ---
var time_alive: float = 0.0          # Accumulates delta — used for sine math
var diagonal_dir: float = 1.0        # 1.0 = right, -1.0 = left
var screen_size: Vector2


func _ready() -> void:
	add_to_group("enemies")
	screen_size = get_viewport().get_visible_rect().size

	# Random diagonal direction using randi().
	# randi() % 2 returns 0 or 1.
	# We use a ternary: condition ? value_if_true : value_if_false
	diagonal_dir = 1.0 if randi() % 2 == 0 else -1.0

	# Random shoot interval adds unpredictability.
	# randf_range(min, max) returns a random float in [min, max].
	shoot_timer.wait_time = randf_range(shoot_interval_min, shoot_interval_max)
	shoot_timer.one_shot = false
	shoot_timer.start()
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)

	area_entered.connect(_on_area_entered)
	sprite.play("fly")


func _process(delta: float) -> void:
	# Accumulate time — used in sine wave calculation below.
	time_alive += delta

	_move(delta)
	_check_screen_bounds()


func _move(delta: float) -> void:
	# 'match' is GDScript's switch statement.
	# It compares the expression (movement_pattern) against each branch.
	# No fall-through — only the matching branch executes.
	match movement_pattern:

		MovementPattern.STRAIGHT:
			# Simple: move straight down.
			position.y += move_speed * delta

		MovementPattern.SINE_WAVE:
			# Sine wave horizontal movement while descending.
			# sin(t) oscillates between -1 and 1 over time.
			# amplitude controls horizontal range (pixels).
			# frequency controls how fast the wave oscillates.
			var amplitude: float = 80.0
			var frequency: float = 2.0
			# cos() used for X (horizontal), gives smooth oscillation.
			position.x += cos(time_alive * frequency) * amplitude * delta
			position.y += move_speed * delta

		MovementPattern.DIAGONAL:
			# Move down AND sideways simultaneously.
			position.x += move_speed * diagonal_dir * 0.6 * delta
			position.y += move_speed * delta

			# Bounce off screen edges — reverse horizontal direction.
			if position.x < 30.0 or position.x > screen_size.x - 30.0:
				diagonal_dir *= -1.0


func _check_screen_bounds() -> void:
	# Destroy the enemy if it leaves the bottom of the screen.
	if position.y > screen_size.y + 100.0:
		queue_free()


func take_damage() -> void:
	health -= 1

	# Flash effect: multiply the sprite's color modulate by 2.0 (makes it brighter).
	# Color.WHITE is (1, 1, 1, 1). Multiplying by 2.0 overblooms to (2, 2, 2, 1).
	modulate = Color.WHITE * 2.0

	# After 0.1 seconds, reset the color back to normal.
	# await suspends this function here and resumes when the timer fires.
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE

	if health <= 0:
		_die()


func _die() -> void:
	# Award score to GameManager.
	GameManager.add_score(score_value)

	# Spawn explosion at our position before we disappear.
	if explosion_scene != null:
		var explosion: Node2D = explosion_scene.instantiate()
		get_tree().current_scene.add_child(explosion)
		# Use global_position so the explosion appears in world space.
		explosion.global_position = global_position

	queue_free()


func _on_shoot_timer_timeout() -> void:
	_shoot()


func _shoot() -> void:
	if bullet_scene == null:
		return

	var bullet: Node2D = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = global_position

	# Reset the timer with a new random interval each shot.
	shoot_timer.wait_time = randf_range(shoot_interval_min, shoot_interval_max)
	shoot_timer.start()


func _on_area_entered(area: Area2D) -> void:
	# If the player's aircraft body-slams into us, both take damage.
	if area.is_in_group("player"):
		if area.has_method("take_damage"):
			area.take_damage()
		_die()
