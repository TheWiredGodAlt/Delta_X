extends Area2D


@export var speed: float = 300.0

# Direction is set by the Enemy when spawning this bullet.
# Default: straight down. Enemy can override with an aimed direction.
var direction: Vector2 = Vector2.DOWN


func _ready() -> void:
	add_to_group("enemy_bullets")
	area_entered.connect(_on_area_entered)


# Called by Enemy.gd after instantiating this bullet to set its direction.
# This is how parent scripts communicate initial state to child instances.
func initialize(spawn_direction: Vector2) -> void:
	direction = spawn_direction.normalized()


func _process(delta: float) -> void:
	position += direction * speed * delta
	_check_screen_bounds()


func _check_screen_bounds() -> void:
	var screen: Vector2 = get_viewport().get_visible_rect().size
	if position.y > screen.y + 50.0 or position.y < -50.0:
		queue_free()
	if position.x < -50.0 or position.x > screen.x + 50.0:
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		# The player handles its own damage logic.
		# We just destroy ourselves.
		queue_free()
