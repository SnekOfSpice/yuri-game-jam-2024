extends Node2D

var input := [
	"jdfhjgdf. gfh, dghfgh: dfhbgjhjdfg"
]



func capitalize_sentence_beginnings_str(input:String) -> String:
	return capitalize_sentence_beginnings([input])[0]

func capitalize_sentence_beginnings(input:Array) -> Array:
	var letters := ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",]

	var c12n_prefixes := [
		".", ":", ";", "-"
	]

	var result := []
	for text : String in input:
		for prefix in c12n_prefixes:
			for letter :String in letters:
				text = text.replace(str(prefix, letter), str(prefix, letter.capitalize()))
				text = text.replace(str(prefix, " ", letter), str(prefix, " ", letter.capitalize()))
		result.append(text)
	return result

func _ready() -> void:
	print(capitalize_sentence_beginnings(input))
