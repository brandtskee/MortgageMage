extends CharacterBody2D
signal textbox_closed

@export var move_speed: float = 100
@export var starting_direction: Vector2 = Vector2(0, 1)

# parameters/Idle/blend_position

# get reference to animation tree from scence
@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")

func _ready():
	update_animation_parameters(starting_direction)
	$Textbox.hide()
	
func display_text(text):
	$Textbox.show()
	$Textbox/Label.text = text
	
func _input(event):
	if (Input.is_action_just_pressed("ui_accept") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)) and $Textbox.visible:
		$Textbox.hide()
		$UIsound.play()
		emit_signal("textbox_closed")

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

# Transitions: there's almost certainly a better way to do transitions,
# but this is just for demonstration

# Go downstairs to main floor
func _on_area_2d_area_entered(area):
	# if player collides with area2d, change scene to main floor
	get_tree().change_scene_to_file("res://scenes/mainOutside.tscn")

# Go back upstairs from to main scene
func _on_main_floor_upstairs_area_entered(area):
	get_tree().change_scene_to_file("res://scenes/mainScene.tscn")

# Go outside from main floor
func _on_main_floor_outside_area_entered(area):
	get_tree().change_scene_to_file("res://scenes/mainOutside.tscn")

# Go inside apartment to main floor
func _on_apartment_door_area_entered(area):
	# if player collides with apartment door in mainOutside, change to room scene
	get_tree().change_scene_to_file("res://scenes/mainScene.tscn")

# Start shark boss - add some dialogue before transitioning to fight
func _on_shark_boss_area_entered(area):
	# if player collides with area2d in mainOutside, change scene to shark fight
	# disable movement and set idle animation before battle starts
	
	# logic if previous battle is WON
	if State.loan_shark_battle == 1:
		set_physics_process(false)
		display_text("'You know what?\nForget about the debt..'")
		await textbox_closed
		set_physics_process(true)
		State.loan_shark_battle = 2
	
	# logic if battle has not occurred yet
	if State.loan_shark_battle == 0:
		MusicController.stop()
		set_physics_process(false)
		state_machine.travel("Idle", false)
		print("Entered")
		display_text("'You think you can show your face\naround here?'")
		await textbox_closed
		display_text("'You owe me four thousand dollars in\ninterest fees!'")
		await textbox_closed
		display_text("The loanshark appears to be preparing\nto fight...")
		await textbox_closed
		await get_tree().create_timer(0.5).timeout
		State.previous_scene.pack(get_tree().get_current_scene())
		MusicController.play_battle()
		get_tree().change_scene_to_file("res://scenes/battle.tscn")
		# How do we get it so area2d is disabled after boss dies?
		get_node("CollisionShape2D").disabled = true

func _on_goblin_boss_area_entered(area):
	# if player collides with area2d in mainDesert, change scene to goblin fight
	# disable movement and set idle animation before battle starts
	
	# logic if previous battle is WON
	if State.goblin_battle == 1:
		set_physics_process(false)
		display_text("'Kids these days.\nNo respect for their elders...'")
		await textbox_closed
		set_physics_process(true)
		State.goblin_battle = 2
	
	# logic if battle has not occurred yet
	if State.goblin_battle == 0:
		MusicController.stop()
		set_physics_process(false)
		state_machine.travel("Idle", false)
		print("Entered")
		display_text("'Hey, punk. You looking for trouble?\n'Cause I'm trouble.'")
		await textbox_closed
		display_text("'I don't got time for you.\nI'll make this quick.'")
		await textbox_closed
		await get_tree().create_timer(0.5).timeout
		State.previous_scene.pack(get_tree().get_current_scene())
		MusicController.play_battle()
		get_tree().change_scene_to_file("res://scenes/battleGoblin.tscn")
		get_node("CollisionShape2D").disabled = true

func _on_desert_area_entered(area):
	# Change to desert scene
	get_tree().change_scene_to_file("res://scenes/mainDesert.tscn")
		
func set_health(progress_bar, health, max_health):
	progress_bar.value = health
	progress_bar.max_value = max_health
	progress_bar.get_node("Label").text = "HP: %d/%d" % [health, max_health]

func _on_desert_to_outside_area_entered(area):
	get_tree().change_scene_to_file("res://scenes/mainOutside.tscn")

func _on_tutorial_area_area_entered(area):
	if State.tutorial_passed == 0:
		MusicController.play_background()
		set_physics_process(false)
		display_text("*Yawn* (I don't wanna go to work...)")
		await textbox_closed
		display_text("PRESS WASD KEYS TO MOVE")
		await textbox_closed
		set_physics_process(true)
		State.tutorial_passed = 1

