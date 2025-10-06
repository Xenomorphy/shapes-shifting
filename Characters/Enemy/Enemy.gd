extends CharacterBody2D

# Movement Information #
const SPEED = 300
var target : CharacterBody2D

# Setup #
func _ready() -> void:
    add_to_group("Enemy")
    target = get_node("/root/Level/Player")

# Game Loop #
func _physics_process(_delta: float) -> void:
    if target:
        var direction = (target.global_position - global_position).normalized()
        velocity = direction * SPEED
        move_and_slide()
