extends ColorRect

class_name ScreenFlasher

signal finished()

var flashing_time = 0.25
var show_time = 0.25
var end_modulate = 1

func _ready():
	Global.screen_flasher = self
	pass 

func flash_coroutine():
	$Tween.interpolate_property( 
		$".", "modulate:a",    
		0, end_modulate,   
		flashing_time,                  
		Tween.TRANS_BACK, Tween.EASE_OUT          
	)
	$Tween.start()
	$AudioStreamPlayer.play()
	yield($Tween,"tween_completed")
	yield(get_tree().create_timer(show_time), "timeout")
	$Tween.interpolate_property( 
		$".", "modulate:a",    
		end_modulate, 0,   
		flashing_time,                  
		Tween.TRANS_BACK, Tween.EASE_OUT          
	)
	$Tween.start()
	yield($Tween,"tween_completed")
	emit_signal("finished")
	
	

func flash():
	flash_coroutine()
	return self
	
