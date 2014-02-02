Rosette rosette;

void setup() {

    size(800, 600);
    background(240);
    smooth();
    rosette = new Rosette(12,2);

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

