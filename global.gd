extends Node

var player:Player
var dialog_manager:DialogBox
var place_label: Control
var screen_flasher:ScreenFlasher
var station_menu:StationMenu
var moving_station : MovingStation
var current_clock_rotation:float = 0
var clock: RotatingTeleporter
var unmarkedStations = []
