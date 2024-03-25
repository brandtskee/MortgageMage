extends Control
signal textbox_closed
@export var enemy: Resource = null

var current_player_health = 0
var current_enemy_health = 0
var is_defending = false

func _ready():
	
	$AnimationPlayer.play("shark_idle")
	
	set_health($EnemyContainer/ProgressBar, enemy.health, enemy.health)
	set_health($PlayerPanel/PlayerData/ProgressBar, State.current_health, State.max_health)
	$EnemyContainer/Enemy.texture = enemy.texture
	
	# load health into local variables
	current_player_health = State.current_health
	current_enemy_health = enemy.health
	
	$Textbox.hide()
	$ActionsPanel.hide()
	
	display_text("A %s challenges you to a battle!" % enemy.name)
	await textbox_closed
	$ActionsPanel.show()

# use this to play animations and use timeout to resume idle animations
func play_animation(animation, timer):
	$AnimationPlayer.play(animation)
	await "animation_finished"
	await get_tree().create_timer(timer).timeout
	$AnimationPlayer.play("shark_idle")
	

# use this function after displaying textbox to allow for pressing action button without
# accidentally selecting the previous action again
func deselect_actions():
	$ActionsPanel/HBoxContainer/Attack.hide()
	$ActionsPanel/HBoxContainer/Attack.show()
	
	$ActionsPanel/HBoxContainer/Defend.hide()
	$ActionsPanel/HBoxContainer/Defend.show()
	
	$ActionsPanel/HBoxContainer/Run.hide()
	$ActionsPanel/HBoxContainer/Run.show()

func set_health(progress_bar, health, max_health):
	progress_bar.value = health
	progress_bar.max_value = max_health
	progress_bar.get_node("Label").text = "HP: %d/%d" % [health, max_health]
	

func _input(event):
	if (Input.is_action_just_pressed("ui_accept") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)) and $Textbox.visible:
		$Textbox.hide()
		$UIsound.play()
		emit_signal("textbox_closed")

func display_text(text):
	$ActionsPanel.hide()
	$Textbox.show()
	$Textbox/Label.text = text


func _on_run_pressed():
	display_text("Can't flee this fight!")
	# rapidly hide and show button to defocus so that enter and space can be used
	deselect_actions()
	await textbox_closed
	$ActionsPanel.show()

func enemy_turn():
	display_text("%s attempts to extort you for more money!" % enemy.name)
	deselect_actions()
	await textbox_closed
	
	if is_defending == true:
		is_defending = false
		play_animation("mini_shake", 0.6)
		display_text("No damage taken!")
		await textbox_closed
	else:
		# use max function to ensure health does not go below zero
		current_player_health = max(0, current_player_health - enemy.damage)
		set_health($PlayerPanel/PlayerData/ProgressBar, current_player_health, State.max_health)
		play_animation("shake", 0.6)
		display_text("%s dealt %d damage!" % [enemy.name, enemy.damage])
		await textbox_closed
	$ActionsPanel.show()

func _on_attack_pressed():
	display_text("You attack and do a bit of damage!")
	deselect_actions()
	await textbox_closed
	# use max function to ensure health does not go below zero
	current_enemy_health = max(0, current_enemy_health - State.damage)
	set_health($EnemyContainer/ProgressBar, current_enemy_health, enemy.health)
	# play enemy damaged animation
	play_animation("enemy_damaged", 0.4)
	
	display_text("You did %s damage!" % State.damage)
	await textbox_closed
	
	# do not attack if enemy is defeated
	if current_enemy_health == 0:
		display_text("%s was defeated!" % enemy.name)
		State.current_health = current_player_health
		await textbox_closed
		$AnimationPlayer.play("enemy_defeated")
		await "animation_finished"
		
		await get_tree().create_timer(1).timeout
		
		# change to returning to previous scene
		State.loan_shark_battle = 1
		get_tree().change_scene_to_packed(State.previous_scene)
		
	else:	
		# execute enemy turn after your attack if enemy health greater than 0
		enemy_turn()


func _on_defend_pressed():
	is_defending = true
	display_text("You brace for impact!")
	deselect_actions()
	await textbox_closed
	await get_tree().create_timer(.25).timeout
	enemy_turn()
	
