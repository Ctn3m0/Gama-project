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
	
	int nb_goat <- 10;
	
	init {
		create goat number: nb_goat;
		create goal;
		create obstacle number: 30;
	}
}

species goat skills: [moving]{
	reflex move {
		plot p <- first(plot overlapping self.location);
		p.red <- 150;
		do goto target: goal[0].location speed: rnd(30.0, 100.0);
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
		draw arc(3000,45,90) color: #yellow;
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

