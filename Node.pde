class Node
{
  int x = 0;
  int y = 0;
  
  Node(float _x, float _y)
  {
    x = (int)_x;
    y = (int)_y;
  }
  
  void draw()
  {
    noFill();
    stroke(60,60,100);
    ellipseMode(CENTER);
    ellipse(x,y,10,10);
  }
}
