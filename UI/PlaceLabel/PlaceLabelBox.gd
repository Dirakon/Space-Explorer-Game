extends Control

export var fade_time = 1
export var show_time = 1

func show_label(new_label:String):
	if $Label.text == new_label:
		return
	$Label.text=new_label
	$Tween.interpolate_property( 
		$Label, "modulate:a",    
		0, 1,   
		fade_time,                  
		Tween.TRANS_BACK, Tween.EASE_OUT          
	)
	$Tween.start()
	yield($Tween,"tween_completed")
	yield(get_tree().create_timer(show_time), "timeout")
	if not new_label == $Label.text:
		return
	$Tween.interpolate_property( 
		$Label, "modulate:a",    
		1, 0,   
		fade_time,                  
		Tween.TRANS_BACK, Tween.EASE_OUT          
	)
	$Tween.start()
	yield($Tween,"tween_completed")
	if not new_label == $Label.text:
		return
	$Label.text = ""
		


func _ready():
	Global.place_label = self
