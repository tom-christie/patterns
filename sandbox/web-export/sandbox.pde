//to do
// - make it so you can select how far into external lines the petal tips go
// - fix issue with (12,3) [or any (even,odd)] where petals stop at FIRST contact rather than the actual line they should be contacting
// - fix interaction issue where (12,5), (16,6), etc is fucked up - problem is that the inner circle radii are switched, so should account for this
// - TILE THE PLANE!

Rosette rosette;

void setup() {

    size(600, 600);
    background(240);
    smooth();
    rosette = new Rosette(16,4,0);// max is ~60 at this point

}

void draw(){
    background(240);
     rosette.construct();
    rosette.draw();   
    
}

  
float get_dist(float x1, float y1, float x2, float y2) {
    return sqrt( pow(x1-x2, 2) + pow(y1-y2, 2)  );
}

void mouseDragged() {
    rosette.change_circle_size();
}


float[] get_intersection_of_lines(float Ax1, float Ay1, float Ax2, float Ay2, float Bx1, float By1, float Bx2, float By2) {
    float[] result = new float[2];

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
    result[0] = ix;
    result[1] = iy;
    return result;
}

class Circle {

    //defined in terms of center and radius

    float xpos, ypos, radius;
    color circle_color = color(255, 0, 0);

    float mouse_range = 5;
    
    boolean mouse_hovering;

    Circle() {
    }

    void init(float _xpos, float _ypos, float _radius) {
        xpos = _xpos;
        ypos = _ypos;
        radius = _radius;
        circle_color = color(255, 0, 0);
    }

    void draw() {
        mouseOver();
        pushMatrix();
        smooth();
        ellipseMode(CENTER);
        stroke(circle_color);
        strokeWeight(1);
        noFill();
        ellipse(xpos, ypos, 2*radius, 2*radius);
        popMatrix();
    }




    float distance_from_center(float x, float y) {
        return sqrt( pow(x-xpos, 2) + pow(y-ypos, 2));
    }

    void mouseOver() {

        float d = distance_from_center(mouseX, mouseY);
        if ( d < (radius + mouse_range) && d > (radius - mouse_range)) {
            circle_color = color(220, 87, 21);
            mouse_hovering = true;
        }
        else { 
            circle_color = color(0);
            mouse_hovering = false;
        }
    }
    
    void check_size_change(){
        
        if(mouse_hovering) radius = distance_from_center(mouseX,mouseY);
        
    }
    
}

class Line{
    //class to define a line from two points 
    //that extends off the end of the end of the screen
    //NOT a line segment
    //and keeps track of what it intersects with.
    
    //initially defined in terms of two points
    
    float x1, y1, x2, y2;
    
    float[][] intersections;
    
    Line(){ 
    }
    
    void init(float _x1, float _y1, float _x2, float _y2){
        x1 = _x1;
        y1 = _y1;
        x2 = _x2;
        y2 = _y2;
        
        intersections = new float[50][2];
        
    }
    
    void sort_intersections(){
        
        
    }
    
    
    void draw(){
        pushMatrix();
        smooth();
        stroke(0);
        strokeWeight(1);
        line(x1,y1,x2,y2);
        popMatrix();
    }

    void draw(color c){
        pushMatrix();
        smooth();
        stroke(c);
        strokeWeight(10);
        line(x1,y1,x2,y2);
        popMatrix();
    }
    

    
}


class PetalDiamond{
 //class for a petal and diamond (clockwise!), 
 //to hold coordinates of all the points found from them.

 //petal #i has diamond #i to the 

 int index; //which in order it is (0-n)
 
 //points
 float diamond_inner_x;//
 float diamond_inner_y;//
 float diamond_left_x;
 float diamond_left_y;
 float diamond_right_x;
 float diamond_right_y;
 float diamond_outer_x; //
 float diamond_outer_y; //
 
 float petal_inner_x;//
 float petal_inner_y;//
 float petal_left_inner_x;//
 float petal_left_inner_y;//
 float petal_right_inner_x; //
 float petal_right_inner_y; //
 float petal_left_outer_x;//
 float petal_left_outer_y;//
 float petal_right_outer_x;//
 float petal_right_outer_y;//
 float petal_outer_x;//
 float petal_outer_y;//
 
 
 PetalDiamond(){
    
 }

 void init(int _index){
     index = _index;
 }    
    
void draw_petal(){
    
    pushMatrix();
    noStroke();
    fill(0,100);
    beginShape();
    vertex(petal_inner_x,petal_inner_y);
    vertex(petal_left_inner_x, petal_left_inner_y);
    vertex(petal_left_outer_x,petal_left_outer_y);
    vertex(petal_outer_x,petal_outer_y);
    vertex(petal_right_outer_x,petal_right_outer_y);
    vertex(petal_right_inner_x, petal_right_inner_y);
    vertex(petal_inner_x,petal_inner_y);
    endShape();
    popMatrix();
    
}


void draw_diamond(){
   
    pushMatrix();
    noStroke();
    fill(100,100);
    beginShape();
     vertex(diamond_inner_x,diamond_inner_y);
     vertex(diamond_left_x,diamond_left_y);
     vertex(diamond_outer_x,diamond_outer_y);
     vertex(diamond_right_x,diamond_right_y);
     vertex(diamond_inner_x,diamond_inner_y);
    endShape();
    popMatrix();
    
}
    
    
}
class Rosette {


    Circle outer_circle, middle_circle, inner_circle;
    Line[] lines;
    PetalDiamond[] petal_diamonds;
    int lines_count;  //actually count-1, i.e. index of last one
    float xpos, ypos;
    float d_rad;
    boolean mouse_hovering;
    float mouse_radius = 10;

    int[] indices_of_external_lines;
    int[] indices_of_radial_lines;
    int[] indices_of_diagonal_lines;
    int[] indices_of_diagonal_extensions;
    int indices_of_external_lines_count;
    int indices_of_radial_lines_count;
    int indices_of_diagonal_lines_count;
    int indices_of_diagonal_extensions_count;

    int connect_every_n;
    int num_petals;
    int petal_extent; //how far out the petal goes into the outer lines

    //points on the radius of the circle
    float[] external_points_x = new float[400];
    float[] external_points_y = new float[400];
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


    ////////////////////////////////////////////////////////////////////////
    ///////////////////////////// Initialization ///////////////////////////
    ////////////////////////////////////////////////////////////////////////

    Rosette(int _num_petals, int _connect_every_n, int _petal_extent) {

        num_petals = _num_petals;
        connect_every_n = _connect_every_n;
        petal_extent = _petal_extent;

        xpos = width/2;
        ypos = height/2;

        inner_radius = 42;
        middle_radius = 100;
        outer_radius = 200;

        outer_circle = new Circle();
        outer_circle.init(xpos, ypos, outer_radius);

        middle_circle = new Circle();
        middle_circle.init(xpos, ypos, middle_radius);

        inner_circle = new Circle();
        inner_circle.init(xpos, ypos, inner_radius);
    }


    void construct() {

        lines = new Line[1000];
        lines_count = 0;

        indices_of_external_lines = new int[500];
        indices_of_radial_lines = new int[500];
        indices_of_diagonal_lines = new int[500];
        indices_of_diagonal_extensions = new int[500];
        indices_of_external_lines_count = 0;
        indices_of_radial_lines_count = 0;
        indices_of_diagonal_lines_count = 0;
        indices_of_diagonal_extensions_count = 0;

        middle_circle_intersections_x = new float[500];
        middle_circle_intersections_y = new float[500];
        inner_circle_intersections_x = new float[500];
        inner_circle_intersections_y = new float[500];
        outer_lines_intersections_x = new float[2000];
        outer_lines_intersections_y = new float[2000];
        outer_lines_intersections_count = 0;

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
        //create bottom 2/3 of petals
        connect_intersections_between_circles();

        //get top corner of petals
        get_intersections_between_rays_and_outer_lines();

        //get bottom point of petals
        get_intersections_between_rays();
        get_outer_lines_intersections();

        //get tip of petal
        get_tip_of_petal();
    }


    ////////////////////////////////////////////////////////////////////////
    ///////////////////////////// Drawing //////////////////////////////////
    ////////////////////////////////////////////////////////////////////////

    void draw() {

        outer_circle.draw();
        inner_circle.draw();
        middle_circle.draw();
        
        //draw all lines
        for (int i=0; i<lines_count; i++) {
            lines[i].draw();
        }
        draw_rosette_lines();
        
        draw_petals_and_diamonds();
        draw_star();
        
        mouseOver();
    }

    void draw_petals_and_diamonds() {

        for (int i=0; i<num_petals; i++) {
            petal_diamonds[i].draw_petal();
            petal_diamonds[i].draw_diamond();
        }
    }

    void draw_star() {
        beginShape();
        fill(255, 100);
        for (int i=0; i<num_petals; i++) {
            vertex( petal_diamonds[i].diamond_inner_x, petal_diamonds[i].diamond_inner_y);
            vertex( petal_diamonds[i].diamond_right_x, petal_diamonds[i].diamond_right_y);
        }   
        endShape();
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


    ////////////////////////////////////////////////////////////////////////
    ///////////////////////////// Construction /////////////////////////////
    ////////////////////////////////////////////////////////////////////////

    void get_intersections_between_rays() {
        for (int i=0; i<num_petals; i++) {

            int line1 = indices_of_diagonal_lines[(num_petals+(i-1))%num_petals];
            int line2 = indices_of_diagonal_lines[(num_petals+(i-1))%num_petals + num_petals];
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
            petal_diamonds[(num_petals+i-1)%num_petals].diamond_right_x = intersection[0];
            petal_diamonds[(num_petals+i-1)%num_petals].diamond_right_y = intersection[1];
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

            //hold results to sort
            float[] distances = new float[1000];
            float[] xcoords = new float[1000];
            float[] ycoords = new float[1000];
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
            if (j < num_petals) {
                petal_diamonds[j].petal_right_outer_x = closest_x;
                petal_diamonds[j].petal_right_outer_y = closest_y;
            }
            else {
                //have to add 2 here so the intersection will be associated with the right diamond 
                //(has to do with the order in which the diagonal lines were drawn)
                petal_diamonds[(j+2)%num_petals].petal_left_outer_x = closest_x;
                petal_diamonds[(j+2)%num_petals].petal_left_outer_y = closest_y;
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


        //between lines and middle circle - just every so many radians, 
        //but would really be done with circle/line intersection
        for (int i=0; i<external_points_count; i++) {
            middle_circle_intersections_x[i] = middle_circle.radius*cos(d_rad*i) + xpos;   
            middle_circle_intersections_y[i] = middle_circle.radius*sin(d_rad*i) + ypos; 
            inner_circle_intersections_x[i] = inner_circle.radius*cos(d_rad*i) + xpos;   
            inner_circle_intersections_y[i] = inner_circle.radius*sin(d_rad*i) + ypos;

            //this is both diamond top and petal bottom right - DONT KNOW IF i IS RIGHT, and petal bottom left of the NEXT petal
            petal_diamonds[i].diamond_outer_x = middle_circle_intersections_x[i];
            petal_diamonds[i].diamond_outer_y = middle_circle_intersections_y[i];
            petal_diamonds[i].petal_right_inner_x = middle_circle_intersections_x[i];
            petal_diamonds[i].petal_right_inner_y = middle_circle_intersections_y[i];
            petal_diamonds[(i+1)%num_petals].petal_left_inner_x = middle_circle_intersections_x[i];
            petal_diamonds[(i+1)%num_petals].petal_left_inner_y = middle_circle_intersections_y[i];            

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


    ////////////////////////////////////////////////////////////////////////
    ///////////////////////////// Interaction/ /////////////////////////////
    ////////////////////////////////////////////////////////////////////////

    void mouseOver() {

        float d = get_dist(mouseX, mouseY, xpos, ypos);
        color circle_color;
        if ( d < mouse_radius ) {
            circle_color = color(220, 87, 21);
            mouse_hovering = true;
            pushMatrix();
            fill(circle_color);
            stroke(circle_color);
            ellipse(xpos, ypos, 10, 10);
            popMatrix();
        }
    }

    void change_circle_size() {

        inner_circle.check_size_change();
        middle_circle.check_size_change();
        outer_circle.check_size_change();

        if (mouse_hovering && get_dist(mouseX, mouseY, xpos, ypos) < mouse_radius) {

            ellipse(xpos, ypos, 10, 10);
            xpos = mouseX;
            ypos = mouseY;


            outer_circle.init(xpos, ypos, outer_circle.radius);
            middle_circle.init(xpos, ypos, middle_circle.radius);
            inner_circle.init(xpos, ypos, inner_circle.radius);
        }
    }
}

class Space{
    
 //class variables
 
    
    
    
 Space(){
  
 }   
 
 void init(){
     
     
 }
    
}

