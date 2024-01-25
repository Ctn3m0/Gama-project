/**
* Name: NewModel
* Based on the internal empty template. 
* Author: ctn3m0
* Tags: 
*/


model NewModel

global {
	float max_carrying_capacity <- 10.0;
	
	float max_cabbage_eat <- 2.0;
	
	file grid_data <- file("../includes/hab10.asc");

	
	geometry shape <- envelope(grid_data);
	
	
//	int nb_wolve <- 10;
//	int wolve_energy <- 30;
	int nb_goat <- 10;
	
	init {
		create goat number: nb_goat;
//		create wolve number: nb_wolve;
	}
}

species animal {
	plot my_plot;
	
	
	init {
		do move_to_cell(one_of(plot where (each.is_free)));
	}
	
	reflex move {
		plot next_plot <- one_of(my_plot.neighbors where (each.is_free));
		
		do move_to_cell(next_plot);
	}
	
//	reflex reproduction when: energy >= reproduction_threshold { 
//		plot repor_plot <- one_of(plot where (each.is_free));
//		if (repor_plot != nil) {
//			create species(self) number: 1 { 
//				do move_to_cell(repor_plot);
//				self.energy <- myself.energy / 2; 
//			}
//			self.energy <- energy /2; 
//		}
//	}
	
	action move_to_cell(plot next_plot) {
		if (my_plot != nil) {
			my_plot.is_free <- true;
		}
		
		next_plot.is_free <- false;
		
		
		location <- next_plot.location;
		my_plot <- next_plot;
	}
}

//species wolve parent: animal{
//
//	reflex move {
//		plot next_plot <- nil;
//		
//		list<plot> buffet <- my_plot.neighbors where (!empty( goat inside each ));
//		
//		if (empty(buffet)) {
//			next_plot <- one_of(my_plot.neighbors where (each.is_free));
//		} else {
//			next_plot <- one_of(buffet);
//			goat victim <- one_of(goat inside next_plot);
//			energy <- energy + victim.energy;
//			
//			ask victim {
//				write "" + self + "died :(";
//				do die;
//			}
//		}
//		
//		do move_to_cell(next_plot);
//	}
//	
//	aspect default {
//		draw circle(50) color: #red;
//	}
//}

species goat parent: animal{

	reflex eat {
		float gonnaEat <- min(max_cabbage_eat, my_plot.biomass);
//		energy <- energy + gonnaEat;
		my_plot.biomass <- my_plot.biomass - gonnaEat;
	}
	
	aspect default {
		draw circle(150) color: #white;
	}
}

grid plot neighbors: 8 file: grid_data{
	float biomass;
	float init_bio;
	float carrying_capacity;
//	rgb color update: rgb(0, 255 * biomass/max_carrying_capacity, 0);
	rgb color update: rgb(0, 255 * biomass/max_carrying_capacity, 0);
	
	bool is_free <- true;
	
	init {
		carrying_capacity <- grid_value;
		biomass <- rnd(1, carrying_capacity);
		init_bio <- biomass;
		color <- rgb(0, 255 * biomass/max_carrying_capacity, 0);
	}
	
	aspect default {
		draw square(100) color: color border: #black;
	}
//	reflex grow when: carrying_capacity != 0 {
//		biomass <- biomass * ( 1 + growth_rate * ( 1 - biomass/carrying_capacity));
//	}
	reflex grow when: carrying_capacity != 0 {
		biomass <- init_bio;
	}
}

experiment runme {
	output {
		display biomass {
			grid plot ;
//			species wolve;
			species goat;
		}

		display plot {
			chart "Nb animal" type: series {
//				data "#wolve" value: length(wolve) color: #red;
				data "#goat" value: length(goat) color: #blue;
			}
		}
	}
}

