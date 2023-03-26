extends Area3D

class_name AStarGrid

@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D

@export_color_no_alpha var selected_color: Color
@export_color_no_alpha var path_color: Color

var _configuration: AStarGridConfiguration

enum Highlight {
	NONE,
	SELECTED,
	PATH
}

var row: int:
	get:
		return _configuration.row

var column: int:
	get:
		return _configuration.column

var index_id: String:
	get:
		return create_index_id(row, column)

static func create_index_id(row: int, column: int) -> String:
	return "%s|%s" % [row, column]
	
func configure(configuration: AStarGridConfiguration) -> void:
	_configuration = configuration

func _ready() -> void:
	var offset_x = row * _configuration.width
	var offset_z = column * _configuration.height
	position.x += offset_x
	position.z += offset_z
	
	var box_shape = collision_shape_3d.shape as BoxShape3D
	box_shape.size = Vector3(_configuration.width, _configuration.depth, _configuration.height)
	mesh_instance_3d.mesh.set("size", box_shape.size)

func on_camera_cast() -> void:
	print("Cast on", index_id)
	
func highlight(mode: Highlight) -> void:
	match mode:
		Highlight.NONE:
			mesh_instance_3d.hide()
		Highlight.SELECTED:
			mesh_instance_3d.show()
			var new_mat := StandardMaterial3D.new()
			new_mat.albedo_color = selected_color
			mesh_instance_3d.material_override = new_mat
		Highlight.PATH:
			mesh_instance_3d.show()
			var new_mat := StandardMaterial3D.new()
			new_mat.albedo_color = path_color
			mesh_instance_3d.material_override = new_mat
	
class AStarGridConfiguration:
	var width: float
	var height: float
	var depth: float
	
	var row: int
	var column: int
	
	func _init(width: float, height: float, depth: float, row: int, column: int) -> void:
		self.width = width
		self.height = height
		self.depth = depth
		self.row = row
		self.column = column
