extends "res://components/BaseComponent.gd"


var instructions = ["right",Vector2(23,16), "still", Vector2(0,0), "fire", Vector2(0,0), \
					"waitfoe",Vector2(25,17), "right", Vector2(26,16),"up", Vector2(27,14), \
					"left", Vector2(20,14), "up", Vector2(20,8)]

var inst_count = 0
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var my_tilemap : RoddRunnerTilemap

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func initialize(_t):
	my_tilemap = _t



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func update (var _actor):
	var player := _actor as Player
	var c = inst_count
	var target_pos
	var move 

	if inst_count >= instructions.size():
		player.next_action = player.action.still
		return 
		
	move = instructions[c]
	target_pos = instructions[c + 1]
	
	if target_pos == player.current_pos:
		inst_count += 2
	else:
		if move == "left":
			player.next_action = player.action.left
		elif move == "right":
			player.next_action = player.action.right
		elif move == "up":
			player.next_action = player.action.up
		elif move == "down":
			player.next_action = player.action.down
		elif move == "still":
			player.next_action = player.action.still
			if player.is_between_tiles == player.between.NONE:
				inst_count += 2
		elif move == "waitfoe":
			player.next_action = player.action.still
			if my_tilemap.is_trapped_foe(target_pos):
				inst_count += 2
		elif move == "fire":
			player.next_action = player.action.fire
			inst_count += 2
		else:
			player.next_action = player.action.still
	
