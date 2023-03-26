extends Node3D

@onready var panel: Panel = $UI/Panel
@onready var a_star_grid_manager = $AStarGridManager as AStarGridManager
@onready var timer: Timer = $Timer

var begin: AStarGrid
var end: AStarGrid

var path_results: Array[AStarGrid]

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_action_pressed("select"):
			_cast_ray()
	if event.is_action_pressed("ui_accept"):
		_clear_path_results()
		
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	
func _cast_ray() -> void:
	var camera = get_viewport().get_camera_3d()
	var space = get_world_3d().direct_space_state
	var from = camera.position
	var to = camera.position + (-camera.transform.basis.z * 10000)
	var params = PhysicsRayQueryParameters3D.create(from, to)
	params.exclude = [self]
	params.collide_with_areas = true
	var result = space.intersect_ray(params)
	
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
