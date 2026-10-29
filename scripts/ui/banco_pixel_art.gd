extends RefCounted
## Atlas regions follow the generated silhouettes, not assumed equal tiles.
const ATLAS = preload("res://assets/ui/generated/banco_verdict_pixel.png")
const RECEIPT := Rect2(0, 90, 752, 514)
const SEAL := Rect2(752, 40, 502, 560)
const CONDEMNATION := Rect2(0, 745, 750, 375)

static func texture(region: Rect2) -> AtlasTexture:
	var result := AtlasTexture.new()
	result.atlas = ATLAS
	result.region = region
	result.filter_clip = true
	return result
