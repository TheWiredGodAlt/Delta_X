
extends Area2D


@export var speed: float = 600.0

# Vector2.UP is the constant (0.0, -1.0) — pointing upward.
# In Godot: Y increases downward, so -Y points up.
var direction: Vector2 = Vector2.UP


func _ready() -> void:
	# Tag this bullet so enemies can identify it in their area_entered callback.
	add_to_group("player_bullets")

	# Connect overlap detection.
	area_entered.connect(_on_area_entered)


func _process(delta: float) -> void:
	# Move upward every frame.
	position += direction * speed * delta

	# Clean up if the bullet leaves the screen.
	_check_screen_bounds()


func _check_screen_bounds() -> void:
	var screen: Vector2 = get_viewport().get_visible_rect().size

	# Margin of 50px — destroy bullet slightly outside screen edge.
	if position.y < -50.0:
		queue_free()
	if position.y > screen.y + 50.0:
		queue_free()
	if position.x < -50.0:
		queue_free()
	if position.x > screen.x + 50.0:
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemies"):
		# has_method() checks if the function exists before calling it.
		# This is defensive programming — prevents runtime errors if an enemy
		# variant doesn't implement take_damage().
		if area.has_method("take_damage"):
			area.take_damage()
		queue_free()    # Bullet is consumed on impact.
