extends "res://components/BaseComponent.gd"

var waiting = true
var player 
var my_tilemap : RoddRunnerTilemap


enum direction {left, right, up, down}


func initialize(var _p, _t):
	player = _p
	my_tilemap = _t
	
	
	
func update (var actor : Actor):
	var foe := actor as Foe
	var player_pos : Vector2
	var _cp = foe.current_pos
	var _op = foe.ongoing_pos
	var _wp 
	var near_left
	var near_right
	
	
	
	if foe.next_action == foe.action.fall:
		return

		

	
	player_pos =  my_tilemap.world_to_map(player.position)
	if foe.current_pos == Vector2(4,16):
		pass
	
	if foe.ongoing_move == foe.action.left:
		_wp = foe.current_pos
	else:
		_wp = foe.ongoing_pos
	
	if player_pos.y > foe.current_pos.y:
		if my_tilemap.is_tile_upon_ladder(_wp) or \
			(my_tilemap.is_tile_ladder(_wp) and \
			my_tilemap.is_tile_ok_to_go_down(_wp)): 
			foe.next_action = foe.action.down
		elif (my_tilemap.is_tile_rope(_wp) and \
			not my_tilemap.is_tile_under_me_floor(_wp)):
			foe.next_action = foe.action.down
		else:
			near_left = search_ladder(foe.ongoing_pos, direction.left, direction.down)
			near_right = search_ladder(foe.ongoing_pos, direction.right, direction.down)
			if near_left < near_right:
				if foe.what_facing != foe.facing.right or near_left != 0:
					foe.next_action = foe.action.left	
			elif near_right != 200:
				if foe.what_facing != foe.facing.left or near_right != 0:
					foe.next_action = foe.action.right
			
	elif player_pos.y < foe.current_pos.y:
		if my_tilemap.is_tile_ladder(_wp) or \
		   my_tilemap.is_tile_ladder(foe.current_pos):
			foe.next_action = foe.action.up
		else:
			near_left = search_ladder(foe.ongoing_pos, direction.left, direction.up)
			near_right = search_ladder(foe.ongoing_pos, direction.right, direction.up)
			if near_left < near_right:
				if foe.what_facing != foe.facing.right or near_left != 0:
					foe.next_action = foe.action.left	
			elif near_right != 200:
				if foe.what_facing != foe.facing.left or near_right != 0:
					foe.next_action = foe.action.right
	
	elif player_pos.x > foe.current_pos.x:
		foe.next_action = foe.action.right
	else:
		foe.next_action = foe.action.left
		
		

func search_ladder(my_pos : Vector2, dir, updown): 
	if dir == direction.left:
		if updown == direction.up:
			for idx in range(my_pos.x, 0, -1):
				if my_tilemap.is_tile_ladder(Vector2(idx, my_pos.y)):
					return (my_pos.x - idx)
		else:
			for idx in range(my_pos.x, 0, -1):
				if my_tilemap.is_tile_upon_ladder(Vector2(idx, my_pos.y)):
					return (my_pos.x - idx)
		
	elif dir == direction.right:
		if updown == direction.up:
			for idx in range(my_pos.x, 28):
				if my_tilemap.is_tile_ladder(Vector2(idx, my_pos.y)):
					return (idx - my_pos.x)
		else:
			for idx in range(my_pos.x, 28):
				if my_tilemap.is_tile_upon_ladder(Vector2(idx, my_pos.y)):
					return (idx - my_pos.x)
			
	return 200
			
