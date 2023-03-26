extends Camera3D

@export var speed = 5

var current_speed: float:
	get:
		if Input.is_action_pressed("speed"):
			return speed * 2
		return speed

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var motion = event as InputEventMouseMotion
		var movement = -motion.relative
		rotate_y(movement.x * 0.005)
		rotate_object_local(Vector3.RIGHT, movement.y * 0.005)
		rotation.x = clamp(rotation.x, -PI / 3, PI / 3)

func _physics_process(delta: float) -> void:
	var movement_dir = Vector3.ZERO

	var forward_motion = Input.get_axis("forward", "back")
	var right_motion = Input.get_axis("left", "right")
	var up_motion = Input.get_axis("down", "up")

	movement_dir += transform.basis.z * forward_motion
	movement_dir += transform.basis.x * right_motion
	movement_dir += Vector3.UP * up_motion
	position = position + (movement_dir.normalized() * current_speed * delta)
