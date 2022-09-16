extends Node2D

var current_level_template 
var level_instance : RoddRunnerLevel

export var level : int = 1
var score = 0
var women = 5
var is_demo_mode = true




var player_keyboard = preload("res://components/KeyboardInputComponent.tscn")
var player_scripted = preload("res://components/ScriptedPlayerComponent.tscn")

var instructions1 = ["right",Vector2(23,14), "still", Vector2(0,0), "fire", Vector2(0,0), \
					"waitfoe",Vector2(25,15), "right", Vector2(26,14),"up", Vector2(27,12), \
					"left", Vector2(20,12)  , "up", Vector2(20,6), "left",Vector2(14,6), \
					"up", Vector2(14,3),"left",Vector2(11,3),"down",Vector2(11,9) ,\
					"left",Vector2(9,9)]

var instructions2 = ["right",Vector2(15,16), "left", Vector2(14,16), "still", Vector2(0,0), \
					"fire", Vector2(0,0), "waitfoe",Vector2(13,17), "left", Vector2(12,16), \
					"up", Vector2(12,13), "left", Vector2(8,13),  "still", Vector2(0,0), \
					"fire", Vector2(0,0), "waitfoe",Vector2(7,14), "left", Vector2(4,13), \
					"up", Vector2(4,10), "left", Vector2(0,10), "still",Vector2(0,0), \
					"right",Vector2(1,10), \
					 "up", Vector2(2,7),"left", Vector2(0,7), "right",Vector2(2,7), \
					 "still",Vector2(0,0), "down", Vector2(2,10), "left", Vector2(0,10), \
					 "still",Vector2(0,0), "down", Vector2(0,16), "right", Vector2(20,16), "still",Vector2(0,0), \
					]

var instructions = [instructions1, instructions2]



# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	set_physics_process(false)
	start_demo_level()	
	


func start_demo_level():
	var rng = RandomNumberGenerator.new()
	var rand_level = 1 #rng.randi_range(1,2)
	is_demo_mode = true
	display_message("RODD RUNNER",true)
	
	current_level_template = load("res://levels/Level" + String(rand_level) +".tscn")
	level_instance = current_level_template.instance()
	add_child(level_instance)
	var play_component = player_scripted.instance()
	play_component.instructions = instructions[rand_level - 1]
	level_instance.initialize(play_component)
	move_child($HUD, 3)
	level_instance.start_level()

func start_current_level():
	is_demo_mode = false
	display_message("Level " + String(level))
	current_level_template = load("res://levels/Level" + String(level) + ".tscn")
	level_instance = current_level_template.instance()
	add_child(level_instance)
	var play_component = player_keyboard.instance()
	level_instance.initialize(play_component)
	move_child($HUD, 3)
	$InfoPanel.update(score,women, level)
	yield(get_tree().create_timer(3.0), "timeout")
	level_instance.start_level()

func player_dead():
	yield(get_tree().create_timer(4.0), "timeout")
	women -= 1
	if women == 0:
		game_over()
	else:
		level_instance.free()
		if is_demo_mode:
			start_demo_level()
		else:
			start_current_level()
	
func switch_to_level(_l):
	level = _l
	if level_instance != null:
		level_instance.free()
	start_current_level()
	

func display_message(var message, persistent = false):
	$HUD/Message.text = message
	$HUD/Message.visible = true
	if not persistent:
		yield(get_tree().create_timer(3.0), "timeout")
		$HUD/Message.visible = false
		$HUD/Fullscreen.visible = false
		
	

func player_won_points(var reason: String):
	
	if is_demo_mode:
		return 
		
	if reason == "treasure":
		score += 250
	elif reason == "level_won":
		score += 500
		level_instance.stop_level(false)
		display_message("Level Won !")
		yield(get_tree().create_timer(2.0), "timeout")
		switch_to_level(level + 1)
	$InfoPanel.update(score,women, level)
	
		


func _on_Button_pressed():
	is_demo_mode = false
	$HUD/Start.visible = false
	$HUD/Fullscreen.visible = false
	level_instance.queue_free()
	women = 5
	start_current_level()


func _on_Fullscreen_pressed():
		OS.window_fullscreen = !OS.window_fullscreen


func game_over():
	display_message("game over")
	yield(get_tree().create_timer(3.0), "timeout")
	is_demo_mode = true
	$HUD/Start.visible = true
	$HUD/Fullscreen.visible = true
	
	if level_instance != null:
		level_instance.queue_free()
	level = 1
	start_demo_level()
