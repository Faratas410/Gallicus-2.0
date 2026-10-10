extends RefCounted
## Printed decision and its retained imprint share the same pigments.
## The only colour source for migrated UI; consumers never write hex inline.

const INK := Color("191917")
const IVORY := Color("e7ddc5")
const WAX := Color("792d26")
const MUTED := Color("a39e8f")
## Disabled print: the surface sinks 16% toward ink, never a new hue.
const DISABLED_MIX: float = 0.16

static func pigment_on(material: StringName) -> Color:
	return INK if material == &"paper" else IVORY

static func surface_of(material: StringName) -> Color:
	return IVORY if material == &"paper" else WAX if material == &"wax" else INK
