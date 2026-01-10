// SimulationEvacuation.pde
ArrayList<Agent> crowd;
Room room;
ArrayList<Obstacle> obstacles;
PGraphics traces; 

int startTime;
int finalTime = 0;
boolean finished = false;
boolean isStarted = false; // Nouvelle variable pour contrôler le départ
int maxObstacles = 5;

void setup() {
  size(800, 500);
  room = new Room(new PVector(0, height/2), 60);
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
  isStarted = false; // On attend l'appui sur Espace à chaque reset
  
  for (int i = 0; i < 60; i++) {
    float xAleatoire = random(20, width - 20);
    float yAleatoire = random(20, height - 20);
    crowd.add(new Agent(xAleatoire, yAleatoire));
  }
  
  startTime = millis();
  finished = false;
  finalTime = 0;
}

void draw() {
  background(245);
  image(traces, 0, 0);
  
  // Le chrono ne tourne que si la simulation a démarré
  int currentTime = 0;
  if (isStarted) {
    currentTime = finished ? finalTime : millis() - startTime;
  }
  
  if (!finished && isStarted && crowd.isEmpty()) {
    finished = true;
    finalTime = millis() - startTime;
  }

  if (mousePressed && obstacles.size() > 0) {
    obstacles.get(obstacles.size()-1).setPosition(mouseX, mouseY);
  }
  
  room.display();
  for (Obstacle obs : obstacles) {
    obs.display();
  }
  
  traces.beginDraw();
  traces.stroke(0, 100, 255, 10); 
  for (int i = crowd.size()-1; i >= 0; i--) {
    Agent a = crowd.get(i);
    
    if (isStarted) {
      PVector prevPos = a.copyPos(); // Utilise une copie pour la trace
      a.run(crowd, obstacles, room);
      traces.line(prevPos.x, prevPos.y, a.pos.x, a.pos.y);
    } else {
      a.display(); // On affiche juste les agents sans les faire bouger
    }
    
    if (room.hasExited(a.pos)) {
      crowd.remove(i);
    }
  }
  traces.endDraw();
  
  // Interface
  fill(0);
  textSize(14);
  text("Temps: " + (currentTime / 1000.0) + " s", 10, 20);
  text("Agents: " + crowd.size(), 10, 40);
  
  if (!isStarted) {
    fill(255, 0, 0);
    textAlign(CENTER);
    textSize(20);
    text("APPUYEZ SUR ESPACE POUR LANCER L'ÉVACUATION", width/2, height - 80);
    textAlign(LEFT);
  }
  
  fill(0);
  textSize(12);
  text("[R] Reset | [C] Effacer Tout | [0-3] Obstacles", 10, height - 20);
}

void keyPressed() {
  if (key == ' ') {
    if (!isStarted) {
      isStarted = true;
      startTime = millis(); // On déclenche le chrono au moment de l'appui
    }
  }
  
  if (key == 'r' || key == 'R') resetSimulation();
  
  if (key == 'c' || key == 'C') {
    obstacles.clear();
    traces.beginDraw();
    traces.clear();
    traces.endDraw();
    resetSimulation();
  }
  
  if (obstacles.size() < maxObstacles) {
    if (key == '0') obstacles.add(new Obstacle(mouseX, mouseY, 20, 0));
    if (key == '1') obstacles.add(new Obstacle(mouseX, mouseY, 20, 1));
    if (key == '2') obstacles.add(new Obstacle(mouseX, mouseY, 20, 2));
    if (key == '3') obstacles.add(new Obstacle(mouseX, mouseY, 20, 3));
  }
}
