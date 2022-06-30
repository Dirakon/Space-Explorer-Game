extends Area2D


export(String, MULTILINE) var text:String

func _on_LabelShowTrigger_body_entered(body):
	if body == Global.player:
		Global.place_label.show_label(text)
	elif body == Global.moving_station and Global.moving_station.being_controlled:
		Global.place_label.show_label(text)
		
