/**
* Name: SheepMovementsex2
* Based on the internal empty template. 
* Author: ctn3m0
* Tags: 
*/


model Ex2

global {
	float max_carrying_capacity <- 10.0;
	
	float max_cabbage_eat <- 5.0;
	
	float growth_rate <- 0.002;
	
	float obstacle_distance <- 500.0;
	
	float perception_distance <- 4000.0 parameter: true;
	
	float friend_distance <- 4000.0 parameter: true;
	
	int goat_precision <- 2000 parameter: true;
	
	int precision <- 600 parameter: true;
	
	float goat_distance <- 1000.0;
	
	file grid_data <- file("../includes/hab10.asc");

	
	geometry shape <- envelope(grid_data);
	
	int nb_goat <- 20;
	
	geometry free_space <- copy(shape);

	
	init {
		create obstacle number: 100{
			shape <- flip(0.6) ? rectangle(1000+rnd(2000), 1000+rnd(2000)) : circle(2000 + rnd(1000));
			safezone <- (square(3000) intersection world.shape) intersection circle(3000);
	
			b <- plot overlapping safezone;
			
			loop p over: b {
				p.is_taken <- true;
			}
		} 
		create goat number: nb_goat {
			location <- one_of(plot where not each.is_taken );
		}
		create goal {
			location <- one_of(plot where not each.is_taken );
		}
	}
}

species goat skills: [moving]{
	
	geometry perceived_area;
	
	geometry friend_zone;
	
	float max_area;
	
	list<obstacle> neighbors1 update: obstacle at_distance obstacle_distance;
	
	reflex move {
		list<plot> pl <- (plot overlapping perceived_area);
		plot go_to_eat <- one_of(pl where (each.biomass > 5));
		if not empty(neighbors1) {
			plot p <- first(plot overlapping self.location);
			
			p.red <- 150;
//			p.red <- 0;
			
			list<goat> a <- (goat select (each.name != self.name)) overlapping friend_zone;
			
			if go_to_eat != nil{
				if go_to_eat.location = self.location {
					write go_to_eat;
					float gonnaEat <- min(max_cabbage_eat, go_to_eat.biomass);
					go_to_eat.biomass <- go_to_eat.biomass - gonnaEat;
				}
				do goto target: go_to_eat.location speed: rnd(500.0, 800.0);
			} else if length(a) > 0 and distance_to(goal[0].location, self.location) > 15000 {
				write "====================";
				write self.name;
				write a;
				do goto target: one_of(a).location speed: rnd(500.0, 800.0);
			} else {
				do goto target: any_location_in(perceived_area) speed: rnd(200.0, 300.0);
			}
			

		} else {
			plot p <- first(plot overlapping self.location);
			p.red <- 150;
//			p.red <- 0;
			if go_to_eat != nil{
				if go_to_eat.location = self.location {
					write go_to_eat;
					float gonnaEat <- min(max_cabbage_eat, go_to_eat.biomass);
					go_to_eat.biomass <- go_to_eat.biomass - gonnaEat;
				}
				do goto target: go_to_eat.location speed: rnd(500.0, 800.0);
			} else {
				do goto target: goal[0].location speed: rnd(200.0, 300.0);	
			}
		}
	}
	
	reflex update_perception {
		perceived_area <- (cone(heading-30,heading+30) intersection world.shape) intersection circle(perception_distance);
		
		if (perceived_area != nil) {
			
			perceived_area <- perceived_area masked_by (obstacle,precision);
			

		}
	}
	reflex update_friendzone {
		friend_zone <- (cone(heading-50,heading+50) intersection world.shape) intersection circle(friend_distance);
		
		max_area <- friend_zone.area; 
		
		
		if (friend_zone != nil) {
			
			friend_zone <- friend_zone masked_by ((goat select (each.name != self.name)),goat_precision);
			

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
	aspect friend {
		if (friend_zone != nil) {
			draw friend_zone color: #yellow;
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
	geometry safezone;
	
	list<plot> b;
	
	aspect default {
		draw shape color: #gray;
	}
	aspect zone {
		draw square(3000) color: #blue;
	}
}


grid plot neighbors: 4 file: grid_data{
	bool is_taken <- false;
	int red <- 0;
	float biomass;
	float init_bio;
	float carrying_capacity;
	rgb color update: rgb(red, 255 * biomass/max_carrying_capacity, 0);
	
	bool is_free <- true;
	
	init {
		carrying_capacity <- grid_value;
		biomass <- rnd(1, carrying_capacity);
//		init_bio <- biomass;
		color <- rgb(red, 255 * biomass/max_carrying_capacity, 0);
	}
	
	aspect default {
		draw square(100) color: color border: #black;
	}
	reflex grow when: carrying_capacity != 0 {
		biomass <- biomass * ( 1 + growth_rate * ( 1 - biomass/carrying_capacity));
	}
}

experiment runme {
	output {
		display biomass {
			grid plot ;
			species goat;
			species goat aspect: perception transparency: 0.5;
			species goat aspect: friend transparency: 1;
			species goal;
			species goal aspect: safezone transparency: 0.5;
			species obstacle;
			species obstacle aspect: zone transparency: 1;
		}
	}
}

