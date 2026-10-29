class_name NPCMetadata
extends Node

@onready var profile: TextureRect = $"../Id_template/Users/Profile"
@onready var details: Label = $"../Id_template/Users/Details"

@export var profiles: Array[NPCProfile] = []

var current_profile: NPCProfile = null


func _ready() -> void:
	generate_random_profile()


func generate_random_profile() -> void:

	if profiles.is_empty():
		push_warning("No NPC profiles assigned!")
		return

	# Pick one complete profile
	current_profile = profiles.pick_random()

	if current_profile == null:
		push_error("Random NPC profile is NULL!")
		return

	'''print("NPC GENERATED")
	print("Name: ", current_profile.Name)
	print("Emp No: ", current_profile.EmpNo)
	print("Monster: ", current_profile.is_monster)'''

	# Set profile picture
	if current_profile.profile_picture:
		profile.texture = current_profile.profile_picture

	# Set ID details
	details.text = (
		"Name: " + current_profile.Name + "\n" +
		"Designation: " + current_profile.Designation + "\n" +
		"Depot: " + current_profile.Depot + "\n" +
		"Route No: " + str(current_profile.RouteNo) + "\n" +
		"Emp No: " + str(current_profile.EmpNo) + "\n" +
		"Date of Joining: " + str(current_profile.DateOfJoining) + "\n" +
		"Date of Birth: " + str(current_profile.DateOfBirth) + "\n" +
		"Blood Group: " + current_profile.BloodGroup + "\n" +
		"Monthly Salary: ₹" + str(current_profile.MonthlySalary)
	)
