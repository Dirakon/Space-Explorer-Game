extends Control

class_name StationMenu

var current_landing_area : LandingArea = null

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.station_menu = self
	
func close_menu():
	$PlayDialog.visible = false
	$TakeControl.visible = false
	$LocateStation.visible = false
	$JumpToClock.visible = false
	current_landing_area = null
	
func open_menu (landing_area:LandingArea):
	current_landing_area = landing_area
	$PlayDialog.visible = (landing_area.play_dialog_option != null)
	$TakeControl.visible = (landing_area.take_control_option != null)
	$LocateStation.visible = (landing_area.locate_station_option != null)
	$JumpToClock.visible = (landing_area.jump_to_clock_option != null)




func _on_PlayDialog_pressed():
	if current_landing_area == null or current_landing_area.play_dialog_option == null:
		return
	current_landing_area.play_dialog_option.call_func()


func _on_TakeControl_pressed():
	if current_landing_area == null or current_landing_area.take_control_option == null:
		return
	current_landing_area.take_control_option.call_func()




func _on_JumpToClock_pressed():
	if current_landing_area == null or current_landing_area.jump_to_clock_option == null:
		return
	current_landing_area.jump_to_clock_option.call_func()


func _on_LocateStation_pressed():
	if current_landing_area == null or current_landing_area.locate_station_option == null:
		return
	current_landing_area.locate_station_option.call_func()
