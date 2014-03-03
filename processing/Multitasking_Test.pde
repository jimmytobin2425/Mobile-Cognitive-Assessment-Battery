

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
String url = "/logMTData";
String videoFilename = "wm3.webm";
boolean displayed = false;
boolean bound = false;
ArrayList<BoardObj> toDisplay;


//Javascript Interface

interface JavaScript {
  void logData(String url, String data, String dataID);
  void displayVideo(String filename);
  void hideVideo();
}

void bindJavascript(JavaScript js) {
  bound = true;
  javascript = js;
}

void setup() {
  size(screen.width,screen.height);
  bg = loadImage("../images/patients-background.png");
  //instructions = loadImage("../images/selfrating-example.png");
  clickableObjs = new ArrayList<ClickableObj>();
  questions = new ArrayList<String>();
  answers = new ArrayList<Integer>();
  shuffled = new ArrayList<Integer>();
  toDisplay = new ArrayList<toDisplay>();
  
  //populateQs();
  //shuffleQs();
  fill(0);
  stroke(100);
}


void mouseClicked(){
  ClickableObj obj = findMouseSelect(mouseX, mouseY);
  if(obj != null) obj.click();
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
    if (obj.inBounds(x, y)) return obj;
  }
  return null;
}

//Screens
void begin(){
  //title
  textAlign(CENTER, BOTTOM);
  fill(0);
  textSize(64);
  text("Multitasking", 0, height*.05, width, height*.2);
  //instructions
  textSize(32);
  text("During this test, you will have to keep track of two things at once. You must remember 3 letters while counting backwards by 3's.", 0, height*.175, width, height*.125);
  //image or video
  //image(instructions, width*.25, height*.25, width*.5, height*.5);
  //start button
  if(!displayed&&bound){
    displayed = true;
    javascript.displayVideo(videoFilename);
  } 
  PracticeButton practiceButton = new PracticeButton();
  practiceButton.display();
  //noLoop();
}

void nextQuestion(){
  //getNextQuestionIndex
  if(!shuffled.isEmpty()){
    curIndex = shuffled.remove(0);
    String questionText = questions.get(curIndex);
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
  redraw();
  noLoop();
  fill(0);
  textAlign(CENTER, BOTTOM);
  textSize(48);
  text("Thank you. Your results have been saved.", 0, height*.4, width, height*.3);

}

void waitingScreen(){
  toDisplay.clear();
  redraw();
  noLoop();
  fill(0);
  textAlign(CENTER, BOTTOM);
  textSize(48);
  text("Please wait while we save your data...", 0, height*.4, width, height*.3);

}


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
  return nfc(questions.size()-shuffled.size()+1);
}

void logDataReceived(String dataID){

  if (dataID.equals("-1")){
    clickableObjs.clear()
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

class Button extends ClickableObj{
  String displayText;
  int padding_y = 5;

  Button(){
    objHeight = 44;
    objWidth = 150;
  }

  void display(){
    fill(0);
    rect(xpos, ypos, objWidth, objHeight+2*padding_y, 10);
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(24);
    text(displayText, xpos, ypos, objWidth, objHeight);

  }
};

class PracticeButton extends Button{
  PracticeButton(){
    displayText = "Practice";
    xpos = (width-objWidth)/2;
    ypos = (int)height*.76;
  }

  void click(){
    begun = true;
    clickableObjs.clear();
    javascript.hideVideo();
    //practiceRound();
  }
};
/*
class StartButton extends Button{

  StartButton(){
    displayText = "Start";
    xpos = (width-objWidth)/2;
    ypos = (int)height*.76;
  }
  
  void click(){
    begun = true;
    clickableObjs.clear()
    nextQuestion();
  }
};


class AnswerButton extends Button{
  String pointValue;

  AnswerButton(String ansText, String points){
    displayText = ansText;
    pointValue = points;
  }

  void click(){
    sendData(pointValue);
    nextQuestion();
  } 
};


class ButtonBar extends BoardObj{
  int buttonMargin = 20;
  AnswerButton never;
  AnswerButton sometimes;
  AnswerButton often;

  ButtonBar(){
    never = new AnswerButton("Never", "0");
    sometimes = new AnswerButton("Sometimes", "1");
    often = new AnswerButton("Often", "2");
    //Set buttons' x's and y's
    int barWidth = never.objWidth*3+buttonMargin*3;
    never.xpos = (width-barWidth)/2;
    sometimes.xpos = never.xpos+never.objWidth+buttonMargin;
    often.xpos = sometimes.xpos+sometimes.objWidth+buttonMargin;
    never.ypos = sometimes.ypos = often.ypos = height*.6;
  }

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
    fill(0);
    textAlign(CENTER, BOTTOM);
    textSize(48);
    text(question, 0, height*.4, width, height*.3);
    buttons.display();
  }
};

*/
