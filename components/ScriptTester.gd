extends Node2D

var instructions1 = ["right",Vector2(23,16), "still", Vector2(0,0), "fire", Vector2(0,0), \
					"waitfoe",Vector2(25,17), "right", Vector2(26,16),"up", Vector2(27,14), \
					"left", Vector2(20,14)  , "up", Vector2(20,8), "left",Vector2(14,8), \
					"up", Vector2(14,5),"left",Vector2(11,5),"down",Vector2(11,11) ,\
					"left",Vector2(9,11)]

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
var inst_count = 0
var current_level_template 
var level_instance : RoddRunnerLevel

var player_scripted = preload("res://components/ScriptedPlayerComponent.tscn")
var test_level = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	current_level_template = load("res://levels/Level" + String(test_level) + ".tscn")
	level_instance = current_level_template.instance()
	add_child(level_instance)
	var play_component = player_scripted.instance()
	play_component.instructions = instructions[test_level - 1]
	level_instance.initialize(play_component)
	level_instance.start_level()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
