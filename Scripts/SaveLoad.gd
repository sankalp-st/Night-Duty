extends Node

const save_location = "user://SaveFile.tres"

var SaveFileData : SaveDataResource = SaveDataResource.new()


func _ready() -> void:
	if ResourceLoader.exists(save_location):
		var loaded = ResourceLoader.load(save_location)
		if loaded is SaveDataResource:
			SaveFileData = loaded
			
func spend_diamonds(amount: int) -> bool:
	if SaveFileData.diamonds < amount:
		return false
	SaveFileData.diamonds -= amount
	return true
	

func _load():
	if FileAccess.file_exists(save_location):
		var data = ResourceLoader.load(save_location)
		
		if data is SaveDataResource:
			SaveFileData = data.duplicate(true)
	
func _save():
	var player := get_tree().get_first_node_in_group("player") as Node3D
	if player:
		SaveFileData.player_position = player.global_position

	# Hotbar
	for i in Inventory.HOTBAR_SIZE:
		var item: ItemData = Inventory.hotbar[i]
		SaveFileData.hotbar_items[i] = item.resource_path if item else ""

	# Uncollected counter items
	SaveFileData.counter_items.clear()
	SaveFileData.counter_positions.clear()
	for node in get_tree().get_nodes_in_group("counter_pickups"):
		SaveFileData.counter_items.append(node.item_data.resource_path)
		SaveFileData.counter_positions.append(node.global_position)

	ResourceSaver.save(SaveFileData, save_location)
	
func apply_to_world() -> void:
	var player := get_tree().get_first_node_in_group("player") as Node3D
	if player and SaveFileData.player_position != Vector3.ZERO:
		player.global_position = SaveFileData.player_position

	for i in Inventory.HOTBAR_SIZE:
		var path :String= SaveFileData.hotbar_items[i]
		Inventory.hotbar[i] = load(path) if path != "" else null
	Inventory.inventory_changed.emit()

	for i in SaveFileData.counter_items.size():
		var item_path: String = SaveFileData.counter_items[i]
		var pos: Vector3 = SaveFileData.counter_positions[i]
		Inventory.spawn_item_at(load(item_path), pos)
