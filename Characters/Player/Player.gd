extends CharacterBody2D

# Sub-nodes #
var sprite   : Sprite2D
var collider : CollisionShape2D
var health   : Label

# Combat Information #
var hp            : int = 100
var bullet        : PackedScene = preload("res://Characters/Player/Bullet.tscn")
var timer         : Timer = Timer.new()
const SHOOT_DELAY : float = 1.0

# Shapeshifting Information #
enum SHAPE {CIRCLE = 1, SQUARE = 0, TRIANGLE = 2, RADIUS = 16}
var current_shape  : SHAPE = SHAPE.CIRCLE
var next_shape     : SHAPE = SHAPE.CIRCLE
var textures := {
    SHAPE.CIRCLE   : preload("res://Characters/Player/Textures/Circle.png"),
    SHAPE.SQUARE   : preload("res://Characters/Player/Textures/Square.png"),
    SHAPE.TRIANGLE : preload("res://Characters/Player/Textures/Triangle.png")
}
var colliders := {
    SHAPE.CIRCLE   : CircleShape2D.new(),
    SHAPE.SQUARE   : RectangleShape2D.new(),
    SHAPE.TRIANGLE : ConvexPolygonShape2D.new()
}
var shifting       : bool = false
var shift_time     : float = 1.0
const SHIFT_SPEED  : float = 1.0

# Movement Information #
const SPEED : int = 400

# Input Handling #
var action_map = {
    "one": func() -> void: next_shape = SHAPE.CIRCLE,
    "two": func() -> void: next_shape = SHAPE.SQUARE,
    "three": func() -> void: next_shape = SHAPE.TRIANGLE
}

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.is_pressed():
        for action in action_map.keys():
            if Input.is_action_pressed(action):
                action_map[action].call()

# Setup #
func _ready() -> void:
    sprite = %Sprite
    collider = %Collider
    health = %Health

    # Set various collider sizes
    colliders[SHAPE.SQUARE].set_size(Vector2(SHAPE.RADIUS*2, SHAPE.RADIUS*2))
    colliders[SHAPE.CIRCLE].set_radius(SHAPE.RADIUS)
    colliders[SHAPE.TRIANGLE].set_points(PackedVector2Array([
        Vector2(0.0, -SHAPE.RADIUS),
        Vector2(-SHAPE.RADIUS, SHAPE.RADIUS),
        Vector2(SHAPE.RADIUS, SHAPE.RADIUS)
    ]))

# Game Loop #
func _physics_process(delta: float) -> void:
    shapeshift(delta)
    move()
    combat()
    display()

# Shapeshifting #
func shapeshift(delta: float) -> void:
    if next_shape != current_shape and !shifting:
        sprite.material.set_shader_parameter("from", textures[current_shape])
        sprite.material.set_shader_parameter("to", textures[next_shape])
        sprite.material.set_shader_parameter("grow", current_shape > next_shape)

        collider.shape = colliders[next_shape]

        shift_time = 0.0
        current_shape = next_shape

    shifting = shift_time < 1.0
    if shifting:
        shift_time += SHIFT_SPEED * delta
        sprite.material.set_shader_parameter("t", clamp(shift_time, 0, 1))

# Movement #
func move() -> void:
    look_at(get_global_mouse_position())
    rotation += deg_to_rad(90)
    var direction = Input.get_vector(&"ui_left", &"ui_right", &"ui_up", &"ui_down")
    velocity = direction * (SPEED + SPEED * int(current_shape == SHAPE.CIRCLE))
    move_and_slide()

# Combat #
func combat() -> void:
    if current_shape == SHAPE.TRIANGLE:
        if !timer.is_inside_tree():
            timer.wait_time = SHOOT_DELAY
            timer.autostart = true
            timer.connect("timeout", shoot)
            add_child(timer)
    elif timer.is_inside_tree():
        remove_child(timer)

    for i in range(get_slide_collision_count()):
        if get_slide_collision(i).get_collider().is_in_group("Enemy"):
            if current_shape == SHAPE.SQUARE:
                hp -= 1
            else:
                hp = 0

    if hp <= 0:
        queue_free()

func shoot() -> void:
    var instance = bullet.instantiate()
    var offset = (get_global_mouse_position() - global_position).normalized() * SHAPE.RADIUS * 2
    instance.global_position = global_position + offset
    get_tree().root.add_child(instance)

# Display #
func display() -> void:
    health.text = String.num_int64(hp)
    health.rotation = -health.rotation
