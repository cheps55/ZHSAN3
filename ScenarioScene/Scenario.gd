extends Node
class_name Scenario

onready var tile_size: int = ($Map.find_node('0x0') as TileMap).cell_size[0]
onready var map_size: Vector2 = Vector2(100, 100)
var current_faction

var architecture_kinds = Dictionary() setget forbidden

var factions = Dictionary() setget forbidden
var architectures = Dictionary() setget forbidden
var persons = Dictionary() setget forbidden

signal current_faction_set
signal scenario_loaded

signal architecture_clicked
signal architecture_survey_updated

signal all_faction_finished

func forbidden(x):
	assert(false)

# Called when the node enters the scene tree for the first time.
func _ready():
	($MainCamera as MainCamera).scenario = self
	($DateRunner as DateRunner).scenario = self
	
	_load_data("user://Scenarios/000Test.json")
	current_faction = factions[1]
	
	emit_signal("scenario_loaded")
	
	$DateRunner.connect("day_passed", self, "_on_day_passed")
	$DateRunner.connect("month_passed", self, "_on_month_passed")

func _load_data(path):
	var file = File.new()
	file.open(path, File.READ)
	
	var json = file.get_as_text()
	var obj = parse_json(json)
	
	var date = $DateRunner as DateRunner
	date.year = obj["GameData"]["Year"]
	date.month = obj["GameData"]["Month"]
	date.day = obj["GameData"]["Day"]
	
	var architecture_kind_script = preload("Architecture/ArchitectureKind.gd")
	for item in obj["ArchitectureKinds"]:
		var instance = architecture_kind_script.new()
		__load_item(instance, item, architecture_kinds)
	
	var person_script = preload("Person/Person.gd")
	for item in obj["Persons"]:
		var instance = person_script.new()
		__load_item(instance, item, persons)
	
	var architecture_scene = preload("Architecture/Architecture.tscn")
	for item in obj["Architectures"]:
		var instance = architecture_scene.instance()
		instance.connect("architecture_clicked", self, "_on_architecture_clicked")
		instance.connect("architecture_survey_updated", self, "_on_architecture_survey_updated")
		__load_item(instance, item, architectures)
		for id in item["PersonList"]:
			instance.add_person(persons[int(id)])
		
	var faction_script = preload("Faction/Faction.gd")
	for item in obj["Factions"]:
		var instance = faction_script.new()
		__load_item(instance, item, factions)
		for id in item["ArchitectureList"]:
			instance.add_architecture(architectures[int(id)])

	
func __load_item(instance, item, add_to_list):
	instance.scenario = self
	instance.load_data(item)
	add_to_list[instance.id] = instance
	add_child(instance)

func _on_all_loaded():
	emit_signal("current_faction_set", current_faction)
	
func _on_architecture_clicked(arch, mx, my):
	emit_signal("architecture_clicked", arch, mx, my)
	
func _on_architecture_survey_updated(arch):
	emit_signal("architecture_survey_updated", arch)
	
func _on_architecture_person_selected(task, current_architecture, selected_person_ids):
	var p = []
	for id in selected_person_ids:
		p.append(persons[id])
	architectures[current_architecture].set_person_task(task, p)

func _on_day_passed():
	var last_faction = current_faction
	for faction in factions.values():
		current_faction = faction
		emit_signal("current_faction_set", current_faction)
		faction.ai()
	current_faction = last_faction
	emit_signal("current_faction_set", current_faction)
	for faction in factions.values():
		faction.day_event()
	yield(get_tree(), "idle_frame")
	emit_signal("all_faction_finished")
	
func _on_month_passed():
	for faction in factions.values():
		faction.month_event()
	
