@tool
extends Node

signal reproject(focus_object: PlanetspaceObject, planet_radius: float)
enum ProjectionType {EUCLIDEAN, FLAT_ANGLE_DISTANCE}
var projection_type: ProjectionType
var planet_radius: float = 12_000
var focus_object: PlanetspaceObject:
	set(new_focus_object):
		if is_instance_valid(focus_object):
			force_disconnect(focus_object.object_moved, self.on_focus_point_motion)
		
		force_connect(new_focus_object.object_moved, self.on_focus_point_motion)
		focus_object = new_focus_object
		reproject.emit(focus_object, planet_radius)

func _physics_process(delta):
	#if is_instance_valid(focus_object):
	pass

func on_focus_point_motion(old_location: Basis, new_location: Basis):
	
	reproject.emit(focus_object, planet_radius)
	
	pass

static func force_connect(sig: Signal, fun: Callable) -> void:
	if not sig.is_connected(fun):
		sig.connect(fun)

static func force_disconnect(sig: Signal, fun: Callable) -> void:
	if sig.is_connected(fun):
		sig.disconnect(fun)
