extends CharacterBody2D

@export var move_speed: float = 100
@export var starting_direction: Vector2 = Vector2(0, 1)

# parameters/Idle/blend_position

# get reference to animation tree from scence
@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")

func _ready():
	update_animation_parameters(starting_direction)

func _physics_process(_delta):
	var input_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)
	
	update_animation_parameters(input_direction)
	
	# updated velocity
	velocity = input_direction*move_speed
	
	# move and slide (USE THIS FOR MOVEMENT!!) 
	move_and_slide()
	
	# pick new animation state
	pick_new_state()

func update_animation_parameters(move_input: Vector2):
	if (move_input != Vector2.ZERO):
		animation_tree.set("parameters/walk/blend_position", move_input)
		animation_tree.set("parameters/Idle/blend_position", move_input)

# choose animation state
func pick_new_state():
	if(velocity != Vector2.ZERO):
		state_machine.travel("walk", false)
	else:
		state_machine.travel("Idle", false)




func _on_area_2d_area_entered(area):
	# if player collides with area2d, change scene to main floor
	get_tree().change_scene_to_file("res://scenes/mainFloor.tscn")
