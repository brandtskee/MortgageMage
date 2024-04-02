extends Node

var background_music = load("res://assets/audio/backgroundMUSIC.mp3")

func play_background():
	$Music.stream = background_music
	$Music.play()
