extends Area2D

class_name LandingArea

signal body_entered_this_area (body,area)
signal body_exited_this_area (body,area)

signal on_player_takes_off()

var take_control_option:FuncRef = null
var locate_station_option:FuncRef = null
var jump_to_clock_option:FuncRef = null
var play_dialog_option: FuncRef =funcref(self,"play_dialog")

var player_control_is_allowed = true

var dialog_finished = false
var sequential_dialog_index = -1
export var dialog_lines:PoolStringArray

func open_station():
	player_control_is_allowed = true
	if not dialog_finished:
		play_dialog()
	else:
		Global.station_menu.open_menu(self)
	
func player_takes_off():
	player_control_is_allowed = true
	Global.station_menu.close_menu()
	emit_signal("on_player_takes_off")

func play_dialog():
	Global.station_menu.close_menu()
	player_control_is_allowed = false
	if sequential_dialog_index == -1:
		Global.unmarkedStations.erase(self)
		sequential_dialog_index =  Global.dialog_manager.play_sequential_dialog()
	else:
		Global.dialog_manager.play_concrete_sequential_dialog(sequential_dialog_index)
	
	yield(Global.dialog_manager,"dialog_over")
	
	Global.dialog_manager.play_dialog(dialog_lines)
	
	yield(Global.dialog_manager,"dialog_over")
	
	dialog_finished = true
	player_control_is_allowed = true
	Global.station_menu.open_menu(self)


func _ready():
	Global.unmarkedStations.append(self)
# warning-ignore:return_value_discarded
	self.connect("body_entered_this_area",
		Global.player
		,"_on_LandingArea_body_entered_area")
# warning-ignore:return_value_discarded
	self.connect("body_exited_this_area",
		Global.player
		,"_on_LandingArea_body_exited_area")

func _on_LandingArea_body_entered(body):
	emit_signal("body_entered_this_area",body,self)

func _on_LandingArea_body_exited(body):
	emit_signal("body_exited_this_area",body,self)

func get_landing_point():
	return $LandingPoint
