/**
* Name: NewModel
* Based on the internal empty template. 
* Author: ctn3m0
* Tags: 
*/


model NewModel

global {
	float max_carrying_capacity <- 10.0;
	
	float obstacle_distance <- 2000.0;
	
	float goat_distance <- 1000.0;
	
	file grid_data <- file("../includes/hab10.asc");

	
	geometry shape <- envelope(grid_data);
	
	int nb_goat <- 10;
	
	init {
		create goat number: nb_goat;
		create goal;
		create obstacle number: 100;
	}
}

species goat skills: [moving]{
	
	list<obstacle> neighbors update: obstacle at_distance obstacle_distance;
	
//	reflex dodge when: not empty(neighbors) {
//		geometry d <- 10 around first(neighbors);
//		do goto target: goal[0].location speed: rnd(30.0, 100.0) on: d;
////		location <- any_location_in(one_of(obstacle));
//	}

	list<goat> neighbors_friend update: goat at_distance obstacle_distance;


//	reflex follow when: length(neighbors_friend) > 0 {
//		do goto target: neighbors_friend[0].location speed: rnd(30.0, 100.0);
//	}
	
	reflex move {
		if not empty(neighbors) {
//			geometry d <- 10 around first(neighbors);
//			do goto target: goal[0].location speed: rnd(30.0, 100.0) on: d;
			plot p <- first(plot overlapping self.location);
			write "====================";
			write first(neighbors).location;
			write plot partially_overlapping first(neighbors).location;
//			write plot partially_overlapping points_in(first(neighbors));
			list<plot> a <- plot overlapping first(neighbors).location;
			write a;
			write plot overlapping first(neighbors).location;
//			write first(neighbors).shape;
//			write neighbors;
//			write first(neighbors);
			p.red <- 150;
//			plot next_plot <- one_of(p.neighbors where (each.location != first(neighbors).location));
//			plot next_plot <- (p.neighbors where (each.location != first(neighbors).location)) with_min_of max(distance_to(each.location, self.location), distance_to(each.location, goal[0].location));
			plot next_plot <- (p.neighbors where (each.location != first(neighbors).location)) with_max_of max(distance_to(each.location, first(neighbors).location), distance_to(each.location, self.location));
//			plot next_plot <- one_of(p.neighbors where (each.location != points_in(first(neighbors))));
//			plot next_plot <- one_of(p.neighbors where (each.location not in plot overlapping first(neighbors).location));
//			plot next_plot <- one_of(p.neighbors where (each.location != any_location_in(round(5))));
			location <- next_plot.location;
//			do move speed: rnd(30.0, 100.0) heading: heading + 70 bounds: d;
		} else {
			plot p <- first(plot overlapping self.location);
			p.red <- 150;
			do goto target: goal[0].location speed: rnd(30.0, 100.0);
		}
	}
	
	aspect default {
		draw circle(150) color: #white;
	}
}

species goal {
	aspect default {
		draw square(1000) color: #blue;
	}
}

species obstacle {
	aspect default {
		draw arc(3000,45,90, false) color: #yellow;
	}
}

grid plot neighbors: 8 file: grid_data{
	int red <- 0;
	float biomass;
	float init_bio;
	float carrying_capacity;
	rgb color update: rgb(red, 255 * biomass/max_carrying_capacity, 0);
	
	bool is_free <- true;
	
	init {
		carrying_capacity <- grid_value;
		biomass <- rnd(1, carrying_capacity);
		init_bio <- biomass;
		color <- rgb(red, 255 * biomass/max_carrying_capacity, 0);
	}
	
	aspect default {
		draw square(100) color: color border: #black;
	}
	reflex grow when: carrying_capacity != 0 {
		biomass <- init_bio;
	}
}

experiment runme {
	output {
		display biomass {
			grid plot ;
			species goat;
			species goal;
			species obstacle;
		}
	}
}

