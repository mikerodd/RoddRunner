extends "res://actors/Actor.gd"

class_name Foe
var label 

var deblock : bool = false
var is_trapped : bool = false
var has_treasure : bool = false
var rng = RandomNumberGenerator.new()
enum foe_action {left, right, up, down, still, fire, fall, blocked, outing1, outing2, outing3}

var foe_rel_vectors = {0:Vector2(-1,0), 1:Vector2(1, 0), 2:Vector2(0,-1), \
					   3:Vector2(0,1),  4:Vector2(0,0),  5:Vector2(0,0), \
					   6:Vector2(0,1), 7:Vector2(0,0), 8:Vector2(0, -1), \
					   9:Vector2(-1, 0), 10:Vector2(1, 0)}

func initialize(var _tm,var _in):
	$FoeLabel.text = name
	label = $FoeLabel.text
	base_speed *= 0.5
	rng.randomize()
	
	.initialize(_tm, _in)

	


func test_other_causes(_pos):
#	print("foe : %s, checking : (%d,%d) " % [name, _pos.x, _pos.y])
	
	for pal in  get_tree().get_nodes_in_group("foes"):
#		print("test foe : %s, current_pos : (%d,%d), position: (%f,%f)" % [pal.name, pal.current_pos.x, pal.current_pos.y, pal.position.x, pal.position.y])
		if (_pos == pal.current_pos and pal != self):
#			print("  => ovelap detection type 1")
			return false
			
		if _pos == pal.next_obstacle_pos and pal != self and not pal.is_trapped:
			if (next_obstacle_pos  == pal.next_obstacle_pos) and \
				pal.get_instance_id() < get_instance_id():
#				print("  => ovelap detection type 2")
				return false
			else:
#				print("  => everything's fine, the other guy will block")
				return true
#	print("  => everything's fine")
	return true
	

	

func get_rel_vector(move): 
	return foe_rel_vectors[move]	

func manage_fall2(_delta, _act):
	if _tilemap.is_tile_destroyed(current_pos):
		return false
	else:
		.manage_fall2(_delta, _act)

func crushed():
	var where = _tilemap. get_spawn_location()
	position.x = where.x * tile_size_x
	position.y = where.y * tile_size_y
	current_pos = where
	ongoing_pos = where
	
	

func manage_stop_falling(_delta, _act):
	if _tilemap.is_tile_destroyed(current_pos):
		if has_treasure:
			var tmp = Vector2(current_pos.x, current_pos.y -1)		
			_tilemap.release_treasure(tmp)
			has_treasure = false
		
		is_trapped = true
		ongoing_move = foe_action.blocked
		immobilize_me(true)
		$BlockedTimer.start()
		$Anims.play_still_ladder()
		_tilemap.add_trapped_foe(current_pos)
		return true

	return .manage_stop_falling(_delta, _act)

	
func manage_moves(delta, _act):

	#log_me("begin")



	if _tilemap.is_tile_contains_treasure(current_pos) and not has_treasure:
		if rng.randi_range(1, 1000) == 150:
			if _tilemap.get_treasure(current_pos):
				has_treasure = true


	if deblock:
		deblock = false
		ongoing_move = foe_action.outing1
		next_obstacle_pos = ongoing_pos - Vector2(0,2)
		_tilemap.remove_trapped_foe(ongoing_pos)

	if ongoing_move == foe_action.outing1:
		if next_obstacle_pos == ongoing_pos:
			immobilize_me()
			_input.update(self) # next_action updated
			if next_action == foe_action.left:
				next_obstacle_pos = ongoing_pos + Vector2(-2, 1)
				ongoing_move = foe_action.outing2
			else:
				next_obstacle_pos = ongoing_pos + Vector2(1, 1)
				ongoing_move = foe_action.outing3
		else:
			$Anims.play_climb_up()
			velocity = rel_vectors[foe_action.up]  * base_speed
			is_between_tiles = between.Y
			what_facing = facing.up
		return 

	if ongoing_move == foe_action.outing2:
		if next_obstacle_pos == ongoing_pos:
			immobilize_me()
			ongoing_move = foe_action.still
		else:		
			$Anims.play_run_left()
			velocity = rel_vectors[foe_action.left]  * base_speed
			what_facing = facing.left
			is_between_tiles = between.X
		return 

	if ongoing_move == foe_action.outing3:
		if next_obstacle_pos == ongoing_pos:
			immobilize_me()
			ongoing_move = foe_action.still
		else:		
			$Anims.play_run_right()
			velocity = rel_vectors[foe_action.right]  * base_speed
			what_facing = facing.right
			is_between_tiles = between.X
		return 
#



	if ongoing_move == foe_action.blocked:
		return 

	.manage_moves(delta, _act)	
	
	log_me("end")
	

func _on_BlockedTimer_timeout():
	deblock =true 
