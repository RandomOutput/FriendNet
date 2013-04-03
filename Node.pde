class Node
{
  int x = 0;
  int y = 0;
  String name;
  
  Node(float _x, float _y)
  {
    x = (int)_x;
    y = (int)_y;
    name = "";
  }
  
  Node(float _x, float _y, String _name)
  {
    x = (int)_x;
    y = (int)_y;
    name = _name;
  }
  
  void draw()
  {
    fill(100, 100, 200, 50);
    textSize(10);
    text(name, x, y); 
    noFill();
    stroke(60,60,100);
    ellipseMode(CENTER);
    ellipse(x,y,10,10);
  }
}
