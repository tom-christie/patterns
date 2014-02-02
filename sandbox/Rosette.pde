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
    float[] outer_lines_intersections_x;
    float[] outer_lines_intersections_y;
    int outer_lines_intersections_count;


    Rosette(int _num_petals, int _connect_every_n) {

        num_petals = _num_petals;
        connect_every_n = _connect_every_n;
    }


    void construct() {

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
        outer_lines_intersections_x = new float[200];
        outer_lines_intersections_y = new float[200];
        outer_lines_intersections_count = 0;
        inner_radius = 42;
        middle_radius = 100;
        outer_radius = 200;

        outer_circle = new Circle();
        outer_circle.init(xpos, ypos, outer_radius);

        middle_circle = new Circle();
        middle_circle.init(xpos, ypos, middle_radius);

        inner_circle = new Circle();
        inner_circle.init(xpos, ypos, inner_radius);

        petal_diamonds = new PetalDiamond[num_petals];
        for (int i=0; i<num_petals; i++) {
            petal_diamonds[i] = new PetalDiamond();
            petal_diamonds[i].init(i);
        }


        place_external_points(num_petals);

        //draw lines around exterior
        connect_external_every_n(connect_every_n);

        //lines from center to border
        create_radial_lines();

        //calculate intersections between radial lines and inner circles
        get_circle_line_intersections();
        //        
        //        //create bottom 2/3 of petals
        connect_intersections_between_circles();
        //        //        
        //        //        //get top corners of petals
        get_intersections_between_rays_and_outer_lines();

        //get bottom point of petals
        get_intersections_between_rays();

        //
        get_outer_lines_intersections();

        //get tip of petal
        get_tip_of_petal();
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

        draw_petals_and_diamonds();
        draw_star();
    }



    void draw_petals_and_diamonds() {

        for (int i=0; i<num_petals; i++) {
            petal_diamonds[i].draw_petal();
            petal_diamonds[i].draw_diamond();
        }
    }

    void draw_star() {
        beginShape();
        fill(255,100);
        for (int i=0; i<num_petals; i++) {
            vertex( petal_diamonds[i].diamond_inner_x, petal_diamonds[i].diamond_inner_y);
            vertex( petal_diamonds[i].diamond_right_x, petal_diamonds[i].diamond_right_y);
        }   
        endShape();
    }

    void get_intersections_between_rays() {
        for (int i=0; i<num_petals; i++) {

            int line1 = indices_of_diagonal_lines[(16+(i-1))%16];
            //if(i==0) lines[line1].draw(color(255,0,0));
            int line2 = indices_of_diagonal_lines[(16+(i-1))%16 + 16];
            //if(i==0) lines[line2].draw(color(255,0,0));
            float[] intersection = get_intersection_of_lines(lines[line1].x1, 
            lines[line1].y1, 
            lines[line1].x2, 
            lines[line1].y2, 
            lines[line2].x1, 
            lines[line2].y1, 
            lines[line2].x2, 
            lines[line2].y2);
            petal_diamonds[i].petal_inner_x = intersection[0];
            petal_diamonds[i].petal_inner_y = intersection[1];

            //THESE MIGHT BE BACKWARDS
            petal_diamonds[i].diamond_left_x = intersection[0];
            petal_diamonds[i].diamond_left_y = intersection[1];           
            petal_diamonds[(16+i-1)%16].diamond_right_x = intersection[0];
            petal_diamonds[(16+i-1)%16].diamond_right_y = intersection[1];
           // if (i==0) ellipse(intersection[0], intersection[1], 12, 12);
            // println(intersection);
        }
    }

    void get_tip_of_petal() {
        for (int i=0; i<num_petals; i++) {

            //get angle of left and right outer x,y
            float angle_left, angle_right;
            float x_left = petal_diamonds[i].petal_left_outer_x;
            float y_left = petal_diamonds[i].petal_left_outer_y;
            float x_right = petal_diamonds[i].petal_right_outer_x;
            float y_right = petal_diamonds[i].petal_right_outer_y;
            angle_left = atan2((y_left-ypos), (x_left-xpos));
            angle_right = atan2( (y_right-ypos), (x_right-xpos));
            //println(angle_left + " " + angle_right);

            //hold results to sort
            float[] distances = new float[10];
            float[] xcoords = new float[10];
            float[] ycoords = new float[10];
            int num_points = 0;

            //go through outer line intersections, and find the closest (eventually nth closest) one to the center
            for (int j=0; j<outer_lines_intersections_count; j++) {
                float xval = outer_lines_intersections_x[j];
                float yval = outer_lines_intersections_y[j];
                float angle = atan2((yval-ypos), (xval-xpos));

                if (angle > angle_left && angle < angle_right) {

                    distances[num_points] = get_dist(xval, yval, xpos, ypos);
                    xcoords[num_points] = xval;
                    ycoords[num_points] = yval;
                    num_points++;
                }
            }//end find points

            //sort the distances and coordinates using bubblesort
            for (int j=0; j<num_points-1; j++) {
                for (int k=j+1; k<num_points; k++) {
                    if ( distances[j] > distances[k]) {
                        float temp = distances[k];
                        distances[k] = distances[j];
                        distances[j] = temp;

                        temp = xcoords[k];
                        xcoords[k] = xcoords[j];
                        xcoords[j] = temp;

                        temp = ycoords[k];
                        ycoords[k] = ycoords[j];
                        ycoords[j] = temp;
                    }
                }
            }//end sort

            //this is where you'd do 1st, second, whatever;
            petal_diamonds[i].petal_outer_x = xcoords[0];
            petal_diamonds[i].petal_outer_y = ycoords[0];
            fill(255, 0, 0);
            //if(i==0)ellipse(xcoords[0],ycoords[0],10,10);
        }
    }


    void get_outer_lines_intersections() {
        int counter = 0;
        for (int i=0; i<indices_of_external_lines_count; i++) {
            for (int j=i+1; j<indices_of_external_lines_count; j++) {
                float[] intersection = new float[2];
                //println(i + " " + j);
                intersection = get_intersection_of_lines(lines[indices_of_external_lines[i]].x1, 
                lines[indices_of_external_lines[i]].y1, 
                lines[indices_of_external_lines[i]].x2, 
                lines[indices_of_external_lines[i]].y2, 
                lines[indices_of_external_lines[j]].x1, 
                lines[indices_of_external_lines[j]].y1, 
                lines[indices_of_external_lines[j]].x2, 
                lines[indices_of_external_lines[j]].y2);
                outer_lines_intersections_x[counter] = intersection[0];
                outer_lines_intersections_y[counter] = intersection[1];
                counter++;
                outer_lines_intersections_count++;
                //put a red dot where the target is
            }
        }
    }







    void change_circle_size() {

        inner_circle.check_size_change();
        middle_circle.check_size_change();
        outer_circle.check_size_change();
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



    void get_intersections_between_rays_and_outer_lines() {

        //to test, pick the first diagonal and see what else it runs into
        for (int j=0; j<indices_of_diagonal_lines_count; j++) {
            //println(j);
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
                float[] intersection = new float[2];
                intersection = get_intersection_of_lines(Ax1, Ay1, Ax2, Ay2, Bx1, By1, Bx2, By2);
                float ix = intersection[0];
                float iy = intersection[1];

                if ( get_dist(ix, iy, target_x, target_y) < current_distance) {
                    closest_x = ix;
                    closest_y = iy;
                    current_distance = get_dist(ix, iy, target_x, target_y);
                }
            }
            //these are top right and top left of petals - which is which?
            if (j < 16) {
                petal_diamonds[j].petal_right_outer_x = closest_x;
                petal_diamonds[j].petal_right_outer_y = closest_y;
            }
            else {
                //have to add 2 here so the intersection will be associated with the right diamond 
                //(has to do with the order in which the diagonal lines were drawn)
                petal_diamonds[(j+2)%16].petal_left_outer_x = closest_x;
                petal_diamonds[(j+2)%16].petal_left_outer_y = closest_y;
            }


            //for each petal, get the points
            for (int k=0; k<1; k++) {

                //get angle from inner left/right points to center

                    //if angle of outer points is BETWEEN these, then this is a candidate petal 
                //be sure to account for 2PI-0 wraparound!

                //if angle is closer to left, it's outer left, otherwise inner left
                //
                //                pushMatrix();
                //                ellipseMode(CENTER);
                //                fill(0, 255, 255);
                //                stroke(0, 255, 255);
                //                ellipse(petal_diamonds[k].petal_left_inner_x, petal_diamonds[k].petal_left_inner_y, 8, 8);
                //                stroke(0, 255, 0);
                //                fill(0, 255, 0);
                //                ellipse(petal_diamonds[k].petal_right_inner_x, petal_diamonds[k].petal_right_inner_y, 8, 8);
                //
                //
                //
                //                fill(255, 0, 0);
                //                ellipse(petal_diamonds[k].petal_left_outer_x, petal_diamonds[k].petal_left_outer_y, 8, 8);
                //                fill(255, 255, 255);
                //                ellipse(petal_diamonds[k].petal_right_outer_x, petal_diamonds[k].petal_right_outer_y, 8, 8);

                //    popMatrix();

                //            
                // float petal_right_outer_x;
                // float petal_right_outer_y;
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






    void get_circle_line_intersections() {


        //        //between outer lines and other outer lines
        //        for (int i=0; i<indices_of_external_lines_count; i++) {
        //            for (int j=0; i<indices_of_external_lines_count; i++) {
        //
        //                //for each i line, find interesction with j line
        //                println(indices_of_external_lines);
        //            }
        //        }
        //
        //




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


    void create_radial_lines() {
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

