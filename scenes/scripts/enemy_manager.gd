
extends Node2D


@export var enemy_scene: PackedScene
@export var spawn_interval: float = 2.0              # Start: 1 enemy group per 2 seconds
@export var difficulty_increase_time: float = 30.0   # Difficulty bumps every 30 seconds
@export var max_enemies_per_wave: int = 5            # Cap enemies per wave


@onready var spawn_timer: Timer = $SpawnTimer
@onready var difficulty_timer: Timer = $DifficultyTimer


var is_active: bool = true
var current_wave: int = 1
var screen_size: Vector2


func _ready() -> void:
	screen_size = get_viewport().get_visible_rect().size

	# Set up spawn timer.
	spawn_timer.wait_time = spawn_interval
	spawn_timer.one_shot = false
	spawn_timer.start()
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)

	# Set up difficulty escalation timer.
	difficulty_timer.wait_time = difficulty_increase_time
	difficulty_timer.one_shot = false
	difficulty_timer.start()
	difficulty_timer.timeout.connect(_on_difficulty_timer_timeout)


func stop_spawning() -> void:
	# Called by Main.gd when the game ends.
	is_active = false
	spawn_timer.stop()
	difficulty_timer.stop()


func _on_spawn_timer_timeout() -> void:
	if not is_active:
		return
	_spawn_wave()


func _spawn_wave() -> void:
	# Scale enemy count with wave, but cap it.
	# min(a, b) returns the smaller of two values.
	var count: int = min(current_wave, max_enemies_per_wave)

	# range(n) produces [0, 1, 2, ..., n-1] — used for looping n times.
	# Like 'for (int i = 0; i < count; i++)' in C.
	for i in range(count):
		_spawn_single_enemy()


func _spawn_single_enemy() -> void:
	if enemy_scene == null:
		push_warning("EnemyManager: enemy_scene not assigned!")
		return

	var enemy: Node2D = enemy_scene.instantiate()

	# Add as child of EnemyManager (not the root scene) for organization.
	# This keeps the scene tree clean — all enemies are under EnemyManager.
	add_child(enemy)

	# Spawn at a random X position along the top of the screen.
	# randf_range(min, max) gives a random float in [min, max].
	enemy.position.x = randf_range(50.0, screen_size.x - 50.0)
	enemy.position.y = -60.0    # Off-screen top — enters from above.

	# Randomly assign a movement pattern for variety.
	# The patterns array holds all possible enum values.

	# Pick a random index: randi() % array.size() gives [0, size-1]


func _on_difficulty_timer_timeout() -> void:
	current_wave += 1

	# Speed up spawn rate. max(0.5, ...) prevents interval from going below 0.5s.
	# Each wave reduces interval by 0.1 seconds.
	spawn_timer.wait_time = max(0.5, spawn_interval - float(current_wave - 1) * 0.1)
	spawn_timer.start()    # Restart with new interval.
