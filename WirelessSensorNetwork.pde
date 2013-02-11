import de.bezier.data.*;

XlsReader reader;

int w = 400, h = 400,  
    gridSize = 40, noOfSesnors = 40,  
    t = 1, noOfAgents = 200, noOfAgentSets = 100, 
    noOfAgentProperties = 10;
    

//10 sets of 200 Agents data, data points are 
//X, Y, S, D, T, p(x,y), q(s,d), s(p(x,y)), s(q(s,d)), Suspiciousness (0 or 1)
double AgentData[][][] = new double[noOfAgentSets][noOfAgents][noOfAgentProperties];   

int[] sensorX = new int[noOfSesnors], sensorY = new int[noOfSesnors], 
      personX = new int[noOfAgents], personY = new int[noOfAgents];

PImage img;
PImage[] imgPeople = new PImage[noOfAgents];

void setup(){  
  
  size(w, h);  
  
  reader = new XlsReader(this, "AgentsData200lap100.xls");
  
  LoadAgentData(); 
  //PrintAgentData();
  
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

/*
  People's x & y co-ordinates are set randomly initially
  to create the scene 0 of the animation, then from t = o to t
  their x coordinate is changed based on a randomly calculated value. 
*/
void setupPeopleStartingLocation(){
  
  for(int i = 0; i < noOfAgents; i++){
    imgPeople[i] = loadImage("man_walking.png");  
  }
  
  for(int m = 0; m < noOfAgents; m++){    
    //AgentData[0:first set of agent data][m:agent no][0:X location]
    personX[m] = ((Double)AgentData[0][m][0]).intValue(); 
    //AgentData[0:first set of agent data][m:agent no][1:Y location]
    personY[m] = ((Double)AgentData[0][m][1]).intValue(); 
  }  
}

void draw(){
  
  //Background is set to white
  background(255);  
  
  delay(1000);
  
  drawGrid();  
  drawRandomSensors();
  drawPeople();  
  t++;  
  
  if(t >= noOfAgentSets){
    noLoop();
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
  img = loadImage("sensor.jpg");    
  
  for(int s = 0; s < noOfSesnors; s++){     
     image(img, sensorX[s], sensorY[s], 25, 10);    
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
    personY[m] = ((Double) AgentData[t][m][1]).intValue();
    
    image(imgPeople[m], personX[m], personY[m], 10, 25);    
  }  
  
}



