extends Control

@onready var name_label: Label = %NameLabel
@onready var designation_label: Label = %DesignationLabel
@onready var depot_label: Label = %DepotLabel
@onready var route_no_label: Label = %RouteNoLabel
@onready var emp_no_label: Label = %EmpNoLabel
@onready var date_of_joining_label: Label = %DateOfJoiningLabel
@onready var date_of_birth_label: Label = %DateOfBirthLabel
@onready var blood_group_label: Label = %BloodGroupLabel
@onready var monthly_salary_label: Label = %MonthlySalaryLabel

@onready var profile_picture: TextureRect = %ProfilePicture
@onready var authority_sign: TextureRect = %AuthoritySign

func show_profile(profile: NPCProfile) -> void:
	name_label.text = profile.Name
	designation_label.text = profile.Designation
	depot_label.text = profile.Depot
	route_no_label.text = str(profile.RouteNo)
	emp_no_label.text = str(profile.EmpNo)
	date_of_joining_label.text = str(profile.DateOfJoining)
	date_of_birth_label.text = str(profile.DateOfBirth)
	blood_group_label.text = profile.BloodGroup
	monthly_salary_label.text = "₹" + str(profile.MonthlySalary)
	profile_picture.texture = profile.profile_picture
