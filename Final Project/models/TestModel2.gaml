model TestModel2

global {
	//number of obstacles
	int nb_obstacles <- 40 parameter: true;
	
	//perception distance
	float perception_distance <- 2.0 parameter: true;
	
	//precision used for the masked_by operator (default value: 120): the higher the most accurate the perception will be, but it will require more computation
	int precision <- 600 parameter: true;
	
	file grid_data <- file("../includes/hab10.asc");

	
	geometry shape1 <- envelope(grid_data);
	
	//space where the agent can move.
	geometry free_space <- copy(shape);
	
	init {
		create obstacle number:nb_obstacles {
//			shape <- rectangle(2+rnd(20), 2+rnd(20));arc(3000,135,180, false);
			shape <- arc(2 + rnd(20),135,180);
			free_space <- free_space - shape;
		}
		
		create people  {
			location <- any_location_in(free_space);
		}
	}
}

species obstacle {
	aspect default {
		draw shape color: #gray border: #black;
	}
}
species people skills: [moving]{
	//zone of perception
	geometry perceived_area;
	
	//the target it wants to reach
	point target ;
	
	reflex move {
		if (target = nil ) {
			if (perceived_area = nil) or (perceived_area.area < 2.0) {
				//if the agent has no target and if the perceived area is empty (or too small), it moves randomly inside the free_space
				do wander bounds: free_space;
			} else {
				//otherwise, it computes a new target inside the perceived_area .
				target <- any_location_in(perceived_area);
			}
		} else {
			//if it has a target, it moves towards this target
			do goto target: target;
			
			//if it reaches its target, it sets it to nil (to choose a new target)
			if (location = target)  {
				target <- nil;
			}
		}
	}
	//computation of the perceived area
	reflex update_perception {
		//the agent perceived a cone (with an amplitude of 60°) at a distance of  perception_distance (the intersection with the world shape is just to limit the perception to the world)
		perceived_area <- (cone(heading-30,heading+30) intersection world.shape) intersection circle(perception_distance); 
		
		//if the perceived area is not nil, we use the masked_by operator to compute the visible area from the perceived area according to the obstacles
		if (perceived_area != nil) {
			perceived_area <- perceived_area masked_by (obstacle,precision);

		}
	}
	
	aspect body {
		draw triangle(0.5) rotate:90 + heading color: #red;
	}
	aspect perception {
		if (perceived_area != nil) {
			draw perceived_area color: #green;
			draw circle(0.1) at: target color: #magenta;
		}
	}
}

//grid plot neighbors: 4 file: grid_data{
//	int red <- 0;
//	float biomass;
//	float init_bio;
//	float carrying_capacity;
////	rgb color update: rgb(red, 255 * biomass/max_carrying_capacity, 0);
//	
//	bool is_free <- true;
//	
//	init {
//		carrying_capacity <- grid_value;
//		biomass <- rnd(1, carrying_capacity);
//		init_bio <- biomass;
////		color <- rgb(red, 255 * biomass/max_carrying_capacity, 0);
//	}
//	
//	aspect default {
//		draw square(100) color: color border: #black;
//	}
//	reflex grow when: carrying_capacity != 0 {
//		biomass <- init_bio;
//	}
//}

experiment goat type: gui {
	float minimum_cycle_duration <- 0.05;
	output synchronized: true {
		display view{
//			species plot;
			species obstacle;
			species people aspect: perception transparency: 0.5;
			species people aspect: body;
		}
	}
}
