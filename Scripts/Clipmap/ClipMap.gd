@tool
extends Node3D

var Partition = preload("res://Scenes/ClipMap/ClipMapPartition.tscn")
@export var distance:int
@export var grassDistance:int
@export var playerCharacter:Node3D

var length = ProjectSettings.get_setting("shader_globals/partitionlength").value

func _ready() -> void:

	for x in range(-distance, distance + 1):
		for z in range(-distance, distance + 1):
			var partition = Partition.instantiate()
			
			partition.x = x
			partition.z = z
			
			add_child(partition)

func _process(_delta: float) -> void:
	global_position = playerCharacter.global_position.snapped(Vector3.ONE * length) * Vector3(1,0,1)
	RenderingServer.global_shader_parameter_set("clipmapposition", global_position)
