extends RefCounted
class_name GallicusLanguages

const DEFAULT_LOCALE: String = "it"

const LANGUAGES: Array[Dictionary] = [
	{
		"locale": "it",
		"label": "Italiano",
		"path": "res://assets/i18n/it.csv",
	},
	{
		"locale": "en",
		"label": "English",
		"path": "res://assets/i18n/en.csv",
	},
	{
		"locale": "es",
		"label": "Español",
		"path": "res://assets/i18n/es.csv",
	},
]


static func all() -> Array[Dictionary]:
	return LANGUAGES.duplicate(true)


static func locales() -> Array[String]:
	var result: Array[String] = []
	for entry: Dictionary in LANGUAGES:
		result.append(str(entry.get("locale", "")))
	return result


static func has_locale(locale: String) -> bool:
	return locales().has(locale.strip_edges().to_lower())


static func sanitize_locale(locale: String) -> String:
	var normalized: String = locale.strip_edges().to_lower()
	if has_locale(normalized):
		return normalized
	return DEFAULT_LOCALE


static func label_for(locale: String) -> String:
	var normalized: String = sanitize_locale(locale)
	for entry: Dictionary in LANGUAGES:
		if str(entry.get("locale", "")) == normalized:
			return str(entry.get("label", normalized))
	return normalized


static func path_for(locale: String) -> String:
	var normalized: String = sanitize_locale(locale)
	for entry: Dictionary in LANGUAGES:
		if str(entry.get("locale", "")) == normalized:
			return str(entry.get("path", ""))
	return ""


static func fallback_locale(locale: String) -> String:
	var normalized: String = sanitize_locale(locale)
	if normalized != DEFAULT_LOCALE:
		return DEFAULT_LOCALE
	if has_locale("en"):
		return "en"
	return DEFAULT_LOCALE
