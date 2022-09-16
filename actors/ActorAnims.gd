extends AnimatedSprite



func play_fall():
	play("fall")
	
func play_run_left():
	flip_h = false
	play("run_left")
	
func play_run_right():
	flip_h = true
	play("run_left")

func play_still_left():
	flip_h = false
	play(("stand_left"))
	
func play_still_right():
	flip_h = true
	play(("stand_left"))
	
func play_still_ladder():
	play("stand_climb")
	

func play_climb_up():
	play("climb")

func play_climb_down():
	play("climb",true)
	

func play_use_rope():
	play("rope")

func play_still_rope():
	play("stand_rope")
