extends Node

var background_music = load("res://assets/audio/backgroundMUSIC.mp3")
var battle_music = load("res://assets/audio/battleMUSIC.mp3")

func play_background():
	$Music.stream = background_music
	$Music.volume_db = -15
	$Music.play()
	
func play_battle():
	$Music.stream = battle_music
	$Music.volume_db = -15
	$Music.play()

func stop():
	$Music.stop()

