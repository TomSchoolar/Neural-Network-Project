class Population {
  Dot[] dots;
  
  float fitnessSum;
  int gen = 1;
  
  int bestDot = 0;
  
  int minStep = 1000;
  
  Population(int size) {
    dots = new Dot[size];
    for (int i = 0;i<size;i++) {
      dots[i] = new Dot();
    }
  }
  
  void show() {
    for(int i = 1; i < dots.length; i++) {
      dots[i].show();
    }
    dots[0].show();
  }
  
  void update() {
    for(int i = 0; i<dots.length; i++) {
      if(dots[i].brain.step>minStep) {
        dots[i].dead = true;
      }
      else {
        dots[i].update();
      }
    }
  }
  
  void calculateFitness() {
    for(int i = 0; i<dots.length; i++) {
      dots[i].calculateFitness();
    }
  }
  
  boolean allDotsDead() {
    for(int i = 0; i<dots.length; i++) {
      if(!dots[i].dead && !dots[i].reachedGoal) {
        return false;
      }
    }
    return true;
  }
  
  void naturalSelection() {
    Dot[] newDots = new Dot[dots.length];
    setBestDot();
    calculateFitnessSum();
    
    newDots[0] = dots[bestDot].gimmeBaby();
    newDots[0].isBest = true;
    
    for(int i= 1; i<newDots.length; i++) {
      Dot parent = selectParent();
      
      newDots[i] = parent.gimmeBaby();
    }
    dots = newDots.clone();
    gen++;
  }
  
   void calculateFitnessSum() {

    fitnessSum = 0;
    for (int i = 0; i< dots.length; i++) {
      fitnessSum += dots[i].fitness;
    }
  }
  
   Dot selectParent() {

    float rand = random(fitnessSum);

    float runningSum = 0;

    for (int i = 0; i< dots.length; i++) {
      runningSum+= dots[i].fitness;
      if (runningSum > rand) {
        return dots[i];
      }
    }

    return null;
  }
  
  void mutateDemBabies() {

    for (int i = 1; i< dots.length; i++) {
      dots[i].brain.mutate();
    }
  }
  
  void setBestDot() {

    float max = 0;
    int maxIndex = 0;

    for (int i = 0; i< dots.length; i++) {
      if (dots[i].fitness > max) {
        max = dots[i].fitness;
        maxIndex = i;
      }
    }
  
  bestDot = maxIndex;
  
  if(dots[bestDot].reachedGoal) {
    minStep = dots[bestDot].brain.step;
    println("step: ",minStep);
  }
  }
}

class Dot {
  
  PVector pos;
  PVector vel;
  PVector acc;
  Brain brain;

  boolean dead = false;
  boolean reachedGoal = false;
  boolean isBest = false;//true if this dot is the best dot from the previous generation
  float fitness = 0;

  Dot() {

    brain = new Brain(1000);//new brain with 1000 instructions

    //start the dots at the bottom of the window with a no velocity or acceleration
    pos = new PVector(width/2, height- 10);
    vel = new PVector(0, 0);
    acc = new PVector(0, 0);
  }

  void show() {
    //if this dot is the best dot from the previous generation then draw it as a big green dot
    if (isBest) {
      
      fill(0, 255, 0);
      ellipse(pos.x, pos.y, 8, 8);
      
    } else {//all other dots are just smaller black dots
    
      fill(0);
      ellipse(pos.x, pos.y, 4, 4);
    }
  }
  
  void move() {

    if (brain.directions.length > brain.step) {//if there are still directions left then set the acceleration as the next PVector in the direcitons array

      acc = brain.directions[brain.step];
      brain.step++;

    } else {//if at the end of the directions array then the dot is dead

      dead = true;
    }
    //apply the acceleration and move the dot

    vel.add(acc);
    vel.limit(5);//not too fast
    pos.add(vel);
  }

  void update() {

    if (!dead && !reachedGoal) {

      move();

      if (pos.x< 2|| pos.y<2 || pos.x>width-2 || pos.y>height -2) {//if near the edges of the window then kill it 

        dead = true;
        
      } else if (dist(pos.x, pos.y, goal.x, goal.y) < 5) {//if reached goal
      
        reachedGoal = true;

      } else if (pos.x< 400 && pos.y < 310 && pos.x > 0 && pos.y > 300) {//if hit obstacle

        dead = true;
      }
    }
  }
  
   void calculateFitness() {

    if (reachedGoal) {//if the dot reached the goal then the fitness is based on the amount of steps it took to get there

      fitness = 1.0/16.0 + 10000.0/(float)(brain.step * brain.step);

    } else {//if the dot didn't reach the goal then the fitness is based on how close it is to the goal

      float distanceToGoal = dist(pos.x, pos.y, goal.x, goal.y);
      fitness = 1.0/(distanceToGoal * distanceToGoal);
    }
  }
  
  Dot gimmeBaby() {

    Dot baby = new Dot();
    baby.brain = brain.clone();//babies have the same brain as their parents
    return baby;
  }
}

class Brain {

  PVector[] directions;//series of vectors which get the dot to the goal (hopefully)
  int step = 0;

  Brain(int size) {
    
    directions = new PVector[size];
    randomize();
  }
  
  void randomize() {

    for (int i = 0; i< directions.length; i++) {

      float randomAngle = random(2*PI);
      directions[i] = PVector.fromAngle(randomAngle);
    }
  }
  
  Brain clone() {

    Brain clone = new Brain(directions.length);

    for (int i = 0; i < directions.length; i++) {

      clone.directions[i] = directions[i].copy();

    }
    return clone;
  }
  
   void mutate() {

    float mutationRate = 0.01;//chance that any vector in directions gets changed

    for (int i =0; i< directions.length; i++) {

      float rand = random(1);

      if (rand < mutationRate) {

        //set this direction as a random direction 
        float randomAngle = random(2*PI);

        directions[i] = PVector.fromAngle(randomAngle);
      }
    }
   }
}

Population test;
PVector goal = new PVector(300,10);

void setup() {
  size(600,600);
  frameRate(100);
  test = new Population(250);
}

void draw() {
  background(255);
  
  textSize(32);
  fill(0,0,0);
  text(str(test.gen), 10, 30);  
  
  fill(255,0,0);
  ellipse(goal.x,goal.y,10,10);
  
  fill(0,0,255); // undiknfd
  rect(0,300,400,10);
  
  if(test.allDotsDead()) {
    test.calculateFitness();
    test.naturalSelection();
    test.mutateDemBabies();
  }
  else {
    test.update();
    test.show();
  }
}
