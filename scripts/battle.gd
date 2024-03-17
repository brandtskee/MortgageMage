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
	$ActionsPanel/HBoxContainer/Run.hide()
	$ActionsPanel/HBoxContainer/Run.show()
	await textbox_closed


func _on_attack_pressed():
	display_text("You attack and do a bit of damage!")
	$ActionsPanel/HBoxContainer/Attack.hide()
	$ActionsPanel/HBoxContainer/Attack.show()
	await textbox_closed
	# use max function to ensure health does not go below zero
	current_enemy_health = max(0, current_enemy_health - State.damage)
	set_health($EnemyContainer/ProgressBar, current_enemy_health, enemy.health)
