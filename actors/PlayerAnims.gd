extends "res://actors/ActorAnims.gd"

class_name PlayerAnims



signal end_fire


func _on_Anims_animation_finished():
	if animation  == "fire_left":
		emit_signal("end_fire")

func play_fire_left():
	flip_h = false
	play("fire_left")

func play_fire_right():
	flip_h = true
	play("fire_left")
	
