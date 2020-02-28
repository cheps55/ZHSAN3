extends Node
class_name Faction

var id: int setget forbidden
var scenario

var gname: String setget forbidden
var color: Color setget forbidden

var _architecture_list = Array() setget forbidden, get_architectures

var player_controlled: bool

func forbidden(x):
	assert(false)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func load_data(json: Dictionary):
	id = json["_Id"]
	gname = json["Name"]
	color = Util.load_color(json["Color"])
	player_controlled = json["PlayerControlled"]
	
func save_data() -> Dictionary:
	return {
		"_Id": id,
		"Name": gname,
		"Color": Util.save_color(color),
		"PlayerControlled": player_controlled,
		"ArchitectureList": Util.id_list(get_architectures())
	}
	
func get_architectures() -> Array:
	return _architecture_list
	
func add_architecture(arch, force: bool = false):
	_architecture_list.append(arch)
	if not force:
		arch.set_belonged_faction(self, true)
		
func ai():
	if not player_controlled:
		for arch in get_architectures():
			arch.ai()
		
func day_event():
	for arch in get_architectures():
		arch.day_event()

func month_event():
	for arch in get_architectures():
		arch.month_event()
