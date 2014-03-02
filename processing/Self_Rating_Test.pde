

//Images
PImage bg;
PImage instructions;

//Global Variables
ArrayList<String> questions;
ArrayList<Integer> answers;
ArrayList<ClickableObj> clickableObjs;
ArrayList<Integer> shuffled;
int curIndex;
boolean begun = false;
String url = "/logSRTdata";

ArrayList<BoardObj> toDisplay;

//Javascript Interface

interface JavaScript {
  void logData(String url, String data, String dataID);
}

void bindJavascript(JavaScript js) {
  javascript = js;
}

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
  shuffleQs();
  
  stroke(255,0,0);
  
}



void mouseClicked(){
  CLickableObj obj = findMouseSelect(mouseX, mouseY);
  if(obj != null) obj.click();
  redraw();
  noLoop();
}


void draw(){
  image(bg, 0, 0, width, height);
  if (!begun){
    begin();
  }
  for(BoardObj obj : toDisplay){
    obj.display();
  }
}



ClickableObj findMouseSelect(int x, int y){
  for(ClickableObj obj : clickableObjs){
    //println("Mouse clicked at ("+x+","+y+")");
    if (obj.inBounds(x, y)) return obj;
  }
  return null;
}

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

void shuffleQs(){
  ArrayList<Integer> temp = new ArrayList<Integer>();
  for(int i=0; i<questions.size();i++){
    temp.add(i);
  }
  while(shuffled.size()<questions.size()){
    int tempRand = (int)random(temp.size());
    shuffled.add(temp.remove(tempRand));
  }
}

//Screens
void begin(){
  //title
  textAlign(CENTER, BOTTOM);
  textSize(32);
  text("Self Rating Test", 0, height*.05, width, height*.1);
  //instructions
  textSize(14);
  text("Read each statement presented and select the appropriate rating", 0, height*.175, width, height*.05);
  //image or video
  image(instructions, width*.25, height*.25, width*.5, height*.5);
  //start button
  //StartButton startButton = new StartButton();
}
/*
void nextQuestion(){
  //getNextQuestionIndex
  if(!shuffled.isEmpty()){
    curIndex = shuffled.remove(0);
    String questionText = questions[curIndex];
    //setNextQuestionText
    Question nextQuestion = new Question(questionText);
    //createNextQuestion
    toDisplay.clear();
    toDisplay.add(nextQuestion);
  }else{
    waitingScreen();
  }
}

void finalScreen(){
  toDisplay.clear();
  text(question, width*.2, height*.4, width*.6, height*.3);

}

void waitingScreen(){
  toDisplay.clear();
  text(question, width*.2, height*.4, width*.6, height*.3);
}
*/

//
//Talking with JavaScript
//
void sendData(String points){
  if(javascript!=null){
    String data = createData(points);
    String dataID = createDataId();
    javascript.logData(url, data, dataID);
  }
}

String createData(String points){
  return "question="+curIndex+"&points="+points;
}

String createDataId(){
  return Integer.toString(questions.size()-shuffled.size()+1);
}

void logDataReceived(String dataID){
  if (dataID.equals("-1")){
    finalScreen();
  }
}


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
};

/*

class Button extends ClickableObj{
  String displayText;
  int x;
  int y;

  Button(){
    objHeight = 30;
    objWidth = 50;
  }

 
  void display(){
    pushStyle(); 
      fill(0);
      rect(x, y, objWidth, objHeight, 10);
      fill(255);
      textAlign(CENTER, CENTER);
      textSize(24);
      text(displayText, x, y, objWidth, objHeight);
    popStyle();
  }
};

class StartButton extends Button{
  
  StartButton(){
    displayText = "Start";
  }
  
  @Override
  click(){
    begun = true;
    nextQuestion();
  }
};

class AnswerButton extends Button{
  String pointValue;

  AnswerButton(String text, String points){
    displayText = text;
    pointValue = points;
  }

  @Override
  click(){
    sendData(pointValue);
  } 
};

class ButtonBar extends BoardObj{
  int buttonMargin = 10;
  AnswerButton never;
  AnswerButton sometimes;
  AnswerButton often;

  ButtonBar(){
    AnswerButton never = new AnswerButton("Never", "0");
    AnswerButton sometimes = new AnswerButton("Sometimes", "1");
    AnswerButton often = new AnswerButton("Often", "2");
    //Set buttons' x's and y's
    int barWidth = never.objWidth*3+buttonMargin*3;
    never.x = (width-barWidth)/2;
    sometimes.x = never.x+never.objWidth+buttonMargin;
    often.x = sometimes.x+sometimes.objWidth+buttonMargin;
    never.y = sometimes.y = often.y = height*.8;
  }

  @Override
  void display(){
    never.display();
    sometimes.display();
    often.display();
  }
};

class Question extends BoardObj{
  String question;
  ButtonBar buttons;

  Question(String questionText){
    question = questionText;
    buttons = new ButtonBar();
  }


  void display(){
    pushStyle();
      textAlign(CENTER, BOTTOM);
      fontSize(48);
      text(question, width*.2, height*.4, width*.6, height*.3);
    popStyle();
    buttons.display();
  }
};

*/

