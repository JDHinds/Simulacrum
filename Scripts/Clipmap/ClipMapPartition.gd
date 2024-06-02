@tool
extends MeshInstance3D

var x
var z
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var length = ProjectSettings.get_setting("shader_globals/partitionlength").value
	var lod_step = ProjectSettings.get_setting("shader_globals/lodstep").value
	var height = ProjectSettings.get_setting("shader_globals/worldamplitude").value
	
	mesh = PlaneMesh.new()
	mesh.size = Vector2.ONE * length
	position = Vector3(x,0,z) * length
	
	var lod = max(abs(x), abs(z)) * lod_step
	var subdivision_length = pow(2, lod)
	var subdivides = max(mesh.size.x/subdivision_length - 1, 0)
	mesh.subdivide_width = subdivides
	mesh.subdivide_depth = subdivides
	
	mesh.custom_aabb.size.y = height

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
