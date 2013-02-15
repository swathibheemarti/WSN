import de.bezier.data.*;

//XlsReader reference
XlsReader reader;

int w = 600, h = 600,            //Screen Size  
    gridSize = 40,               //Grid Size
    noOfSesnors = 40,            //No of Sensors watching agents 
    t = 1,                       //Time variable
    noOfAgents = 200,            //No of agents -- this is coming from Matlab
    noOfAgentSets = 100,         //No of agent Sets (time laps)-- this is coming from Matlab
    noOfAgentProperties = 10,    //No of agent properties, X, Y, S, D, T, p(x,y), q(s,d), s(p(x,y)), 
                                 //s(q(s,d)), Suspiciousness
    noOfStandingAgents = 20,     //No of agents not moving
    noOfSuspiciousAgents = 0;
    

//10 sets of 200 Agents data, data points are 
//X, Y, S, D, T, p(x,y), q(s,d), s(p(x,y)), s(q(s,d)), Suspiciousness (0 or 1)
double AgentData[][][] = new double[noOfAgentSets][noOfAgents][noOfAgentProperties];   

int[] sensorX = new int[noOfSesnors], sensorY = new int[noOfSesnors], //Sensors Location Array
      personX = new int[noOfAgents], personY = new int[noOfAgents],   //Agents Locations Array
      standingPersonX = new int[noOfStandingAgents], //Standing Agents Location Array
      standingPersonY = new int[noOfStandingAgents]; //Standing Agents Location Array

PImage imgSensor;

PImage[] imgPeople = new PImage[noOfAgents];  //Image for moving agents
PImage[] imgPeopleWalkingLeft = new PImage[noOfAgents]; //Image for agents moving opposite direction
PImage[] suspiciousAgents = new PImage[noOfAgents]; //Suspicious agent Image
PImage[] suspiciousAgentWalkingLeft = new PImage[noOfAgents]; //Suspicious agent Image

PImage[] imgStandingPeople = new PImage[noOfStandingAgents]; //Image for standing agents





void setup(){  
  
  size(w, h);  
  
  reader = new XlsReader(this, "AgentsData.xls");
  
  imgSensor = loadImage("sensor.jpg");
  
  LoadAgentData(); 
  //PrintAgentData();
  //noOfSuspiciousAgents = GetNoOfSuspiciousAgents();
  //suspiciousAgents = new PImage[noOfSuspiciousAgents];
  
  setupSensorLocations();  
  setupPeopleStartingLocation();  
}

void PrintAgentData(){
  
    for(int j=0; j<noOfAgents; j++){
      for(int k=0; k<noOfAgentProperties; k++){
        print(AgentData[0][j][k] + "   ");
      }
      println();
    }
}

//10 sets of 200 Agents data, data points are 
//X, Y, S, D, T, p(x,y), q(s,d), s(p(x,y)), s(q(s,d)), Suspiciousness (0 or 1)
void LoadAgentData(){
  
  //Ignore Header Row
  reader.nextRow(); 
  
  int rowindex = 0;
  int i = 0, j = 0;
     
  while(reader.hasMoreRows()){
    
    if(rowindex >= noOfAgentSets * noOfAgents)
      break;
    
    reader.nextRow();
    rowindex++;
    
    for(int k = 1; k <= 9; k++){
      
      AgentData[i][j][k-1] = Math.floor( reader.getFloat(reader.getRowNum(), k) * 100000 ) / 100000.0000;
            
    }
          
    //Suspicious
    if(reader.getString(reader.getRowNum(), 10).toLowerCase().contains("y")){     
      AgentData[i][j][9] = 1;
    }
    else{
      AgentData[i][j][9] = 0;
    }
    
    j++;
    if(j >= noOfAgents){
      j = 0;
      i++;
    }    
  }  
}

/*
  xGrid and yGrid are generated randomly, 
  xGrid, yGrid represent random cell (grid) for placement of sensor
  x & y co-ordinate is calculated based onthe grid locatin as 
  x = gridnumber * size of grid + (som value to place the sensor middle of the grid)
*/

void setupSensorLocations(){
  int xGrid = 0, yGrid = 0;
  
  for(int s = 0; s < noOfSesnors; s++){
    
    xGrid = int(random(0, w/gridSize));
    yGrid = int(random(0, h/gridSize));
    
    sensorX[s] = (xGrid * gridSize) + (gridSize / 4);
    sensorY[s] = (yGrid * gridSize) + (gridSize / 4); 
  }
}

int GetNoOfSuspiciousAgents(){
  
  int noOfSuspiciousAgents = 0;
  
  for(int i = 0; i < noOfAgents; i++){
    if(AgentData[0][i][9] == 1){
      noOfSuspiciousAgents++;
    }
  }
  
  return noOfSuspiciousAgents;
}


/*
  People's x & y co-ordinates are set randomly initially
  to create the scene 0 of the animation, then from t = o to t
  their x coordinate is changed based on a randomly calculated value. 
*/
void setupPeopleStartingLocation(){
  
  for(int i = 0; i < noOfAgents; i++){
    imgPeople[i] = loadImage("man_walking_right.png");     
    imgPeopleWalkingLeft[i] = loadImage("man_walking_left.png");
    suspiciousAgents[i] = loadImage("man_walking_Right_red.png");
    suspiciousAgentWalkingLeft[i] = loadImage("man_walking_left_red.png");
  }
  
  for(int m = 0; m < noOfAgents; m++){    
    //AgentData[0:first set of agent data][m:agent no][0:X location]
    personX[m] = ((Double)AgentData[0][m][0]).intValue(); 
    //AgentData[0:first set of agent data][m:agent no][1:Y location]
    personY[m] = ((Double)AgentData[0][m][1]).intValue(); 
  }  
  
  //Set up standing peoples initial location randomly
  for(int j = 0; j < noOfStandingAgents; j++){
    imgStandingPeople[j] = loadImage("man_standing_green.png");
    standingPersonX[j] = int(random(gridSize, w - gridSize));
    standingPersonY[j] = int(random(gridSize, h - gridSize));
  }  
}

void draw(){
  
  //Background is set to white
  background(255);  
  
  delay(100);
  
  drawGrid();  
  drawRandomSensors();
  drawPeople();  
  t++;  
  
  if(t >= noOfAgentSets){
    noLoop();
    /*
    delay(5000);
    t = 1;
    loop();
    */
  }  
}



/*
  Grid lines are drawn horizontally and vertically
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

/*
  Based on the previously populated sensorX and sensorY arrays,
  sensors are drawn
*/
void drawRandomSensors(){
  
  for(int s = 0; s < noOfSesnors; s++){     
     image(imgSensor, sensorX[s], sensorY[s], 10, 10);    
  }  
}

/*
  People's x & y co-ordinates are set randomly initially
  to create the scene 0 of the animation, then from t = o to t
  their x coordinate is changed based on a randomly calculated value. 
*/
void drawPeople(){  
  
  for(int m = 0; m < noOfAgents; m++){
    
    //AgentData[0:first set of agent data][m:agent no][0:X location]
    personX[m] = ((Double) AgentData[t][m][0]).intValue();
    
    //AgentData[0:first set of agent data][m:agent no][1:Y location]
    //NOTE : We are ignoring Y co-ordinate changes from Matlab for now
    //       So Agents only move in Left to Right or Right to Left 
    //       at what ever Y location they were initially
    personY[m] = ((Double) AgentData[0][m][1]).intValue();
    
    //Drawing a line for Agent[m] from location @t=0 to t=current
    for(int i = 0; i < t; i++)
    {
      
      line(((Double) AgentData[i][m][0]).intValue(),
           ((Double) AgentData[0][m][1]).intValue(),
           ((Double) AgentData[i][m][0]).intValue(),
           ((Double) AgentData[0][m][1]).intValue());
    }
    
    //Placing moving agent in location personX[m], personY[m]
    
    
    
    if(personX[m] < ((Double) AgentData[t - 1][m][0]).intValue()){      
      if(AgentData[0][m][9] == 1){
        image(suspiciousAgentWalkingLeft[m], personX[m], personY[m], 10, 25);
      }
      else{
        image(imgPeopleWalkingLeft[m], personX[m], personY[m], 10, 25);
      }      
    }
    else{
      if(AgentData[0][m][9] == 1){
        image(suspiciousAgents[m], personX[m], personY[m], 10, 25);
      }
      else{
        image(imgPeople[m], personX[m], personY[m], 10, 25);
      }      
    }        
  }  
  
  //Place standing people
  for(int j = 0; j < noOfStandingAgents; j++){    
    image(imgStandingPeople[j], standingPersonX[j], standingPersonY[j], 15, 30);    
  }   
}



