class_name NPCIdleState
extends State

@export var idle_time: float = 1.0

var timer: float = 0.0


func enter() -> void:
	timer = idle_time


func update(delta: float) -> void:
	timer -= delta
	if timer <= 0.0:
		transition.emit("movement")
