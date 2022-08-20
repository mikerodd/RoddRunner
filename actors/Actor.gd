extends Area2D


class_name Actor

var base_speed = 170
const VELO_RATIO = 2.7143

var game_is_on = false

var velocity = Vector2.ZERO

var can_climb_destroyed = false

var tile_size_x
var tile_size_y

var _tilemap : RoddRunnerTilemap
var _input

enum between {NONE, X, Y  }
var is_between_tiles = between.NONE

# actions and relative vectors
enum action {left, right, up, down, still, fire, fall}
var rel_vectors = {0:Vector2(-1,0), 1:Vector2(1, 0), 2:Vector2(0,-1), 3:Vector2(0,1),4:Vector2(0,0),5:Vector2(0,0), 6:Vector2(0,1) }
var vect_shift  = {0:Vector2(1,0), 1:Vector2(0,0), 2:Vector2(0,0), 3:Vector2(0,0), 4:Vector2(0,0), 5:Vector2(0,0), 6:Vector2(0,0)}
enum facing {left, right, up, down, rope}
var what_facing = facing.left


var current_pos = Vector2.ZERO
var ongoing_pos = Vector2.ZERO
var next_obstacle_pos = Vector2.ZERO

var ongoing_move = action.still
var next_action = action.still

var my_delta 


func lets_go():
	game_is_on = true
	
func lets_stop():
	$Anims.stop()
	game_is_on = false


func initialize(var _tm,var _in):
	_tilemap = _tm
	_input = _in
	$Anims.get_sprite_frames().set_animation_speed("run_left", base_speed / VELO_RATIO)

	tile_size_x = $Anims.get_sprite_frames().get_frame("run_left",0).get_width()
	tile_size_y = $Anims.get_sprite_frames().get_frame("run_left",0).get_height()
	tile_size_x = _tilemap.get_cell_size().x
	tile_size_y = _tilemap.get_cell_size().y
	
	ongoing_pos = _tilemap.world_to_map(position)
	current_pos = ongoing_pos
	next_obstacle_pos = ongoing_pos


func get_rel_vector(move): 
	return rel_vectors[move]
	



func _process(delta):
	if not game_is_on:
		return 
			
	current_pos = _tilemap.world_to_map(position)
	ongoing_pos = _tilemap.world_to_map(position + get_rel_vector(ongoing_move) * base_speed * delta)
	my_delta = delta
	_input.update(self) # next_action updated
	manage_moves(delta, next_action)
	position += velocity * delta
	current_pos = _tilemap.world_to_map(position)

	var _test = velocity * delta 
#	print ("actor : %s, delta : %f velocity * delta :(%f, %f) " % [name, delta, _test.x, _test.y ])
	
	

func manage_fall2(_delta, _act):
	
	var test_pos
	var new_og = _tilemap.world_to_map(position + velocity * _delta)
	var pre_og = _tilemap.world_to_map(position + velocity * _delta + \
										Vector2(tile_size_x - 1,0))
	
	if (current_pos - new_og).x >= 0:
		test_pos = not _tilemap.is_tile_under_me_floor(current_pos) and\
				not _tilemap.is_tile_under_me_floor(pre_og)
	elif (current_pos - new_og).x < 0:
		test_pos =  not _tilemap.is_tile_under_me_floor(new_og)
	else: 
		test_pos =  not _tilemap.is_tile_under_me_floor(current_pos)
		
	if test_pos and \
		not _tilemap.is_tile_rope(ongoing_pos) and \
		not _tilemap.is_tile_ladder(ongoing_pos):
		immobilize_me()
		velocity = rel_vectors[action.fall] * base_speed 
		$Anims.play_fall()
		ongoing_move = action.fall


func manage_stop_falling(_delta, _act):
	if ongoing_move == action.fall:
		if _tilemap.is_tile_under_me_floor(ongoing_pos):
			immobilize_me()
			ongoing_move = action.still
			what_facing = facing.left
			
		if _tilemap.is_tile_rope(ongoing_pos):
			immobilize_me()
			ongoing_move = action.still
			what_facing = facing.rope
			
		return true
	return false
	

func manage_still(_delta, _act):
	if _act == action.still:
		immobilize_me()
	return false


func test_other_causes(_pos):
	return true 
	
	
func manage_leftright(_delta, _act):
	if _act in [action.left,action.right]:
		if  not _tilemap.is_tile_solid(next_obstacle_pos) and test_other_causes(next_obstacle_pos):
			velocity = rel_vectors[_act] * base_speed
			is_between_tiles = between.X
			ongoing_move = _act
			if  _tilemap.is_tile_rope(next_obstacle_pos):
				what_facing = facing.rope
				$Anims.play_use_rope()
			elif _act == action.left:
				what_facing = facing.left
				$Anims.play_run_left()
			else:
				what_facing = facing.right
				$Anims.play_run_right()
		else:
			if _act == action.left:
				immobilize_me()
			elif _act == action.right:
				immobilize_me(true)
	return false	
	
func manage_updown(_delta, _act):
	if _act in [action.up,action.down]:
		if  (_tilemap.is_tile_climbable(next_obstacle_pos, can_climb_destroyed) or \
			 _tilemap.is_tile_rope(next_obstacle_pos)) \
			and test_other_causes(next_obstacle_pos):
			velocity = rel_vectors[_act]  * base_speed
			is_between_tiles = between.Y
			what_facing = facing.up
			ongoing_move = _act
			if _act == action.up:
				what_facing = facing.up
				$Anims.play_climb_up()
			else:
				what_facing = facing.down
				$Anims.play_climb_down()
		elif _act == action.down and not _tilemap.is_tile_under_me_floor(current_pos):
			immobilize_me()
			velocity = rel_vectors[action.fall] * base_speed 
			$Anims.play_fall()
			ongoing_move = action.fall
		else:
			if _act == action.up:
				immobilize_me()
			elif _act == action.down:
				immobilize_me(true)
	return false	

func am_i_crushed():
	return (_tilemap.is_tile_rebuilt(current_pos))
	

func crushed():
	pass # treated by descendants

func log_me(_prefix):
	pass
#		print ("%s actor : %s  position: (%f,%f), velocity (%f,%f) next_obstacle: (%f,%f)" % [_prefix, name,  position.x,position.y, velocity.x, velocity.y, next_obstacle_pos.x, next_obstacle_pos.y])
	

func manage_moves(delta, _act):
	
	
	if am_i_crushed():
		crushed()

	if manage_stop_falling(delta, _act):
		return 

	var ahead = 1 
	if is_between_tiles == between.X and not _act in [action.left, action.right, action.still]:
		if (current_pos != ongoing_pos):
			manage_moves(delta, action.still)
		else:
			#return 
			_act = ongoing_move
	elif is_between_tiles == between.Y and not _act in [action.up, action.down, action.still]:
		if (current_pos != ongoing_pos):
			manage_moves(delta, action.still)
		else:
			#return
			_act = ongoing_move
			
	if is_between_tiles == between.Y and _act == action.down and \
		 current_pos != ongoing_pos:
			ahead = 2 
	elif is_between_tiles == between.X and _act == action.right and \
		 current_pos != ongoing_pos:
			ahead = 2 
			
	next_obstacle_pos  = _tilemap.world_to_map(position + rel_vectors[_act] * ahead * tile_size_x)

	if manage_still(delta, _act):
		return 

	if manage_leftright(delta, _act):
		return
 
	if manage_updown(delta, _act):
		return

	manage_fall2(delta, _act)

func immobilize_me(shift = false):
	if name == "Foe" and ongoing_pos == Vector2(7,11):
		pass 
	
	if velocity.x != 0:
		if _tilemap.world_to_map(position).x != ongoing_pos.x or shift:
			if velocity.x < 0:
				position.x = (ongoing_pos.x  + 1)  * tile_size_x
				if what_facing == facing.rope:
					$Anims.play_still_rope()
				else:
					what_facing = facing.left
					$Anims.play_still_left()
				velocity = Vector2.ZERO
			else:
				position.x = (ongoing_pos.x)  * tile_size_x
				if what_facing == facing.rope:
					$Anims.play_still_rope()
				else:
					what_facing = facing.right
					$Anims.play_still_right()
				velocity = Vector2.ZERO

			is_between_tiles = between.NONE
			ongoing_move = action.still

	elif velocity.y != 0:
		if _tilemap.world_to_map(position).y != ongoing_pos.y or shift:
			position.y = (ongoing_pos.y  + (1 if velocity.y < 0 else 0 )) * tile_size_y
			what_facing = facing.up
			is_between_tiles = between.NONE
			velocity = Vector2.ZERO
			$Anims.play_still_ladder()
	else:
		if what_facing == facing.left:
			$Anims.play_still_left()
		elif what_facing == facing.right:
			$Anims.play_still_right()
		elif what_facing == facing.rope:
			$Anims.play_still_rope()
		else:
			$Anims.play_still_ladder()
			
