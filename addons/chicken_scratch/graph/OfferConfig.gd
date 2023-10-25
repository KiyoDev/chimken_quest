@tool
class_name OfferConfig extends VBoxContainer


@onready var Offers := $Offers;



func get_offers() -> Array[OfferElement]:
	var offers : Array[OfferElement] = [];
	
	for offer in Offers.get_children():
		offers.append(offer);
	
	return offers;
