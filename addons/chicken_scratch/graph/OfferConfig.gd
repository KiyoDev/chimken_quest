@tool
class_name OfferConfig extends VBoxContainer


@onready var Offerings := $Offerings;



func get_offers() -> Array[OfferElement]:
	var offerings : Array[OfferElement] = [];
	
	for offering in Offerings.get_children():
		offerings.append(offering);
	
	return offerings;
