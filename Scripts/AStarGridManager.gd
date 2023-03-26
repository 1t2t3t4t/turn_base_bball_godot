@tool

extends Node3D

class_name AStarGridManager

@export_category("Cell Configuration")
@export var cellScene: PackedScene = preload("res://AStarGrid.tscn")
@export var width: float = 1:
	set(newVal):
		width = newVal
		_create_grids_editor()

@export var height: float = 1:
	set(newVal):
		height = newVal
		_create_grids_editor()

@export_category("Configuration")
@export var row: int = 10:
	set(newVal):
		row = newVal
		_create_grids_editor()
@export var column: int = 10:
	set(newVal):
		column = newVal
		_create_grids_editor()
		
@onready var grids: Node3D = $Grids
@onready var a_star_path_finder := $AStarPathFinder as AStarPathFinder

var _a_star_grids: Dictionary = {}

func _clear_grids_children(grids: Node3D) -> void:
	for child in grids.get_children():
		grids.remove_child(child)
		child.queue_free()

func _create_grids_editor() -> void:
	pass

func _ready() -> void:
	_create_grids()

func _create_grids() -> void:
	_clear_grids_children(grids)
	for x in range(0, row):
		for y in range(0, column):
			var new_cell = cellScene.instantiate() as AStarGrid
			var config = AStarGrid.AStarGridConfiguration.new(width, height, 0.2, x, y)
			new_cell.configure(config)
			new_cell.name = "Grid row %s column %s" % [x, y]
			grids.add_child(new_cell)
			_a_star_grids[new_cell.index_id] = new_cell

func get_grid_idx(index_id: String) -> AStarGrid:
	return _a_star_grids[index_id]

func get_grid(g_row: int, g_column: int) -> AStarGrid:
	if g_row >= 0 && g_row < row && g_column >= 0 && g_column < column:
		return get_grid_idx(AStarGrid.create_index_id(g_row, g_column))
	return null
	
func get_neighbour(grid: AStarGrid) -> Array[AStarGrid]:
	var results: Array[AStarGrid] = []
	for i in range(-1, 2):
		for j in range(-1, 2):
			if i == 0 && j == 0:
				continue
			var n_grid := get_grid(grid.row + i, grid.column + j)
			if n_grid:
				results.append(n_grid)
	return results
	
func find_path(from: AStarGrid, to: AStarGrid) -> Array[AStarGrid]:
	return a_star_path_finder.find_path(from, to)
