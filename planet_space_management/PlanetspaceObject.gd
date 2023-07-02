@tool
class_name PlanetspaceObject extends Node3D

signal object_moved(old_location: Basis, new_location: Basis)

const NORTH_POLE := Vector3(0, 1, 0)

@export var planet_data: Planet
@export var visibility_cutoff: float = 10_000
@export var altitude: float = 1.0: # doesn't work correctly for some reason bruh
	set(value):
		altitude = max(value, -planet_data.planet_radius)
		if is_focus_point:
			planet_data.reproject.emit()
		reprojection_requested = true
@export var loc := Basis():
	set(value):
		var old_loc = Basis(loc)
		loc = value.orthonormalized()
		if is_focus_point:
			planet_data.reproject.emit()
		object_moved.emit(old_loc, loc)
		reprojection_requested = true
@export var loc_euler_degrees: Vector3:
	set(newval):
		newval.x = deg_to_rad(newval.x)
		newval.y = deg_to_rad(newval.y)
		newval.z = deg_to_rad(newval.z)
		loc = Basis.from_euler(newval)
	get:
		var out := loc.get_euler()
		out.x = rad_to_deg(out.x)
		out.y = rad_to_deg(out.y)
		out.z = rad_to_deg(out.z)
		return out
@export var is_focus_point: bool:
	set(value):
		if value and is_instance_valid(planet_data):
			planet_data.focus_object = self
	get:
		return is_instance_valid(planet_data) and planet_data.focus_object == self
@export var reprojection_requested := true:
	set(newvalue):
		if planet_data:
			reprojection_requested = is_instance_valid(planet_data.focus_object) and newvalue

func _ready():
	planet_data.reproject.connect(func():reprojection_requested = true)
	#object_moved.connect(func(_a, _b):reprojection_requested = true)

func _physics_process(_delta):
	if reprojection_requested:
		reproject(planet_data.focus_object)
		reprojection_requested = false

func reproject(focus_object: PlanetspaceObject):
	pass
	if focus_object == self:
		position = Vector3(0, altitude, 0)
		transform.basis = Basis()
	else:
		var focus_local_matx := focus_object.loc.inverse() * loc
		match planet_data.projection_type:
			planet_data.ProjectionType.EUCLIDEAN:
				position = (focus_local_matx.y + Vector3(0, -1, 0)) * planet_data.planet_radius + focus_local_matx.y * altitude
				transform.basis = focus_local_matx
			planet_data.ProjectionType.FLAT_ANGLE_DISTANCE:
				var rotation_axis := Vector3.UP.cross(focus_local_matx.y).normalized()
				position = Vector3.UP.cross(-rotation_axis).normalized() * distance_to_vector(focus_object.loc.y)
				position.y = altitude
				transform.basis = focus_local_matx.rotated(rotation_axis, -Vector3.UP.signed_angle_to(focus_local_matx.y, rotation_axis))
				pass

func move_local(delta: Vector3): # local to heading, obviously. y - upwards. meters.
	altitude += delta.y
	delta.y = 0.0 # this must be nullified for further calculations
	var motion_tangent: Vector3 = loc.x * delta.normalized().x + loc.z * delta.normalized().z
	move_along_tangent(motion_tangent.normalized(), delta.length())

func move_towards_object(target: PlanetspaceObject, dist: float):
	var direction_helper := Vector2(distance_to_vector(target.loc.y), altitude - target.altitude).normalized()
	altitude += direction_helper.y * dist
	move_towards_basis(target.loc, direction_helper.x * dist)

func move_towards_basis(target: Basis, dist: float):
	move_towards_vector(target.y, dist)

func move_towards_vector(target: Vector3, dist: float):
	var motion_axis: Vector3 = loc.y.cross(target)
	var dist_to_travel: float = distance_to_vector(target)
	move_around_rotation_axis(motion_axis, minf(dist, dist_to_travel))

func move_along_tangent(tangent: Vector3, dist: float):
	var motion_axis := loc.y.cross(tangent).normalized()
	move_around_rotation_axis(motion_axis, dist)

func move_around_rotation_axis(axis: Vector3, dist: float):
	loc = loc.rotated(axis.normalized(), planet_data.dist_to_arc_angle(dist))

func rotate_around_vertical_axis(angle: float):
	loc = loc.rotated(loc.y.normalized(), angle)

func distance_to_vector(target: Vector3) -> float:
	var motion_axis: Vector3 = loc.y.cross(target)
	return planet_data.arc_angle_to_dist(loc.y.signed_angle_to(target, motion_axis))

