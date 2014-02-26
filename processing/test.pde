ArrayList points;
PImage bg;
ArrayList getPoints() { return points; }

boolean finished = false;

void setup() {
  size(screen.width,screen.height);
  bg = loadImage("../images/patients-background.png");

  points = new ArrayList();

  stroke(255,0,0);
}

void draw() {
  image(bg, 0, 0, width, height);
  for(int p=0, end=points.size(); p < end; p++) {
    Point pt = (Point) points.get(p);
    if(p < end-1) {
    Point next = (Point) points.get(p+1);
    line(pt.x,pt.y,next.x,next.y); }
    pt.draw(); }
}

void mouseClicked() {
  points.add(new Point(mouseX,mouseY));
  if(javascript!=null){
      javascript.showXYCoordinates(mouseX, mouseY);
    }
  redraw();
  noLoop();
}

interface JavaScript {
  void showXYCoordinates(int x, int y);
}

void bindJavascript(JavaScript js) {
  javascript = js;
}

class Point {
  int x,y;
  Point(int x, int y) { this.x=x; this.y=y; }
  void draw() { ellipse(x,y,10,10); }
}