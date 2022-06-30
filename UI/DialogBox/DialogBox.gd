extends Control

class_name DialogBox

signal mouse_click
signal dialog_skipped
signal dialog_over

export var visibility_change_speed: float
export var on_station_dialogs = []
var last_played_dialog = -1
var is_dialog_over = false;
onready var textbox = $MarginContainer/Label

func _ready():
	Global.dialog_manager = self

func play_concrete_sequential_dialog(index:int):
	var dialog_to_play = on_station_dialogs[index]
	play_dialog(dialog_to_play)
	

func play_sequential_dialog():
	last_played_dialog += 1
	play_concrete_sequential_dialog(last_played_dialog)
	return last_played_dialog
	
func show_line(line:String):
	textbox.text = line
	textbox.percent_visible = 0
	
func play_dialog(dialogue:PoolStringArray):
	# Opened
	modulate.a=1;
	is_dialog_over=false
	
	# Show lines
	for line in dialogue:
		show_line(line)
		yield(self,"mouse_click")
		if textbox.percent_visible < 1:
			textbox.percent_visible = 1
			yield(self,"mouse_click")
			
	# Closed
	is_dialog_over = true
	modulate.a=0;
	
	emit_signal("dialog_over")
	

func _process(delta):
	if textbox.percent_visible < 1:
		textbox.percent_visible += delta*visibility_change_speed
		if textbox.percent_visible > 1:
			textbox.percent_visible = 1
			
	if Input.is_action_just_pressed("left_click"):
		emit_signal("mouse_click")
		
