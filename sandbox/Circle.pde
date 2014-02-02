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

