@tool
class_name GlobalPlanetspaceObject
extends PlanetspaceObject

func reproject(focus_object: PlanetspaceObject):
	if focus_object == self:
		transform.basis = Basis()
	else:
		transform.basis = focus_object.loc.inverse() * loc
