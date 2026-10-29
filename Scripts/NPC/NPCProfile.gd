class_name NPCProfile
extends Resource

@export_category("Identity")

@export var Name: String
@export var Designation: String
@export var Depot: String
@export var RouteNo: int
@export var EmpNo: int
@export var DateOfJoining: int
@export var DateOfBirth: int
@export var BloodGroup: String
@export var MonthlySalary: int
@export var AuthoritySign : bool

@export_category("Type")

@export var is_monster: bool = false

@export_category("Appearance")

@export var npc_mesh: PackedScene
@export var profile_picture: Texture2D
