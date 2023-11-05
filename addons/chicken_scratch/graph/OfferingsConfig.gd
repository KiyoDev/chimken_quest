@tool
class_name OfferingsConfig extends VBoxContainer


@export var add_offering_button : Button;
@export var offerings : VBoxContainer;


func offering_count() -> int:
	return offerings.get_child_count();


func get_offers() -> Array[OfferingElement]:
	var offerings_arr : Array[OfferingElement] = [];
	
	for offering in offerings.get_children():
		offerings_arr.append(offering);
	
	return offerings_arr;


func get_offering(index : int) -> OfferingElement:
	return offerings.get_child(index);


func add_offering(offering : OfferingElement):
	offerings.add_child(offering);


func remove_offering(offering : OfferingElement):
	offerings.remove_child(offering);
