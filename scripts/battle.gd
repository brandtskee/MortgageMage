extends Control
signal textbox_closed
@export var enemy: Resource = null

var current_player_health = 0
var current_enemy_health = 0

func _ready():
	
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
		emit_signal("textbox_closed")

func display_text(text):
	$Textbox.show()
	$Textbox/Label.text = text


func _on_run_pressed():
	display_text("Can't flee this fight!")
	# rapidly hide and show button to defocus so that enter and space can be used
	deselect_actions()
	await textbox_closed

func enemy_turn():
	display_text("%s attempts to extort you for more money!" % enemy.name)
	deselect_actions()
	await textbox_closed
	# use max function to ensure health does not go below zero
	current_player_health = max(0, current_player_health - enemy.damage)
	set_health($PlayerPanel/PlayerData/ProgressBar, current_player_health, State.max_health)
	$AnimationPlayer.play("shake")
	display_text("%s dealt %d damage!" % [enemy.name, enemy.damage])
	await textbox_closed

func _on_attack_pressed():
	display_text("You attack and do a bit of damage!")
	deselect_actions()
	await textbox_closed
	# use max function to ensure health does not go below zero
	current_enemy_health = max(0, current_enemy_health - State.damage)
	set_health($EnemyContainer/ProgressBar, current_enemy_health, enemy.health)
	# play enemy damaged animation
	$AnimationPlayer.play("enemy_damaged")
	await "animation_finished"
	
	display_text("You did %s damage!" % State.damage)
	await textbox_closed
	
	# execute enemy turn after your attack
	enemy_turn()
