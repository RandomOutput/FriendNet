class Node
{
  public int x = 0;
  public int y = 0;
  public String id = "";
  public String name;
  public HashMap nodeConnections;
  
  Node(float _x, float _y)
  {
    x = (int)_x;
    y = (int)_y;
    name = "";
    nodeConnections = new HashMap();
  }
  
  Node(float _x, float _y, String _name, String _id)
  {
    x = (int)_x;
    y = (int)_y;
    id = _id;
    name = _name;
    nodeConnections = new HashMap();
  }
  
  void draw()
  {
    noFill();
    stroke(80,80,120);
    ellipseMode(CENTER);
    ellipse(x,y,10,10);
    fill(200, 100, 100, 50);
    textSize(7);
    text(name, x, y); 
    
    if(this.x < 0) this.x = 10;
    else if(this.x > 1200) this.x = 1990;
    
    if(this.y < 0) this.y = 10;
    else if(this.y > 700) this.y = 690;
    
    
  }
}
