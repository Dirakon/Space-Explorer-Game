extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var dir_to_words = {
	Vector2(0,-1):"north",
	Vector2( 1/sqrt(2), -1/sqrt(2)):"north-east",
	Vector2(1,0):"east",
	Vector2(1/sqrt(2), 1/sqrt(2)):"south-east",
	Vector2(0,1):"south",
	Vector2(- 1/sqrt(2), 1/sqrt(2)):"south-west",
	Vector2(-1,0):"west",
	Vector2(- 1/sqrt(2), -1/sqrt(2)):"north-west",
}

func locate_nearest_unmarked_station():
	Global.station_menu.close_menu()
	$LandingArea.player_control_is_allowed = false
	var nearest_station = get_nearest_station()
	if nearest_station == null:
		Global.dialog_manager.play_dialog(
			["Locating the closest unmarked station...",
			"Operation failed: no unmarked stations found."]
			)
	else:
		var dir = get_words_from_direction(nearest_station.global_position - global_position)
		Global.dialog_manager.play_dialog(
			["Locating the closest unmarked station...",
			"Located unmarked station to the " + dir]
			)
		
	yield(Global.dialog_manager,"dialog_over")
	$LandingArea.player_control_is_allowed = true
	Global.station_menu.open_menu($LandingArea)

func get_nearest_station():
	var min_distance = 9999999
	var closest_staion = null
	for station in Global.unmarkedStations:
		var distance = (global_position - station.global_position).length()
		if distance < min_distance:
			min_distance = distance
			closest_staion = station
	return closest_staion


func jump_to_clock():
	Global.station_menu.close_menu()
	
	var new_position:Vector2 = Vector2(rand_range(-1,1),rand_range(-1,1))
	if new_position.x == 0 and new_position.y == 0:
		new_position.x = 1
	teleport_position = (new_position.normalized() * 500) + Global.clock.global_position
	Global.dialog_manager.play_dialog(
			["Preparing the jump...",
			"Jump is ready.",
			"Disembark the station to proceed."]
			)
		
	yield(Global.dialog_manager,"dialog_over")
	$LandingArea.player_control_is_allowed = true


func get_words_from_direction(dir:Vector2):
	dir = dir.normalized()
	var min_distance = 999999
	var correct_words = "unknown"
	for vec in dir_to_words.keys():
		var length = (dir-vec).length()
		if length < min_distance:
			correct_words = dir_to_words[vec]
			min_distance = length
	return correct_words

export var thing:NodePath

# Called when the node enters the scene tree for the first time.
func _ready():
	$LandingArea.locate_station_option = funcref(self,"locate_nearest_unmarked_station")
	$LandingArea.jump_to_clock_option = funcref(self,"jump_to_clock")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

var teleport_position = null

func _on_LandingArea_on_player_takes_off():
	if teleport_position == null:
		return
	Global.player.teleport_to(teleport_position)
	Global.screen_flasher.flash()
	teleport_position = null	
