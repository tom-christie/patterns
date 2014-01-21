class Rosette {


    Circle outer_circle, middle_circle, inner_circle;
    Line[] lines;
    PetalDiamond[] petal_diamonds;
    int lines_count;  //actually count-1, i.e. index of last one
    float xpos, ypos;
    float d_rad;

    int[] indices_of_external_lines;
    int[] indices_of_radial_lines;
    int[] indices_of_diagonal_lines;
    int[] indices_of_diagonal_extensions;
    int indices_of_external_lines_count;
    int indices_of_radial_lines_count;
    int indices_of_diagonal_lines_count;
    int indices_of_diagonal_extensions_count;
    //fundamental constructs for a single rosette

    int connect_every_n;
    int num_petals;

    //points on the radius of the circle
    float[] external_points_x = new float[40];
    float[] external_points_y = new float[40];
    int external_points_count;


    float inner_radius;
    float middle_radius;
    float outer_radius;

    //intersections
    float[] middle_circle_intersections_x;
    float[] middle_circle_intersections_y;
    float[] inner_circle_intersections_x;
    float[] inner_circle_intersections_y;




    Rosette() {
    }


    void init() {

        xpos = width/2;
        ypos = height/2;

        lines = new Line[100];
        lines_count = 0;

        indices_of_external_lines = new int[50];
        indices_of_radial_lines = new int[50];
        indices_of_diagonal_lines = new int[50];
        indices_of_diagonal_extensions = new int[50];
        indices_of_external_lines_count = 0;
        indices_of_radial_lines_count = 0;
        indices_of_diagonal_lines_count = 0;
        indices_of_diagonal_extensions_count = 0;

        middle_circle_intersections_x = new float[50];
        middle_circle_intersections_y = new float[50];
        inner_circle_intersections_x = new float[50];
        inner_circle_intersections_y = new float[50];
        inner_radius = 42;
        middle_radius = 100;
        outer_radius = 200;

        outer_circle = new Circle();
        outer_circle.init(xpos, ypos, outer_radius);

        middle_circle = new Circle();
        middle_circle.init(xpos, ypos, middle_radius);

        inner_circle = new Circle();
        inner_circle.init(xpos, ypos, inner_radius);

        num_petals = 8;

        petal_diamonds = new PetalDiamond[num_petals];
        for(int i=0; i<num_petals; i++){
         petal_diamonds[i] = new PetalDiamond();
         petal_diamonds[i].init(i);   
            
        }
        place_external_points(num_petals);
        connect_external_every_n(2);
        connect_center_to_external();
        get_intersections();
        connect_intersections_between_circles();
        get_intersections_between_rays_and_outer_lines();

        get_line_along_outer_lines();
    }

    void get_line_along_outer_lines(){

     //GET OUTER PETAL POINT   
     //first find intersections of external lines
  
  
     //now find the nearest intersection between each rosette upper right and upper left   
        
        
        
    }

    void draw() {

        outer_circle.draw();
        inner_circle.draw();
        middle_circle.draw();
        //draw all lines
        for (int i=0; i<lines_count; i++) {
            lines[i].draw();
        }

        //draw rosette lines
        draw_rosette_lines();
    }

    void draw_rosette_lines() {
        for (int i=0; i<indices_of_diagonal_lines_count; i++) {
            int index = indices_of_diagonal_lines[i];
            lines[index].draw();
        }
        for (int i=0; i<indices_of_diagonal_extensions_count; i++) {
            int index = indices_of_diagonal_extensions[i];
            lines[index].draw();
        }
    }

    float get_dist(float x1, float y1, float x2, float y2) {
        return sqrt( pow(x1-x2, 2) + pow(y1-y2, 2)  );
    }

    void get_intersections_between_rays_and_outer_lines() {

        //actually have to do line intersections here

        //to test, pick the first diagonal and see what else it runs into
        for (int j=0; j<indices_of_diagonal_lines_count; j++) {
            float Ax1 = lines[indices_of_diagonal_lines[j]].x1;
            float Ay1 = lines[indices_of_diagonal_lines[j]].y1;
            float Ax2 = lines[indices_of_diagonal_lines[j]].x2;
            float Ay2 = lines[indices_of_diagonal_lines[j]].y2;

            //eventually want nth closest
            float closest_x = 0;
            float closest_y = 0;
            float current_distance = 100000;

            //get x/y that are further from the center
            float target_x;
            float target_y;
            if ( get_dist(Ax1, Ay1, xpos, ypos) < get_dist(Ax2, Ay2, xpos, ypos)) {
                target_x = Ax2;
                target_y = Ay2;
            } 
            else {
                target_x = Ax1;
                target_y = Ay1;
            }   

            //put a red dot where the target is
//            stroke(255,0,0);
//            fill(255, 0, 0);
//            ellipseMode(CENTER);
//            ellipse(target_x, target_y, 8, 8);
            
            //find intersections with all external lines
            for (int i=0; i<indices_of_external_lines_count; i++) {
                float Bx1 = lines[indices_of_external_lines[i]].x1;
                float By1 = lines[indices_of_external_lines[i]].y1;
                float Bx2 = lines[indices_of_external_lines[i]].x2;
                float By2 = lines[indices_of_external_lines[i]].y2;            
                //println(i);
                //calculate intersection
                float bx = Ax2 - Ax1;
                float by = Ay2 - Ay1;
                float dx = Bx2 - Bx1;
                float dy = By2 - By1;     
                float b_dot_d_perp = bx*dy - by*dx;
                float cx = Bx1-Ax1; 
                float cy = By1-Ay1;
                float t = (cx*dy - cy*dx) / b_dot_d_perp; 

                float ix = Ax1+t*bx;
                float iy = Ay1+t*by;

                if ( get_dist(ix, iy, target_x, target_y) < current_distance) {
                    closest_x = ix;
                    closest_y = iy;
                    current_distance = get_dist(ix, iy, target_x, target_y);
                }
            }
            pushMatrix();
            ellipseMode(CENTER);
            fill(0, 0, 255);
            stroke(0, 0, 255);
            ellipse(closest_x, closest_y, 4, 4);
            popMatrix();
            //these are top right and top left of petals - which is which?
            
            //for each petal, get the points
            for(int k=0; k<1; k++){
                
              //get angle from inner left/right points to center
              
              
              //if angle of outer points is BETWEEN these, then this is a candidate petal 
              //be sure to account for 2PI-0 wraparound!
              
              //if angle is closer to left, it's outer left, otherwise inner left
              
              pushMatrix();
            ellipseMode(CENTER);
            fill(0, 255, 255);
            stroke(0, 255, 255);
            ellipse(petal_diamonds[k].petal_left_inner_x, petal_diamonds[k].petal_left_inner_y, 8, 8);
            stroke(0,255,0);
            fill(0,255,0);
            ellipse(petal_diamonds[k].petal_right_inner_x, petal_diamonds[k].petal_right_inner_y, 8, 8);
            popMatrix();
                
            }
            
            
            

            //make new line between A and B points
            lines[lines_count] = new Line();
            lines[lines_count].init(target_x, target_y, closest_x, closest_y);
            indices_of_diagonal_extensions[indices_of_diagonal_extensions_count++] = lines_count;
            lines_count++;
        }
    }

    void connect_intersections_between_circles() {
        //clockwise
        for (int i=0; i<external_points_count; i++) {
            lines[lines_count] = new Line();
            lines[lines_count].init(middle_circle_intersections_x[i], 
            middle_circle_intersections_y[i], 
            inner_circle_intersections_x[(i+1)%external_points_count], 
            inner_circle_intersections_y[(i+1)%external_points_count]);
            indices_of_diagonal_lines[indices_of_diagonal_lines_count++] = lines_count;
            lines_count++;
        }

        //counter-clockwise
        for (int i=0; i<external_points_count; i++) {
            lines[lines_count] = new Line();
            lines[lines_count].init(middle_circle_intersections_x[(i+1)%external_points_count], 
            middle_circle_intersections_y[(i+1)%external_points_count], 
            inner_circle_intersections_x[i], 
            inner_circle_intersections_y[i]);
            indices_of_diagonal_lines[indices_of_diagonal_lines_count++] = lines_count;
            lines_count++;
        }
    }

    void get_intersections() {
        //between lines and middle circle - just every so many radians, 
        //but would really be done with circle/line intersection
        for (int i=0; i<external_points_count; i++) {
            middle_circle_intersections_x[i] = middle_radius*cos(d_rad*i) + xpos;   
            middle_circle_intersections_y[i] = middle_radius*sin(d_rad*i) + ypos; 
            inner_circle_intersections_x[i] = inner_radius*cos(d_rad*i) + xpos;   
            inner_circle_intersections_y[i] = inner_radius*sin(d_rad*i) + ypos;

//            pushMatrix();
//            ellipseMode(CENTER);
//            fill(0, 0, 255);
//            stroke(0, 0, 255);
//            ellipse(middle_circle_intersections_x[i], middle_circle_intersections_y[i], 4, 4);
//            popMatrix();
            //this is both diamond top and petal bottom right - DONT KNOW IF i IS RIGHT, and petal bottom left of the NEXT petal
            petal_diamonds[i].diamond_outer_x = middle_circle_intersections_x[i];
            petal_diamonds[i].diamond_outer_y = middle_circle_intersections_y[i];
            petal_diamonds[i].petal_right_inner_x = middle_circle_intersections_x[i];
            petal_diamonds[i].petal_right_inner_y = middle_circle_intersections_y[i];
            petal_diamonds[(i+1)%num_petals].petal_left_inner_x = middle_circle_intersections_x[i];
            petal_diamonds[(i+1)%num_petals].petal_left_inner_y = middle_circle_intersections_y[i];            
            
//            pushMatrix();
//            ellipseMode(CENTER);
//            fill(0, 0, 255);
//            stroke(0, 0, 255);
//            ellipse(inner_circle_intersections_x[i], inner_circle_intersections_y[i], 4, 4);
//            popMatrix();
            //these are the bottom of the diamonds
            petal_diamonds[i].diamond_inner_x = inner_circle_intersections_x[i];
            petal_diamonds[i].diamond_inner_y = inner_circle_intersections_y[i];
            
        }
    }


    void connect_center_to_external() {
        for (int i=0; i<external_points_count; i++) {
            lines[lines_count] = new Line();
            lines[lines_count].init(xpos, 
            ypos, 
            external_points_x[i], 
            external_points_y[i]);
            indices_of_radial_lines[indices_of_radial_lines_count++] = lines_count;
            lines_count++;
        }
    }


    void place_external_points(int _count) {
        external_points_count = _count;

        //space points evenly around the circl
        d_rad = 2*PI/external_points_count;
        float r = 0;
        for (int i=0;i < external_points_count; i++) {
            external_points_x[i] = outer_circle.radius * cos(r) + outer_circle.xpos;
            external_points_y[i] = outer_circle.radius * sin(r) + outer_circle.ypos;
            r += d_rad;
        }
    }

    void connect_external_every_n(int _count) {

        //make new lines
        for (int i=0; i< external_points_count; i++) {

            lines[lines_count] = new Line();
            lines[lines_count].init(external_points_x[i%external_points_count], 
            external_points_y[i%external_points_count], 
            external_points_x[(i+_count)%external_points_count], 
            external_points_y[(i+_count)%external_points_count]);
            indices_of_external_lines[indices_of_external_lines_count++] = lines_count;
            lines_count++;
        }
    }
}

