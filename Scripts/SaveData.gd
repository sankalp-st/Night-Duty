extends Resource
class_name SaveDataResource

@export var player_position: Vector3 = Vector3.ZERO
@export var player_health: float = 100.0
@export var fuel: float = 100.0
@export var diamonds: int = 100

# Hotbar slots as ItemData resource paths ("" = empty slot)
@export var hotbar_items: Array[String] = ["", "", "", ""]

# Bought items still lying on the counter (parallel arrays)
@export var counter_items: Array[String] = []
@export var counter_positions: Array[Vector3] = []

# Keep this only for world pickups you want to mark as taken (e.g. notes)
@export var collected_items: Array[String] = []
