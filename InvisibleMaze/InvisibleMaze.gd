extends Node2D

class_name InvisibleMaze

export var teleport_position_path:NodePath


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_Area2D_body_entered(body):
	if body == Global.player:
		var offset_from_real_maze = Global.player.global_position - global_position
		
		var new_player_position = get_node(teleport_position_path).global_position\
			+ offset_from_real_maze
		Global.screen_flasher.flash()
		Global.player.teleport_to(new_player_position)
	elif body == Global.moving_station:
		var offset_from_real_maze = Global.moving_station.global_position - global_position
		
		var new_station_position = get_node(teleport_position_path).global_position\
			+ offset_from_real_maze
		Global.screen_flasher.flash()
		Global.moving_station.teleport_to(new_station_position)
