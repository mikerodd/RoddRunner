
extends "res://components/BaseComponent.gd"

func update (var actor):
	if Input.is_action_pressed("ui_down"):
		actor.next_action =  actor.action.down
		return

	if Input.is_action_pressed("ui_up"):
		actor.next_action =  actor.action.up
		return
		
	if Input.is_action_pressed("ui_left"):
		actor.next_action =  actor.action.left
		return
		
	if Input.is_action_pressed("ui_right"):
		actor.next_action =  actor.action.right
		return

	if Input.is_action_just_pressed("ui_accept"):
		actor.next_action =  actor.action.fire
		return


	actor.next_action =  actor.action.still
	

func initialize(_t):
	pass
