extends Node3D

@export var Fillrate: float = 0.5 # Fuel per second
@export var MaxFuel: float = 100.0

var bus: VehicleBody3D
var is_refueling: bool = false


func _ready() -> void:
	bus = get_tree().get_first_node_in_group("Bus") as VehicleBody3D


func _process(delta: float) -> void:
	if not is_refueling:
		return
	if not is_instance_valid(bus):
		return
	bus.refuel(Fillrate, delta)


func _on_area_1_body_entered(body: Node3D) -> void:
	if body == bus:
		is_refueling = true
		print("Refueling started")
		print(bus.fuel)


func _on_area_1_body_exited(body: Node3D) -> void:
	if body == bus:
		is_refueling = false
		print("Refueling stopped")


func _on_area_2_body_entered(body: Node3D) -> void:
	if body == bus:
		is_refueling = true
		print("Refueling started")
		print(bus.fuel)


func _on_area_2_body_exited(body: Node3D) -> void:
	if body == bus:
		is_refueling = false
		print("Refueling stopped")
