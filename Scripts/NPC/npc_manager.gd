extends Node

@export var npc_scene: PackedScene
@export var bus_button: Node

@onready var npc_spawn_point: Marker3D = %NPCSpawnPoint


var current_npc = null


func _ready() -> void:
	if bus_button:
		null


func spawn_npc() -> void:
	if current_npc != null:
		return

	if npc_scene == null:
		print("NPC scene not assigned!")
		return

	current_npc = npc_scene.instantiate()

	add_child(current_npc)

	current_npc.global_position = npc_spawn_point.global_position

	current_npc.reached_bus.connect(_on_npc_reached_bus)

	print("NPC spawned")


func _on_button_pressed() -> void:
	if current_npc == null:
		return
	print("Inspection done")
	current_npc.mark_inspection_done()


func _on_npc_reached_bus() -> void:

	print("NPC reached bus")

	current_npc.queue_free()
	current_npc = null

	await get_tree().process_frame

	spawn_npc()
