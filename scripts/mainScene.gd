extends Node2D


func _ready():
	set_health($PlayerPanel/PlayerData/ProgressBar, State.current_health, State.max_health)


func set_health(progress_bar, health, max_health):
	progress_bar.value = health
	progress_bar.max_value = max_health
	progress_bar.get_node("Label").text = "HP: %d/%d" % [health, max_health]
