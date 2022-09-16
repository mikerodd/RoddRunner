extends Node2D
class_name RoddRunnerLevel

export var dumb_foes : bool = false




var ai_foe = preload("res://components/AIFoeComponent.tscn")
var dumb_foe = preload("res://components/BaseComponent.tscn")


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
signal player_dead

var frame = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	if (get_tree().current_scene == self):
		#debug mode of a level, create a keyboard component and pass it
		var key = preload("res://components/KeyboardInputComponent.tscn")
		var myinstance = key.instance()
		initialize(myinstance)
		start_level()





func initialize(play_component):
	
		
	add_child(play_component)
	play_component.initialize($TileMap)
	$Player.initialize_player($TileMap, play_component, get_parent())

	var ai_foe_instance 
	if  dumb_foes:
		ai_foe_instance = dumb_foe.instance()
	else:
		ai_foe_instance = ai_foe.instance()
		ai_foe_instance.initialize($Player,$TileMap)
	add_child(ai_foe_instance)
	get_tree().call_group("foes", "initialize",$TileMap,ai_foe_instance)
	if connect("player_dead",get_parent(),"player_dead") != OK:
		print("Error in connect player_dead")
	

func start_level():
	$Player.lets_go()
	get_tree().call_group("foes", "lets_go")


func stop_level(is_player_dead = false):
	$Player.lets_stop()
	get_tree().call_group("foes", "lets_stop")
	if is_player_dead:
		emit_signal("player_dead")
	

func _on_level_won():
	get_tree().call_group("foes", "lets_stop")
	
	
