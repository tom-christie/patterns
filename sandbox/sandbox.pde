//to do
// - make it so you can select how far into external lines the petal tips go
// - fix issue with (12,3) [or any (even,odd)] where petals stop at FIRST contact rather than the actual line they should be contacting
// - fix interaction issue where (12,5), (16,6), etc is fucked up - problem is that the inner circle radii are switched, so should account for this
// - TILE THE PLANE!

Rosette rosette;

void setup() {

    size(1200, 800);
    background(240);
    smooth();
    rosette = new Rosette(16,14,0);// max is ~60 at this point

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

