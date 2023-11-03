@tool
class_name OfferConfig extends VBoxContainer


@export var Offerings : VBoxContainer;
@export var ItemCount : SpinBox;


func set_item_count(value : int):
	ItemCount.value = value;


func get_offers() -> Array[OfferElement]:
	var offerings : Array[OfferElement] = [];
	
	for offering in Offerings.get_children():
		offerings.append(offering);
	
	return offerings;
