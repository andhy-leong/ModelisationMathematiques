ArrayList<Agent> crowd;
Room room;
ArrayList<Obstacle> obstacles;
PGraphics traces; 

int startTime;
int finalTime = 0;
boolean finished = false;
boolean isStarted = false; 
int maxObstacles = 5;

void setup() {
  size(800, 500); // Taille fixe de la salle
  room = new Room(60); 
  room.addExit(0, height/2); // Sortie initiale mur gauche
  
  obstacles = new ArrayList<Obstacle>();
  crowd = new ArrayList<Agent>();
  
  traces = createGraphics(width, height);
  traces.beginDraw();
  traces.background(245, 0); 
  traces.endDraw();
  
  resetSimulation();
}

void resetSimulation() {
  crowd.clear();
  isStarted = false; 
  for (int i = 0; i < 60; i++) {
    crowd.add(new Agent(random(50, width - 50), random(50, height - 50)));
  }
  startTime = millis();
  finished = false;
  finalTime = 0;
}

void draw() {
  background(245);
  image(traces, 0, 0);
  
  int currentTime = isStarted ? (finished ? finalTime : millis() - startTime) : 0;
  if (!finished && isStarted && crowd.isEmpty()) {
    finished = true;
    finalTime = millis() - startTime;
  }

  room.display();
  for (Obstacle obs : obstacles) obs.display();
  
  traces.beginDraw();
  traces.stroke(0, 100, 255, 12); 
  for (int i = crowd.size()-1; i >= 0; i--) {
    Agent a = crowd.get(i);
    if (isStarted) {
      PVector prevPos = new PVector(a.pos.x, a.pos.y);
      a.run(crowd, obstacles, room);
      traces.line(prevPos.x, prevPos.y, a.pos.x, a.pos.y);
    } else {
      a.display();
    }
    if (room.hasExited(a.pos)) crowd.remove(i);
  }
  traces.endDraw();
  
  fill(0); textSize(14); textAlign(LEFT);
  text("Temps: " + (currentTime / 1000.0) + " s", 15, 25);
  text("Agents: " + crowd.size(), 15, 45);
  text("Sorties: " + room.exits.size(), 15, 65);
}

void keyPressed() {
  if (key == ' ') { isStarted = true; startTime = millis(); }
  if (key == 's' || key == 'S') room.addExit(mouseX, mouseY);
  if (key == 'r' || key == 'R') resetSimulation();
  if (key == 'c' || key == 'C') {
    obstacles.clear(); room.exits.clear(); room.addExit(0, height/2);
    traces.beginDraw(); traces.clear(); traces.endDraw();
    resetSimulation();
  }
  if (obstacles.size() < maxObstacles) {
    if (key == '0') obstacles.add(new Obstacle(mouseX, mouseY, 20, 0));
    if (key == '1') obstacles.add(new Obstacle(mouseX, mouseY, 20, 1));
    if (key == '2') obstacles.add(new Obstacle(mouseX, mouseY, 20, 2));
    if (key == '3') obstacles.add(new Obstacle(mouseX, mouseY, 20, 3));
  }
}
