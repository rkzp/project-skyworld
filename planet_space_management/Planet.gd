@tool
class_name Planet extends Resource

signal reproject()
enum ProjectionType {EUCLIDEAN, FLAT_ANGLE_DISTANCE}
@export var planet_name := "Unnamed Planet"
@export var sync_to_real_time: bool = false # if true, will use unix time for daylight cycle
@export var daylight_cycle_seconds: float = 240
@export var daylight_cycle_minutes: float:
	set(val):
		daylight_cycle_seconds = val * 60
	get:
		return daylight_cycle_seconds / 60
@export var daylight_cycle_hours: float:
	set(val):
		daylight_cycle_seconds = val * 3600
	get:
		return daylight_cycle_seconds / 3600
@export var atmosphere_ceiling: float = 1000
@export var planet_radius: float = 24_000:
	set(newval):
		reproject.emit()
		planet_radius = newval
@export var projection_type := ProjectionType.FLAT_ANGLE_DISTANCE:
	set(newval):
		reproject.emit()
		projection_type = newval
@export var focus_object: PlanetspaceObject:
	set(new_focus_object):
		#if is_instance_valid(focus_object):
		#	force_disconnect(focus_object.object_moved, self.on_focus_point_motion)
		
		focus_object = new_focus_object
		reproject.emit()

func _init():
	reproject.connect(func():
		if focus_object:
			RenderingServer.global_shader_parameter_set("focus_position", focus_object.loc)
		)
	
	pass


func dist_to_arc_angle(dist: float) -> float:
	return dist / planet_radius
func arc_angle_to_dist(angle: float) -> float:
	return angle * planet_radius

static func force_connect(sig: Signal, fun: Callable) -> void:
	if not sig.is_connected(fun):
		sig.connect(fun)

static func force_disconnect(sig: Signal, fun: Callable) -> void:
	if sig.is_connected(fun):
		sig.disconnect(fun)
