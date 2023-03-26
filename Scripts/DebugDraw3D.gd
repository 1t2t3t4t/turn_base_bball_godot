extends Node

class_name DrawDebug3D

class DrawnInstance:
	var instance: MeshInstance3D
	var duration: float
	var killed: bool = false

	func _init(n_instance: MeshInstance3D, n_duration: float) -> void:
		self.instance = n_instance
		self.duration = n_duration

	func kill() -> void:
		instance.queue_free()
		killed = true

var _instances: Array[DrawnInstance] = []
var _timer: Timer

var debug_material: Material:
	get:
		var material := StandardMaterial3D.new()
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.albedo_color = Color(1.0, 0, 0, 0.5)
		return material

func _ready() -> void:
	if OS.is_debug_build():
		_timer = Timer.new()
		_timer.name = "Clean Timer"
		_timer.wait_time = 0.1
		_timer.timeout.connect(_clear_instances.bind(0.1))
		add_child(_timer)
		_timer.start()

func _clear_instances(delta: float) -> void:
	for i in _instances:
		if i.duration < 0:
			i.kill()
		i.duration -= delta

	var i = 0
	while i < len(_instances):
		if _instances[i].killed:
			_instances.remove_at(i)
			i -= 1
		i += 1

func draw_box(position: Vector3, size: Vector3, duration: float = 0.0) -> void:
	if not OS.is_debug_build():
		return

	var box_mesh := BoxMesh.new()
	box_mesh.size = size
	_create_mesh_instance(position, box_mesh, duration)

func draw_line(start: Vector3, end: Vector3, duration: float = 0.0) -> void:
	if not OS.is_debug_build():
		return

	var mesh := ImmediateMesh.new()
	mesh.surface_begin(Mesh.PRIMITIVE_LINES, debug_material)
	mesh.surface_add_vertex(start)
	mesh.surface_add_vertex(end)
	mesh.surface_end()
	_create_mesh_instance(Vector3.ZERO, mesh, duration)


func _create_mesh_instance(position: Vector3, mesh: Mesh, duration: float) -> void:
	if not OS.is_debug_build():
		return

	var mesh_instance := MeshInstance3D.new()

	mesh_instance.mesh = mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mesh_instance.global_position = position
	mesh_instance.material_override = debug_material
	get_tree().root.add_child(mesh_instance)

	_instances.append(DrawnInstance.new(mesh_instance, duration))
