extends Node
class_name DateRunner

enum Season { SPRING, SUMMER, AUTUMN, WINTER }

var year: int
var month: int
var day: int

signal date_updated

signal day_passed
signal month_passed
signal season_passed
signal year_passed

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func get_season():
	if month >= 3 and month <= 5:
		return Season.SPRING
	if month >= 6 and month <= 8:
		return Season.SUMMER
	if month >= 9 and month <= 11:
		return Season.AUTUMN
	return Season.WINTER
	
func _on_all_loaded():
	emit_signal("date_updated", year, month, day, get_season())

func _on_start_date_runner(day_count):
	day += 3
	emit_signal("day_passed")
	if day > 30:
		day -= 30
		month += 1
		emit_signal("month_passed")
		if month == 3 or month == 6 or month == 9 or month == 12:
			emit_signal("season_passed")
		if month > 12:
			month -= 12
			year += 1
			emit_signal("year_passed")
	emit_signal("date_updated", year, month, day, get_season())
	
func _on_stop_date_runner():
	pass
