@tool
extends MultiMeshInstance3D

const Grass_Blade_Verts = 15
const Num_Grass = 600
const Grass_Height = 1.0
const Grass_Width = 0.05
@export var player:Node3D

var rng = RandomNumberGenerator.new()
var player_rounded_position
@onready var length : float

func _ready() -> void:
	length = ProjectSettings.get_setting("shader_globals/partitionlength").value
	length *= 4
	var lod_step = ProjectSettings.get_setting("shader_globals/lodstep").value
	createGrassMultimesh()
	recalculateGrassMultimesh()

func _physics_process(_delta: float) -> void:
	player_rounded_position = (player.global_position.snapped(Vector3.ONE * length/4.0) - Vector3.ONE * length/2.0) * Vector3(1,0,1)
	if global_position != player_rounded_position:
		global_position = player_rounded_position
		#recalculateGrassMultimesh()

func createGrassMultimesh() -> void:
	multimesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.mesh = createGrassMesh()
	multimesh.instance_count = Num_Grass * Num_Grass
	
func recalculateGrassMultimesh():
	for i in range(multimesh.instance_count):
		var position = Transform3D()
		var scalingFactor : float = float(length) / float(Num_Grass)
		var x = float(i / Num_Grass) * scalingFactor + rng.randf_range(-0.2, 0.2)
		var z = float(i % Num_Grass) * scalingFactor + rng.randf_range(-0.2, 0.2)
		var y = 0.0 #Heightmap.get_height(x + global_position.x, z + global_position.z)
		position.basis = Basis.from_euler(Vector3(0, rng.randf_range(0, 2 * PI), 0))
		position = position.translated(Vector3(x, y, z))
		multimesh.set_instance_transform(i, position)

func createGrassMesh() -> ArrayMesh:
	var mesh = ArrayMesh.new()
	var vertices := PackedVector3Array([])
	var indices := PackedInt32Array([])
	vertices.append_array(createGrassBlade())
	indices.append_array(createGrassFaces(vertices.size()))
	
	var array = []
	array.resize(Mesh.ARRAY_MAX)
	array[Mesh.ARRAY_VERTEX] = vertices
	array[Mesh.ARRAY_INDEX] = indices
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, array)
	return mesh;

func createGrassBlade() -> PackedVector3Array:
	return PackedVector3Array([
		Vector3(Grass_Width,0,0),
		Vector3(-1 * Grass_Width,0,0),
		Vector3(0,Grass_Height,0)
	])

func createGrassFaces(vertices_size: int) -> PackedInt32Array:
	return PackedInt32Array([
		vertices_size - 3,
		vertices_size - 2,
		vertices_size - 1])
