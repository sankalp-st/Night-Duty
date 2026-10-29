class_name NPC
extends CharacterBody3D

@onready var npc_state_machine: NPCStateMachine = $NPCStateMachine
@onready var move_state: NPCMoveState = $NPCStateMachine/movement
@onready var npc_meta_data: NPCMetadata = %NPCMetaData
@onready var mesh_holder: Node3D = %MeshHolder

signal reached_bus

@export var gravity: float = 20.0

var bus_reached: bool = false


func _ready() -> void:
	npc_meta_data.generate_random_profile()
	apply_npc_profile()


func _physics_process(delta: float) -> void:

	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	move_and_slide()


func mark_inspection_done() -> void:
	if move_state.inspection_done:
		return

	move_state.inspection_done = true
	move_state.set_target()

	# Make sure NPC is in movement state again
	npc_state_machine.on_child_transition("movement")

	if move_state.inspection_done and not bus_reached:
		if move_state.navigation_agent.is_navigation_finished():
			bus_reached = true
			reached_bus.emit()

func apply_npc_profile() -> void:
	var profile := npc_meta_data.current_profile
	if profile == null:
		return
	if profile.npc_mesh == null:
		return
	var npc_model = profile.npc_mesh.instantiate()
	mesh_holder.add_child(npc_model)
