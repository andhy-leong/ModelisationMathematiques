// SimulationEvacuation.pde
ArrayList<Agent> crowd;
Room room;
ArrayList<Obstacle> obstacles;
PGraphics traces; // Calque pour les traces

int startTime;
int finalTime = 0;
boolean finished = false;
int maxObstacles = 5;

void setup() {
  size(800, 500);
  room = new Room(new PVector(0, height/2), 60);
  obstacles = new ArrayList<Obstacle>();
  crowd = new ArrayList<Agent>();
  
  // Initialiser le calque de traces
  traces = createGraphics(width, height);
  traces.beginDraw();
  traces.background(245, 0); // Transparent au début
  traces.endDraw();
  
  resetSimulation();
}

void resetSimulation() {
  crowd.clear();
  // On ne vide pas les traces ici pour voir l'accumulation, 
  // sauf si vous appuyez sur 'C'
  for (int i = 0; i < 60; i++) {
    crowd.add(new Agent(random(400, width-20), random(20, height-20)));
  }
  startTime = millis();
  finished = false;
  finalTime = 0;
}

void draw() {
  background(245);
  
  // 1. Afficher les traces en premier (sous les agents)
  image(traces, 0, 0);
  
  // 2. Chronomètre
  int currentTime = finished ? finalTime : millis() - startTime;
  if (!finished && crowd.isEmpty()) {
    finished = true;
    finalTime = currentTime;
  }

  // 3. Interaction
  if (mousePressed && obstacles.size() > 0) {
    obstacles.get(obstacles.size()-1).setPosition(mouseX, mouseY);
  }
  
  // 4. Murs et Obstacles
  room.display();
  for (Obstacle obs : obstacles) {
    obs.display();
  }
  
  // 5. Mise à jour des agents et dessin des traces
  traces.beginDraw();
  traces.stroke(0, 150, 255, 15); // Bleu très transparent
  for (int i = crowd.size()-1; i >= 0; i--) {
    Agent a = crowd.get(i);
    
    // On dessine une ligne entre l'ancienne et la nouvelle position
    PVector prevPos = a.pos.copy();
    a.run(crowd, obstacles, room);
    traces.line(prevPos.x, prevPos.y, a.pos.x, a.pos.y);
    
    if (room.hasExited(a.pos)) {
      crowd.remove(i);
    }
  }
  traces.endDraw();
  
  // 6. UI
  fill(0);
  textSize(14);
  text("Temps: " + (currentTime / 1000.0) + " s", 10, 20);
  text("Agents: " + crowd.size(), 10, 40);
  text("Obstacles: " + obstacles.size() + "/5", 10, 60);
  text("[R] Reset Agents | [C] Effacer Tout (Traces + Obs)", 10, height - 20);
}

void keyPressed() {
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
