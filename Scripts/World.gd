extends Node3D

@onready var a_star_grid_manager = $AStarGridManager as AStarGridManager
@onready var timer: Timer = $Timer
@onready var camera_3d: Camera3D = $Camera3D
@onready var csg_torus_3d: CSGTorus3D = $Map/Hoop/CSGTorus3D

var begin: AStarGrid
var end: AStarGrid

var path_results: Array[AStarGrid]

var target_pos: Vector3 = Vector3.ZERO

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_action_pressed("select"):
			_cast_ray()
	if event.is_action_pressed("ui_accept"):
		_clear_path_results()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	if Input.is_action_just_pressed("ui_accept"):
		target_pos = csg_torus_3d.global_position

	if target_pos != Vector3.ZERO:
		var look_dir := (target_pos - camera_3d.transform.origin).normalized()
		var look_basis := Basis.looking_at(look_dir)
		camera_3d.transform.basis = camera_3d.transform.basis.slerp(look_basis, 0.1)

func _cast_ray() -> void:
	var camera = get_viewport().get_camera_3d()
	var space = get_world_3d().direct_space_state
	var from = camera.position
	var to = camera.position + (-camera.transform.basis.z * 10000)
	var params := PhysicsRayQueryParameters3D.create(from, to)
	params.exclude = [self]
	params.collide_with_areas = true
	var result = space.intersect_ray(params)
	DebugDraw3d.draw_line(from, to, 5.0)

	if result.has("position"):
		var position = result.get("position") as Vector3
		DebugDraw3d.draw_box(position, Vector3(0.2, 0.2, 0.2), 1)

	if result.has("collider") && result["collider"] is AStarGrid:
		var grid = result["collider"] as AStarGrid
		grid.on_camera_cast()

		if begin == null:
			begin = grid
			grid.highlight(AStarGrid.Highlight.SELECTED)
		elif end == null:
			end = grid
			grid.highlight(AStarGrid.Highlight.SELECTED)
			path_results = a_star_grid_manager.find_path(begin, end)
			for r in path_results:
				r.highlight(AStarGrid.Highlight.PATH)
			timer.start()


func _on_timer_timeout() -> void:
	_clear_path_results()

func _clear_path_results() -> void:
	if path_results:
		for r in path_results:
				r.highlight(AStarGrid.Highlight.NONE)
	begin = null
	end = null
