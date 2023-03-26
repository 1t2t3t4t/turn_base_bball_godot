extends Node3D

class_name AStarPathFinder

@onready var grids: Node3D = $"../Grids"
@onready var grid_manager := $".." as AStarGridManager

class GridNode:
	var grid: AStarGrid
	var g_cost: float = 0
	var h_cost: float = 0

	var f_cost: float:
		get:
			return g_cost + h_cost

	func _init(n_grid: AStarGrid) -> void:
		self.grid = n_grid

	func equal(other: GridNode) -> bool:
		return grid.index_id == other.grid.index_id

func cost(from: AStarGrid, to: AStarGrid) -> float:
	return abs(to.row - from.row) + abs(to.column - from.column)

func remove_grid(arr: Array[GridNode], node: GridNode):
	var idx := -1
	for i in range(0, len(arr)):
		if arr[i].equal(node):
			idx = i
	if idx != -1:
		arr.remove_at(idx)

func has_grid(arr: Array[GridNode], node: GridNode) -> bool:
	for n in arr:
		if n.equal(node):
			return true
	return false

func _retrace(path_map: Dictionary, current_node: GridNode, start: AStarGrid) -> Array[AStarGrid]:
	var results: Array[String] = []

	var current_pos := current_node.grid.index_id
	var start_pos := start.index_id

	while current_pos != start_pos:
		results.append(current_pos)
		current_pos = path_map[current_pos] as String
	results.append(current_pos)
	results.reverse()

	var return_results: Array[AStarGrid] = []
	for idx in results:
		return_results.append(grid_manager.get_grid_idx(idx))

	return return_results

func find_path(from: AStarGrid, to: AStarGrid) -> Array[AStarGrid]:
	var open_list: Array[GridNode] = [GridNode.new(from)]
	var closed_list: Array[GridNode] = [];

	var end_node := GridNode.new(to)

	var path_map: Dictionary = {}

	while not open_list.is_empty():
		var current_node := open_list[0]

		for open_grid in open_list:
			if open_grid.f_cost < current_node.f_cost || \
			(open_grid.f_cost == current_node.f_cost && open_grid.h_cost < current_node.h_cost):
				current_node = open_grid

		remove_grid(open_list, current_node)
		closed_list.append(current_node)

		if current_node.equal(end_node):
			return _retrace(path_map, current_node, from)

		var neighbour := grid_manager.get_neighbour(current_node.grid)
		for n_grid in neighbour:
			var node := GridNode.new(n_grid)
			if has_grid(closed_list, node):
				continue

			var movement_cost := current_node.g_cost + cost(current_node.grid, node.grid)
			if movement_cost < node.g_cost:
				remove_grid(open_list, current_node)

			if not has_grid(open_list, node):
				node.g_cost = movement_cost
				node.h_cost = cost(node.grid, end_node.grid)
				path_map[node.grid.index_id] = current_node.grid.index_id

				open_list.append(node)

	return []
