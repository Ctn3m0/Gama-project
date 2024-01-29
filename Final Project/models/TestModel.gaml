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
	
	float perception_distance <- 4000.0 parameter: true;
	
	int precision <- 600 parameter: true;
	
	float goat_distance <- 1000.0;
	
	file grid_data <- file("../includes/hab10.asc");

	
	geometry shape <- envelope(grid_data);
	
	int nb_goat <- 10;
	
	geometry free_space <- copy(shape);
	
//	list<agent> var2 <- agents_overlapping(goal[0].safezone);
	
	
	
//	list<plot> avail <- 
	
	init {
//		write var2 contains plot[0].name;
		create goat number: nb_goat;
		create goal;
		create obstacle number: 100{
			shape <- arc(1000 + rnd(2000),135,180);
		} 
//		{
//			location <- (one_of (plot where var2 contains each.name)).location;
//		}
//		create obstacle number:100 {
//			shape <- rectangle(2000+rnd(2000), 2000+rnd(2000));
//			free_space <- free_space - shape;
//		}
	}
}

species goat skills: [moving]{
	
	geometry perceived_area;
	
	list<obstacle> neighbors1 update: obstacle at_distance obstacle_distance;
	
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
		if not empty(neighbors1) {
//			geometry d <- 10 around first(neighbors);
//			do goto target: goal[0].location speed: rnd(30.0, 100.0) on: d;
			plot p <- first(plot overlapping self.location);
			write "====================";
			write neighbors1;
//			write agents_crossing(first(neighbors1));
//			write plot partially_overlapping first(neighbors1).location;
//			write plot partially_overlapping points_in(first(neighbors));
			list<plot> a <- plot overlapping first(neighbors1).location;
//			write a;
//			write plot overlapping first(neighbors1).location;
//			write first(neighbors).shape;
//			write neighbors;
//			write first(neighbors);
			p.red <- 150;
//			plot next_plot <- one_of(p.neighbors where (each.location != first(neighbors).location));
//			plot next_plot <- (p.neighbors where (each.location != first(neighbors).location)) with_min_of max(distance_to(each.location, self.location), distance_to(each.location, goal[0].location));
			plot next_plot;
			list<agent> danger_zone <- agents_overlapping(first(neighbors1).safezone);
//			write (neighbors1 where area(each) intersection perceived_area);
//			write var0;
//			if flip(0.5) {
//				write "1";
////				next_plot <- (p.neighbors where (each.location != first(neighbors1).location)) with_max_of distance_to(each.location, first(neighbors1).location);
//				next_plot <- (p.neighbors) with_max_of distance_to(each.location, first(neighbors1).location);
//			} else {
//				write "0";
////				next_plot <- (p.neighbors where (each.location != first(neighbors1).location)) with_min_of distance_to(each.location, goal[0].location);
//				next_plot <- (p.neighbors) with_min_of distance_to(each.location, goal[0].location);
//			}
			do goto target: any_location_in(perceived_area) speed: rnd(30.0, 100.0);
//			target <- 
//			plot next_plot <- one_of(p.neighbors where (each.location != points_in(first(neighbors))));
//			plot next_plot <- one_of(p.neighbors where (each.location not in plot overlapping first(neighbors).location));
//			plot next_plot <- one_of(p.neighbors where (each.location != any_location_in(round(5))));
//			location <- next_plot.location;
//			do move speed: rnd(30.0, 100.0) heading: heading + 70 bounds: d;
		} else {
			plot p <- first(plot overlapping self.location);
			p.red <- 150;
			do goto target: goal[0].location speed: rnd(30.0, 100.0);
		}
	}
	
	reflex update_perception {
		//the agent perceived a cone (with an amplitude of 60°) at a distance of  perception_distance (the intersection with the world shape is just to limit the perception to the world)
		perceived_area <- (cone(heading-30,heading+30) intersection world.shape) intersection circle(perception_distance); 
		
//		write "First: " + perceived_area;
		
		if (perceived_area != nil) {
			
			perceived_area <- perceived_area masked_by (obstacle,precision);
			
//			write "Second: " + perceived_area;

		}
	}
	
	aspect default {
		draw circle(150) color: #white;
	}
	aspect perception {
		if (perceived_area != nil) {
			draw perceived_area color: #red;
		}
	}
}

species goal {
	geometry safezone <- (square(15000) intersection world.shape) intersection circle(perception_distance);
	
	aspect default {
		draw square(1000) color: #blue;
	}
	aspect safezone {
		draw square(15000) color: #blue;
	}
}

species obstacle {
	geometry safezone <- (square(2000) intersection world.shape) intersection circle(3000);
	
	aspect default {
		draw shape color: #yellow;
	}
	aspect zone {
		draw square(3000) color: #blue;
	}
}

//species obstacle {
//	aspect default {
//		draw shape color: #yellow border: #red;
//	}
//}

grid plot neighbors: 4 file: grid_data{
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
			species goat aspect: perception transparency: 0.5;
			species goal;
			species goal aspect: safezone transparency: 0.5;
			species obstacle;
			species obstacle aspect: zone transparency: 1;
		}
	}
}

