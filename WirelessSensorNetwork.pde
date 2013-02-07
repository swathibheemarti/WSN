int w = 640, h = 700, topBorder = 60, 
    gridSize = 40, noOfSesnors = 40,  
    noOfPeople = 40, t = 1;

int[] sensorX = new int[noOfSesnors], sensorY = new int[noOfSesnors], 
      personX = new int[noOfPeople], personY = new int[noOfPeople];

PImage img;
PImage[] imgPeople = new PImage[noOfPeople];

void setup(){  
  size(w, h);  
  
  setupSensorLocations();  
  setupPeopleStartingLocation();
}

void setupSensorLocations(){
  for(int s = 0; s < noOfSesnors; s++){
    sensorX[s] = int(random(gridSize, w - gridSize));
    sensorY[s] = int(random(gridSize, h - gridSize)); 
  }
}

void setupPeopleStartingLocation(){
  
  for(int i = 0; i < noOfPeople; i++){
    imgPeople[i] = loadImage("man_walking.png");  
  }
  
  for(int m = 0; m < noOfPeople; m++){    
    personX[m] = int(random(gridSize, w - gridSize));
    personY[m] = int(random(gridSize, h - gridSize));  
  }  
}

void draw(){
  background(255);  
  drawGrid();  
  drawRandomSensors();
  drawPeople();  
  t++;  
  
  if(t >= 1000){
    noLoop();
  }  
}

/* Not using this for now, 
   will add a border for instructions 
   at the bottom later 
void drawBorder(){
  rectMode(CORNER);
  strokeWeight(5);
  rect(0, topBorder, 640, h - topBorder);
  strokeWeight(1);  
}
*/

void drawGrid(){
  //horizontal lines
  for(int y = gridSize; y <= h; y += gridSize){
    line(0, y, w, y);
  }
  
  //vertical lines
  for(int x = 0; x <= w; x+=gridSize){
    line(x, 0, x, h);
  }  
}

void drawRandomSensors(){
  img = loadImage("sensor.jpg");    
  
  for(int s = 0; s < noOfSesnors; s++){     
     image(img, sensorX[s], sensorY[s], 25, 10);    
  }  
}

void drawPeople(){  
  for(int m = 0; m < noOfPeople; m++){
    
    int inc = int(random(0, 10));
    
    if(personX[m] + inc > w){
      personX[m] = int(random(gridSize, w - gridSize));
    }
    else{
      personX[m] = personX[m] + inc;
    }
    
    image(imgPeople[m], personX[m], personY[m], 10, 25);    
  }       
}



