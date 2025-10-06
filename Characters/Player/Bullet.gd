extends Area2D

# Movement Information #
const SPEED = 200
var direction : Vector2

func _ready() -> void:
    direction = (get_global_mouse_position() - global_position).normalized()

func _physics_process(delta: float) -> void:
    position += direction * SPEED * delta

func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("Enemy"): body.queue_free()
    queue_free()
