//Images
PImage bg;
PImage instructions;

//Global Variables
ArrayList<String> questions;
ArrayList<Integer> answers;
ArrayList<ClickableObj> clickableObjs;
ArrayList<Integer> shuffled;
int index;
boolean begun = false;

//ArrayList<BoardObj> toDisplay;

void setup() {
  size(screen.width,screen.height);
  bg = loadImage("../images/patients-background.png");
  instructions = loadImage("../images/selfrating-example.png");
  clickableObjs = new ArrayList<ClickableObj>();
  questions = new ArrayList<String>();
  answers = new ArrayList<Integer>();
  shuffled = new ArrayList<Integer>();
  toDisplay = new ArrayList<toDisplay>();

  populateQs();
  
  index = 0;
  stroke(255,0,0);
  
}

void mouseClicked(){
  //CLickableObj obj = findMouseSelect(mouseX, mouseY);
  //if(obj != null) obj.click();
  if(javascript!=null){
      javascript.showXYCoordinates(mouseX, mouseY);
  }
  redraw();
  noLoop();
  begun = true;
}


void draw(){
  image(bg, 0, 0, width, height);
  if (!begun){
    begin();
  }
}


/*
ClickableObj findMouseSelect(int x, int y){
  for(ClickableObj obj : clickableObjs){
    //println("Mouse clicked at ("+x+","+y+")");
    if (obj.inBounds(x, y)) return obj;
  }
  return null;
}
*/

void populateQs(){
  questions.add("I have trouble remembering new things.");
  questions.add("It is difficult for me to start a task.");
  questions.add("My thinking is slow.");
  questions.add("My memory is worse than other people my age.");
  questions.add("I am forgetful.");
  questions.add("I have trouble keeping track of what I'm doing.");
  questions.add("It's difficult for me to do more than one thing at a time.");
  questions.add("I say or do things without thinking of the consequences.");
  questions.add("I have trouble changing from one activity or idea to another.");
  questions.add("I am upset by changes in my routine.");
  questions.add("It's hard for me to think of more than one way to solve a problem.");
  questions.add("I have trouble thinking of things to do with my free time.");
  questions.add("It's difficult for me to finish things that I've started.");
  questions.add("I have trouble concentrating.");
  questions.add("I am confused by other people's reactions to things I say or do.");
  questions.add("I have a short attention span.");
  questions.add("I tend to overreact even to small things.");
  questions.add("I am easily upset.");
  questions.add("It is difficult for me to express myself.");
  questions.add("I have trouble finding the right word or words.");
  questions.add("I engage in aerobic exercise");
  questions.add("I try to learn new things");
  questions.add("I try to develop new interests or hobbies");
  questions.add("I eat healthy and follow a nutritious diet");
  questions.add("I participate in social groups or clubs");
  questions.add("I try to stay mentally active.");
  questions.add("My work skills are impaired (mark never if unemployed)");
  questions.add("My social skills are impaired");
  questions.add("My leisure activites are impaired");
  questions.add("My home skills (cooking, finances, etc) are impaired");
  questions.add("I have difficulty sleeping at night");
  questions.add("I have physical pain that interferes with daily activiites");
  questions.add("I have been physically active throughout my life");
}

//Screens
void begin(){
  //title
  textAlign(CENTER, BOTTOM);
  textSize(height*.1);
  text("Self Rating Test", 0, height*.05, width, height*.1);
  //instructions
  textSize(height*.05);
  text("Read each statement presented and select the appropriate rating", 0, height*.175, width, height*.05)
  //image or video
  image(instructions, width*.25, height*.25, width*.5, height*.5)
  //start button
  //StartButton startButton = new StartButton();
}

/*
void nextQuestion(){
  
}
*/

//Javascript Interface


interface JavaScript {
  void showXYCoordinates(int x, int y);
}

void bindJavascript(JavaScript js) {
  javascript = js;
}

/*
//Classes
class BoardObj{
  void display(){}
};

class ClickableObj extends BoardObj{
  int xpos;
  int ypos;
  int objHeight;
  int objWidth;
  
  ClickableObj(){
    clickableObjs.add(this);
  }

  int getX(){
    return xpos;
  }

  int getY(){
    return ypos;
  }

  boolean inBounds(int x, int y){
    return (x<=xpos+objWidth&&x>=xpos&&y<=ypos+objHeight&&y>=ypos);
  }
  
  void click(){}
}



class Button extends ClickableObj{
  String displayText
  int buttonWidth;
  int buttonHeight;
 
  display(){
    //black box with text
    text(displayText)
  }
}

class StartButton extends Button{
  displayText = "Start"
  display(){}
  
  click(){
    begun = true;
  }
}

class SometimesButton extends Button{
  displayText = "Sometimes"
  click(){
    
  }
  
}

class NeverButton extends Button{
  displayText = "Never"
  click(){
    
  }
}

class OftenButton extends Button{
  displayText = "Often"
  click(){
    
  }
}

*/

