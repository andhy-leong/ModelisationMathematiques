ArrayList<Agent> crowd;
Room room;
ArrayList<Obstacle> obstacles; // Obstacles utilisateur
PGraphics traces; 
FlowField flowField;
ArrayList<PVector> safeZones;

// Interaction
Obstacle selectedObstacle = null;
PVector selectedExit = null;
PVector selectedSafeZone = null;
boolean isDragging = false;
float viewOffset = 0; 

int startTime;
int finalTime = 0;
boolean finished = false;
boolean isStarted = false; 
boolean debug = false;
int maxObstacles = 100;

float xExit = 200;
float yExit = 400;


void setup() {
  size(1200, 800);
  // Pièce centrée
  room = new Room(200, 150, 800, 500, 60); 
  room.addExit(xExit, yExit); 
  
  safeZones = new ArrayList<PVector>();
  safeZones.add(new PVector(100, 400));
  
  obstacles = new ArrayList<Obstacle>();
  obstacles.add(new Obstacle(xExit, float(args[0]) + yExit, float(args[1]), 2)); 

  flowField = new FlowField();
  updateSimulation(); // Fonction centrale de mise à jour
  
  crowd = new ArrayList<Agent>();
  traces = createGraphics(width, height);
  traces.beginDraw(); traces.background(245, 0); traces.endDraw();
  
  resetSimulation();
}

// Fonction utilitaire pour regrouper TOUS les obstacles (Murs + User)
ArrayList<Obstacle> getAllObstacles() {
  ArrayList<Obstacle> all = new ArrayList<Obstacle>();
  all.addAll(obstacles);
  all.addAll(room.wallObstacles); // On ajoute les murs comme obstacles
  return all;
}

void updateSimulation() {
  // On recalcule le FlowField en prenant en compte les murs et les obstacles
  flowField.generate(getAllObstacles(), room);
}

void resetSimulation() {
  crowd.clear();
  isStarted = false; 
  for (int i = 0; i < 100; i++) {
    float ax = random(room.x + 20, room.x + room.w - 20);
    float ay = random(room.y + 20, room.y + room.h - 20);
    crowd.add(new Agent(ax, ay));
  }
  startTime = millis();
  finished = false;
  finalTime = 0;
}

void draw() {
  background(245);
  image(traces, 0, 0);
  
  int currentTime = isStarted ? (finished ? finalTime : millis() - startTime) : 0;
  boolean allOut = true;
  for(Agent a : crowd) if (!a.escaped) { allOut = false; break; }
  if (!finished && isStarted && allOut) { finished = true; finalTime = millis() - startTime; }
  
  if (isDragging) updateSimulation();
  if (debug) flowField.display();
  
  room.display(); // Affiche les murs
  for (Obstacle obs : obstacles) obs.display(); // Affiche les cubes
  
  for (PVector sz : safeZones) {
    fill(0, 150, 0); noStroke(); ellipse(sz.x, sz.y, 40, 40);
    fill(255); textAlign(CENTER, CENTER); textSize(10); text("EXIT", sz.x, sz.y);
  }
  
  noFill(); stroke(255, 0, 0); strokeWeight(3);
  if (selectedExit != null) ellipse(selectedExit.x, selectedExit.y, 25, 25);
  if (selectedSafeZone != null) ellipse(selectedSafeZone.x, selectedSafeZone.y, 45, 45);
  
  traces.beginDraw(); traces.stroke(0, 100, 255, 12);
  
  // On récupère la liste complète UNE FOIS par frame
  ArrayList<Obstacle> allObs = getAllObstacles();
  
  for (int i = crowd.size()-1; i >= 0; i--) {
    Agent a = crowd.get(i);
    if (isStarted) {
      PVector prevPos = a.pos.copy();
      PVector target = getClosestSafeZone(a.pos);
      // On passe TOUT aux agents
      a.run(crowd, flowField, allObs, room, target);
      if (!a.escaped) traces.line(prevPos.x, prevPos.y, a.pos.x, a.pos.y);
    } else {
      a.display();
    }
  }
  traces.endDraw();
  
  fill(0); textSize(14); textAlign(LEFT);
  text("Temps: " + (currentTime / 1000.0) + " s", 15, 25);
  text("Agents: " + crowd.size(), 15, 45);
}

PVector getClosestSafeZone(PVector pos) {
  if (safeZones.isEmpty()) return new PVector(100, height/2);
  PVector best = safeZones.get(0);
  float minDist = PVector.dist(pos, best);
  for(PVector sz : safeZones) {
    float d = PVector.dist(pos, sz);
    if(d < minDist) { minDist = d; best = sz; }
  }
  return best;
}

void mousePressed() {
  selectedExit = room.getExitUnderMouse(mouseX, mouseY);
  if (selectedExit == null) {
    selectedSafeZone = null;
    for(PVector sz : safeZones) if(dist(mouseX, mouseY, sz.x, sz.y) < 20) { selectedSafeZone = sz; break; }
  }
  if (selectedExit == null && selectedSafeZone == null) {
    if (selectedObstacle != null) selectedObstacle.isSelected = false;
    selectedObstacle = null;
    for (int i = obstacles.size()-1; i >= 0; i--) {
      Obstacle obs = obstacles.get(i);
      if (obs.contains(mouseX, mouseY)) { selectedObstacle = obs; obs.isSelected = true; break; }
    }
  }
  if (selectedExit != null || selectedObstacle != null || selectedSafeZone != null) isDragging = true;
}

void mouseDragged() {
  if (isDragging) {
    if (selectedObstacle != null) selectedObstacle.setPosition(mouseX, mouseY);
    else if (selectedExit != null) { 
      selectedExit.set(mouseX, mouseY); 
      // Si on bouge une porte, il faut régénérer les murs
      room.updateWalls(); 
    }
    else if (selectedSafeZone != null) selectedSafeZone.set(mouseX, mouseY);
  }
}

void mouseReleased() { isDragging = false; updateSimulation(); }

void mouseWheel(MouseEvent event) {
  if (selectedObstacle != null) {
    selectedObstacle.angle += event.getCount() * (PI/18);
    updateSimulation();
  }
}

void keyPressed() {
  boolean mustUpdate = false;
  if (key == ' ') { isStarted = true; startTime = millis(); }
  if (key == 'r' || key == 'R') resetSimulation();
  if (key == 'd' || key == 'D') debug = !debug;
  if (key == 'c' || key == 'C') {
    obstacles.clear(); room.exits.clear(); room.addExit(200, 400); 
    safeZones.clear(); safeZones.add(new PVector(100, 400));
    traces.beginDraw(); traces.clear(); traces.endDraw();
    mustUpdate = true; resetSimulation();
  }
  if (obstacles.size() < maxObstacles) {
    if (key == '0') { obstacles.add(new Obstacle(mouseX, mouseY, 20, 0)); mustUpdate = true; }
    if (key == '1') { obstacles.add(new Obstacle(mouseX, mouseY, 20, 1)); mustUpdate = true; }
  }
  if (key == 's' || key == 'S') { room.addExit(mouseX, mouseY); mustUpdate = true; }
  if (key == 'z' || key == 'Z') { safeZones.add(new PVector(mouseX, mouseY)); }
  if (key == BACKSPACE || key == DELETE) {
    if (selectedObstacle != null) { obstacles.remove(selectedObstacle); selectedObstacle = null; mustUpdate = true; }
    if (selectedSafeZone != null && safeZones.size() > 1) { safeZones.remove(selectedSafeZone); selectedSafeZone = null; }
  }
  if (mustUpdate) updateSimulation();
}
