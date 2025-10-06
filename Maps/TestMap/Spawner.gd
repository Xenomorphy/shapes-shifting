extends Node2D

# Spawner Information #
var enemy       : PackedScene = preload("res://Characters/Enemy/Enemy.tscn")
var to_spawn    : bool = false
var interval    : float = 2.0
var max_enemies : int = 20

# Setup #
func _ready() -> void:
    var timer = Timer.new()
    timer.wait_time = interval
    timer.autostart = true
    timer.connect("timeout", spawn)
    add_child(timer)

# Spawn Function #
func spawn() -> void:
    if get_child_count() < max_enemies:
        var instance = enemy.instantiate()
        instance.global_position = Vector2(600, 300)
        add_child(instance)
