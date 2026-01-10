// SimulationEvacuation.pde
ArrayList<Agent> crowd;
Room room;
ArrayList<Obstacle> obstacles;

int startTime;
int finalTime = 0;
boolean finished = false;
int maxObstacles = 5;

void setup() {
  size(800, 500);
  // Sortie au milieu du mur de gauche
  room = new Room(new PVector(0, height/2), 60);
  obstacles = new ArrayList<Obstacle>();
  crowd = new ArrayList<Agent>();
  
  resetSimulation();
}

void resetSimulation() {
  crowd.clear();
  // Génération de 60 agents dans la zone de droite
  for (int i = 0; i < 60; i++) {
    crowd.add(new Agent(random(400, width-20), random(20, height-20)));
  }
  startTime = millis();
  finished = false;
  finalTime = 0;
}

void draw() {
  background(245);
  
  // --- Gestion du Chronomètre ---
  int currentTime = 0;
  if (!finished) {
    currentTime = millis() - startTime;
    if (crowd.isEmpty()) {
      finished = true;
      finalTime = currentTime;
    }
  } else {
    currentTime = finalTime;
  }

  // --- Interaction Obstacles ---
  // Permet de déplacer le dernier obstacle ajouté avec la souris
  if (mousePressed && obstacles.size() > 0) {
    obstacles.get(obstacles.size()-1).setPosition(mouseX, mouseY);
  }
  
  // --- Affichage ---
  room.display();
  for (Obstacle obs : obstacles) {
    obs.display();
  }
  
  // Mise à jour et affichage de la foule
  for (int i = crowd.size()-1; i >= 0; i--) {
    Agent a = crowd.get(i);
    a.run(crowd, obstacles, room);
    if (room.hasExited(a.pos)) {
      crowd.remove(i);
    }
  }
  
  // --- Interface Utilisateur ---
  fill(0);
  textSize(14);
  textAlign(LEFT);
  text("Temps: " + (currentTime / 1000.0) + " s", 10, 20);
  text("Agents restants: " + crowd.size(), 10, 40);
  text("Obstacles: " + obstacles.size() + "/" + maxObstacles, 10, 60);
  
  fill(100);
  text("Touches: [0]Cercle [1]Carré [2]Rectangle [3]Triangle", 10, height - 40);
  text("[R] Reset simulation | [C] Effacer obstacles", 10, height - 20);
}

void keyPressed() {
  if (key == 'r' || key == 'R') resetSimulation();
  if (key == 'c' || key == 'C') obstacles.clear();
  
  // Ajout d'obstacles selon la touche pressée
  if (obstacles.size() < maxObstacles) {
    if (key == '0') obstacles.add(new Obstacle(mouseX, mouseY, 20, 0));
    if (key == '1') obstacles.add(new Obstacle(mouseX, mouseY, 20, 1));
    if (key == '2') obstacles.add(new Obstacle(mouseX, mouseY, 20, 2));
    if (key == '3') obstacles.add(new Obstacle(mouseX, mouseY, 20, 3));
  }
}
