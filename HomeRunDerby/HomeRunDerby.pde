//STARTUP OPTIONS: Modify these to modify the parameters of the game.

final float UNIT_STEP = .05; //timestep for each frame
final int FENCE_HEIGHT = 30; //height of the fence
final int FENCE_DISTANCE = 325; //distance from home plate to fence
final int STARTING_PLAYER_ID = 0; //defines which character the player will be using on startup

//GAME VARIABLES: Modify these to change the entire program, not just the game parameters.

final float BOTTOM = 700; //y-level of the ground
float target[] = {random(0, FENCE_DISTANCE), BOTTOM - 20 - random(4*FENCE_HEIGHT), random(0, FENCE_DISTANCE), 20}; //x, y, z, radius
ArrayList<Float> path = new ArrayList<Float>();
int index = 0;
int wait_time = 0;
int player_id = STARTING_PLAYER_ID;
String options[] = {"Little Leaguer", "College Player", "MLB Player", "Babe Ruth", "God"};
float speed_min_options[] = {5, 15, 25, 28, 55};
float speed_max_options[] = {20, 34, 38, 44, 100};
float speed_min = speed_min_options[player_id];
float speed_max = speed_max_options[player_id];
float launch_speed = random(speed_min, speed_max);
float launch_vector[] = {launch_speed, -launch_speed, launch_speed};
float wind_factor[] = {random(-3, 3), random(-3, 3)};
boolean prep_phase = true; //True if user is choosing the vector; false if user is watching result
boolean landed = false;
boolean first_hit = false;
boolean contact = false;
boolean hit_balloon = false;
boolean fair = true;
boolean speed_set = false;
float fair_ball_coordinates[] = {0, BOTTOM, 0};
int home_runs = 0;
projectile Ball = new projectile();
float lastDistance = 0;
int toggle = 1;
int toggle_frequency = 3;
//PGraphics stadium;

class projectile {
  private float mass = 0.1455;
  private float velocity[] = {1, 1, 1};
  private float position[] = {0, BOTTOM - 9, 0};
  
  public void updatePosition() {
    if ((contact == true) && (first_hit == false)) {
      if (toggle == 1) { 
        path.add(position[0]);
        path.add(position[1]);
        path.add(position[2]);
        index++;
        toggle+=toggle_frequency;
      } else {
        toggle--;
      }
    }
    if ((calculateDistance(position[0], position[2], 0, 0) >= FENCE_DISTANCE - 5) && (calculateDistance(position[0], position[2], 0, 0) <= FENCE_DISTANCE + 5) && (position[1] >= (BOTTOM - FENCE_HEIGHT)) && (position[0] >= 0) && (position[2] >= 0)) {
      velocity[0] = -velocity[0];
      velocity[2] = -velocity[2];
      if (first_hit == false) {
        first_hit = true;
        fair_ball_coordinates[0] = Ball.getPosition(0);
        fair_ball_coordinates[1] = Ball.getPosition(1);
        fair_ball_coordinates[2] = Ball.getPosition(2);
        lastDistance = FENCE_DISTANCE;
      }
    } if (calculateDistance3D(position[0], position[1], position[2], target[0], target[1], target[2]) <= target[3]) {
      if (!hit_balloon)
        home_runs++;
      hit_balloon = true;
    }
    for (int i = 0; i < 3; i++) {
      position[i] += (velocity[i] * UNIT_STEP);
    }
    if (position[1] >= BOTTOM) {
      if (first_hit == false) {
        first_hit = true;
        fair_ball_coordinates[0] = Ball.getPosition(0);
        fair_ball_coordinates[1] = Ball.getPosition(1);
        fair_ball_coordinates[2] = Ball.getPosition(2);
        lastDistance = calculateDistance(0, 0, Ball.getPosition(0), Ball.getPosition(2));
        if ((Ball.getPosition(0) < 0) || (Ball.getPosition(2) < 0)) {
          fair = false; 
        }
      }
      position[1] = BOTTOM;
      if ((velocity[1] < 1) && (velocity[1] > -1)) {
        velocity[1] = 0; 
      } else {
        velocity[1] = -velocity[1]/2;
      }
      if (velocity[0] > 2) {
        velocity[0] -= 50 * UNIT_STEP;
      } else if (velocity[0] < -2) {
        velocity[0] += 50 * UNIT_STEP;
      } else {
        velocity[0] = 0; 
      }
      if (velocity[2] > 2) {
        velocity[2] -= 50 * UNIT_STEP;
      } else if (velocity[2] < -2) {
        velocity[2] += 50 * UNIT_STEP;
      } else {
        velocity[2] = 0; 
      }
    } 
    if (position[1] < BOTTOM) {
      velocity[1] += 9.8*UNIT_STEP;
    }
    if ((velocity[0] ==  0) && (velocity[1] == 0) && (velocity[2] == 0)) {
      landed = true;
    }
    velocity[0] += wind_factor[0] * UNIT_STEP;
    velocity[2] += wind_factor[1] * UNIT_STEP;
    stroke(255);
    translate(position[0], position[1], position[2]);
    sphere(2);
  }
  public void accelerate(float delta_v, int vector_index) {
    velocity[vector_index] += (delta_v * UNIT_STEP); 
  }
  public void setVelocity(float x, float y, float z) {
    velocity[0] = x;
    velocity[1] = y;
    velocity[2] = z;
  }
  public void setPosition(float x, float y, float z) {
    position[0] = x;
    position[1] = y;
    position[2] = z;
  }
  public float getPosition(int i) {
    return position[i];
  }
  public void setMass(float new_mass) {
    mass = new_mass; 
  }
  public float getMass() {
    return mass; 
  }
};

float calculateDistance(float x1, float y1, float x2, float y2) {
  float distance = 0;
  distance = sqrt(((x2 - x1)*(x2 - x1)) + ((y2 - y1)*(y2 - y1)));
  return distance;
}

float calculateDistance3D(float x1, float y1, float z1, float x2, float y2, float z2) {
   float distance = 0;
   distance = sqrt((((x1-x2)*(x1-x2))+((z1-z2)*(z1-z2))) + ((y1-y2)*(y1-y2)));
   return distance;
}

void drawFence() {
  for (int x = 0; x <= FENCE_DISTANCE*sqrt(2); x++) {
    for (int y = 0; y <= FENCE_HEIGHT; y++) {
      stroke(120);
      point(x, BOTTOM - y, sqrt((FENCE_DISTANCE*FENCE_DISTANCE)-(x*x)));
    }
  } for (int z = 0; z <= 350*sqrt(2); z++) {
    for (int y = 0; y <= FENCE_HEIGHT; y++) {
      stroke(120);
      point(sqrt((FENCE_DISTANCE*FENCE_DISTANCE)-(z*z)), BOTTOM - y, z);
    }
  }
}

void drawTarget() {
  if (!hit_balloon) {
    stroke(0, 0, 255);
    translate(target[0], target[1], target[2]);
    sphere(target[3]);
    translate(-target[0], -target[1], -target[2]);
  }
  stroke(0, 0, 255);
  translate(target[0], BOTTOM, target[2]);
  sphere(3);
  translate(-target[0], -BOTTOM, -target[2]);
}

void drawSpace() {
  //stadium.beginDraw();
  //Field
  stroke(255);
  line(0, BOTTOM, 0, FENCE_DISTANCE, BOTTOM, 0);
  stroke(255);
  drawFence();
  drawTarget();
  stroke(255);
  line(0, BOTTOM, FENCE_DISTANCE, 0, BOTTOM, 0);
  stroke(255);
  line(FENCE_DISTANCE, BOTTOM, 0, FENCE_DISTANCE, BOTTOM - FENCE_HEIGHT*8, 0);
  stroke(255);
  line(0, BOTTOM, FENCE_DISTANCE, 0, BOTTOM - FENCE_HEIGHT*8, FENCE_DISTANCE);
  stroke(255);
  line(0, BOTTOM, 5, 5, BOTTOM, 0);
  stroke(255);
  line(0, BOTTOM, 90, 90, BOTTOM, 90);
  stroke(255);
  line(90, BOTTOM, 0, 90, BOTTOM, 90);
  //stadium.endDraw();
}

void drawScoreboardAndLastBall() {
  for (int i = 0; i < 2; i++) {
    stroke(255, 0, 0);
    translate(fair_ball_coordinates[0], fair_ball_coordinates[1], fair_ball_coordinates[2]);
    sphere(2);
    translate(-fair_ball_coordinates[0], -fair_ball_coordinates[1], -fair_ball_coordinates[2]);
  }
  textSize(50);
  scale(-1, 1);
  text((int)lastDistance, 0, BOTTOM - 300, 100);
  scale(-1, 1);
  textSize(50);
  scale(-1, 1);
  text(home_runs, 0, BOTTOM - 400, 100);
  text(options[player_id], 0, BOTTOM - 500, 100);
  scale(-1, 1);
};

void reset() {
  prep_phase = true;
  if ((lastDistance > FENCE_DISTANCE) && (fair == true))
    home_runs++;
  contact = false;
  first_hit = false;
  landed = false;
  hit_balloon = false;
  fair = true;
  Ball.setPosition(60.5/sqrt(2), BOTTOM-10, 60.5/(sqrt(2)));
  Ball.setVelocity(-random(60, 72), 0, -random(60, 72));
  wait_time = 180;
  target[0] = random(0, FENCE_DISTANCE);
  target[1] = BOTTOM - target[3] - random(4*FENCE_HEIGHT);
  target[2] = random(0, FENCE_DISTANCE);
  speed_set = false;
  path.clear();
  index = 0;
}

void drawTrace() {
  for (int i = 0; i < index; i++) {
    stroke(255, 0, 0);
    point(path.get(3*i), path.get((3*i) + 1), path.get((3*i) + 2));
  }
}

void drawPath() {
  stroke(255, 255, 0);
  line(0, BOTTOM - 5, 0,  launch_vector[0], (BOTTOM - 5 + launch_vector[1]), launch_vector[2]);
  stroke(255, 255, 0);
  translate(launch_vector[0], BOTTOM, launch_vector[2]);
  sphere(2);
  translate(-launch_vector[0], -BOTTOM, -launch_vector[2]);
  stroke(0, 255, 0);
  line(launch_vector[0], BOTTOM, launch_vector[2], launch_vector[0] + (wind_factor[0]*3), BOTTOM, launch_vector[2] + (wind_factor[1]*3));
}

void keyPressed() {
  if (prep_phase) {
    if (keyCode == UP) {
      launch_vector[1]-=2; 
      launch_vector[0]-=2*sqrt(2);
      launch_vector[2]-=2*sqrt(2);
    } else if (keyCode == DOWN) {
      launch_vector[1]+=2;
      if (launch_vector[1] >= 0) {
        launch_vector[1] = 0;
      } else { 
        launch_vector[0]+=2*sqrt(2);
        launch_vector[2]+=2*sqrt(2);
      }
    } else if (keyCode == LEFT) {  //x is adjacent, z is opposite
      launch_vector[0]+=2;
      launch_vector[2]-=2;
    } else if (keyCode == RIGHT) {
      launch_vector[0]-=2;
      launch_vector[2]+=2;
    } else if ((keyCode == ENTER) || (keyCode == RETURN)) {
      prep_phase = false;
      wait_time = 180;
    } else if (keyCode == 49) {
      player_id = keyCode - 49;
      speed_set = false;
    } else if (keyCode == 50) {
      player_id = keyCode - 49;
      speed_set = false;
    } else if (keyCode == 51) {
      player_id = keyCode - 49;
      speed_set = false;
    } else if (keyCode == 52) {
      player_id = keyCode - 49;
      speed_set = false;
    } else if (keyCode == 53) {
      player_id = keyCode - 49;
      speed_set = false;
    } else if (keyCode == 87) {
      wind_factor[0] = random(-3, 3);
      wind_factor[1] = random(-3, 3);
    } else if (keyCode == 81) {
      exit();
    }
  }
  keyCode = 0;
}

void setup() {
  size(1000, 1000, P3D);
  Ball.setPosition(60.5/sqrt(2), BOTTOM-10, 60.5/(sqrt(2)));
  Ball.setVelocity(-random(60, 72), 0, -random(60, 72));
  camera(-500, 200, -500, 300, 500, 300, 0, 1, 0);
  //stadium = createGraphics(1000, 1000, P3D);
  //drawSpace();
}

void draw() {
  clear();
  drawSpace();
  //imageMode(CENTER);
  drawTrace();
  drawScoreboardAndLastBall();
  //image(stadium, 0, 0);
  wind_factor[0] += random(-1, 1) * UNIT_STEP;
  wind_factor[1] += random(-1, 1) * UNIT_STEP;
  if (wait_time == 0) {
    if (prep_phase) {
      if (!speed_set) {
        speed_min = speed_min_options[player_id];
        speed_max = speed_max_options[player_id];
        speed_set = true;
        launch_speed = random(speed_min, speed_max);
        launch_vector[0] = launch_speed;
        launch_vector[1] = -launch_speed;
        launch_vector[2] = launch_speed;
      }
      drawPath();
    } else {
      if ((Ball.getPosition(0) < 8) && (Ball.getPosition(2) < 8) && (!contact)) {
        for (int i = 0; i < 3; i++) {
          Ball.setVelocity(launch_vector[0], launch_vector[1], launch_vector[2]);
        }
        contact = true;
        Ball.setPosition(8.1, BOTTOM - 8.1, 8.1);
      }
      Ball.updatePosition();
    }
    if (landed == true) {
      reset();
    }
  } else {
    wait_time--; 
  }
}
