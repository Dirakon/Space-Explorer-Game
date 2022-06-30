extends GravitatingBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"




# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_BlockingTrigger_body_entered(body):
	if body == Global.moving_station:
		is_teleportable = false


func _on_BlockingTrigger_body_exited(body):
	if body == Global.moving_station:
		is_teleportable = true
