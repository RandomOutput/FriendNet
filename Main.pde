import com.francisli.processing.http.*;
import com.francisli.processing.http.JSONObject;
import org.json.*;

Boolean CACHE_MODE = true;
Boolean STORE_MODE = false;

HashMap nodes;

HttpClient myClient;

FacebookOAuth auth;
String clientID = "489785564410684";
HTTP http;
String token = "";
Boolean dataPulled = false;

//parsing friends
JSONObject allFriends;

//for queing mutual friend requests
Boolean findingMutuals = false;
Boolean readyForNextMutual = false;
Boolean replotPointsPass1 = false;
Boolean replotPointsPass2 = false;
Boolean drawConnections = false;
int friendItterator = 0;
String currentID = "";

PrintWriter friendsOutput;
PrintWriter connectionsOutput;

int plotSteps = 0;
int plotSteps2 = 0;

//FOR STUFF
Object[] nodeArray;

void setup()
{
  myClient = new HttpClient(this, "graph.facebook.com");
  myClient.useSSL = true;
  http = new HTTP();
  
  size(1200,700);
  background(20,20,70);
  nodes = new HashMap();
  
  if(STORE_MODE) friendsOutput = createWriter("data/friends.txt");
  
  auth = new FacebookOAuth(this, clientID, 500, 500, DFF_WAP, true);  
  
  // opens the browser window with the authentication page
  if(CACHE_MODE)
  {
    readCache();
  }
  else
  {
    auth.authenticate();
  }
   
}

void readCache()
{
  //READ IN FRIENDS AND CREATE NODES
  String friendsJSON;
  //FileInputStream fin;
  
  byte[] buffer = loadBytes("friends.txt");
 
  try 
  {
    friendsJSON = new String(buffer, "UTF-8");
  } 
  catch (UnsupportedEncodingException e)
  {
    e.printStackTrace();
    friendsJSON = "";
  }
 
  //convert to JSON
  JSON results = JSON.parse(friendsJSON);
  
  JSON _allFriends = results.getJSON("friends").getJSON("data");
  
  for (int i = 0; i < _allFriends.length(); i++) 
  {
    // get the displayName element in the array and return as a String
    String id = _allFriends.getJSON(i).getString("id");
    String friendName = _allFriends.getJSON(i).getString("name");
    
    nodes.put(id, new Node(100 + (10 * (i % 100)), 100 + (150 * int(i / 100)), friendName, id));
    //println("Name " + i + ": " + friendName + " ID: " + id);
  }
  
  for(int i=0;i< _allFriends.length();i++)
  {
    for(int j = 0; j < _allFriends.length(); j++)
    {
      currentID =  _allFriends.getJSON(i).getString("id");
      buffer = loadBytes("friends/"+currentID);
      
      try {
        friendsJSON = new String(buffer, "UTF-8");
      } 
      catch (UnsupportedEncodingException e)
      {
        e.printStackTrace();
        friendsJSON = "";
      }
      
      //println(friendsJSON);
      
      //convert to JSON
      results = JSON.parse(friendsJSON);
     
      JSON mutualConnections = results.getJSON("data");
      
      for (int k = 0; k < mutualConnections.length(); k++) 
      {
        Node node1 = (Node)nodes.get(mutualConnections.getJSON(k).getString("id"));
        //println(mutualConnections.getJSON(k).getString("id") + nodes.containsKey(mutualConnections.getJSON(k).getString("id")));
        Node node2 = (Node)nodes.get(currentID);
        
        if(node1 == null || node2 == null)
        {
          println("err id node1| " + node1 + " node2| " + node2);
          continue;
        }
        
        node2.nodeConnections.put(mutualConnections.getJSON(k).getString("id"), node1);
      }
    }
  }
  
  replotPointsPass1 = true;
  
}

void callForNextMutual()
{
  if(friendItterator < allFriends.size())
  {
    HashMap params = new HashMap();
    params.put("access_token", token);
    currentID =  allFriends.get(friendItterator).get("id").stringValue();
    myClient.GET("me/mutualfriends/" + currentID, params);
    friendItterator++;
    readyForNextMutual = false;
    println("itt: " + friendItterator);
  }
  else 
  {
    findingMutuals = false;
    replotPointsPass1 = true;
  }
}

void draw()
{
  background(30,30,60);
  
  if(CACHE_MODE) //Pull data from local cache
  {
  }
  else //Pull new data from Facebook
  {
    if(token != "" && dataPulled == false)
    {
      HashMap params = new HashMap();
      params.put("access_token", token);
      params.put("fields", "friends");
      
      myClient.GET("me", params);
      dataPulled = true;
    }
    if(findingMutuals == true && readyForNextMutual == true)
    {
        callForNextMutual();
    }
  }
  
  nodeArray = nodes.values().toArray();
  
  
  for(int i=0;i<nodes.size();i++)
  {
    Node node = (Node)nodeArray[i];
    
    if(replotPointsPass1 == true)
    {
      if(plotSteps < 53000)
      {
        plotSteps++;
        //println(i);
        replotPointsPass1(node, ((53000.0 - plotSteps) / 53000.0));
        //println(plotSteps);
      }
      else
      {
        replotPointsPass1 = false;
        replotPointsPass2 = true;
      }
    }
    else if(replotPointsPass2 == true)
    {
      if(plotSteps2 < 2000)
      {
        plotSteps2++;
        replotPointsPass2(node, ((2000.0 - plotSteps) / 2000.0));
      }
      else
      {
        replotPointsPass2 = false;
        drawConnections = true;
      }
    }
    
    if(drawConnections == true)
    {
      Object[] nodeConn = node.nodeConnections.values().toArray();
      for(int j=0;j<nodeConn.length;j++)
      {
        Node node2 = (Node)nodeConn[j];
        
        stroke(100, 100, 256, 10);
        line(node.x, node.y, node2.x, node2.y);
      }
    }
    
    node.draw();
  }
  
  fill(256,0,0,256);
  ellipse(0,0,10,10);
}

void replotPointsPass2(Node node, float temp)
{
  float xAverage = 0;
  float yAverage = 0;
  float xTotal = 0;
  float yTotal = 0;
  float xComp = 0;
  float yComp = 0;
  float avCount = 0.0;
  
  for(int j=0;j<nodes.size();j++)
  {
    Node node2 = (Node)nodeArray[j];
    
    float xDist = node2.x - node.x;
    float yDist = node2.y - node.y;
    float dist = sqrt(pow(xDist,2)+ pow(yDist,2));
    
    if(dist < 3)
    {
      xTotal -= xDist;
      yTotal -= yDist;
      avCount++;
    }
  }
  
  if(avCount != 0)
  {
    xAverage = xTotal / avCount;
    yAverage = yTotal / avCount;
  }
  else
  {
    return;
  }
  
  if(sqrt(pow(xAverage,2) + pow(yAverage,2)) != 0)
  {
    //xComp = xAverage / 10;
    //yComp = yAverage / 10;
    xComp = xAverage / sqrt(pow(xAverage,2)+ pow(yAverage,2));
    yComp = yAverage / sqrt(pow(xAverage,2)+ pow(yAverage,2));
    
    node.x += xComp * (3 * temp);
    node.y += yComp * (3 * temp);
  }
}


void replotPointsPass1(Node node, float temp)
{
  float xAverage = 0;
  float yAverage = 0;
  float xTotal = 0;
  float yTotal = 0;
  float xComp = 0;
  float yComp = 0;
  float avCount = 0.0;
  
  
  Object[] nodeConn = node.nodeConnections.values().toArray();
      
        
  for(int j=0;j<nodes.size();j++)
  {
    Node node2 = (Node)nodeArray[j];
    Boolean mututalNode = false;
    float xDist = node2.x - node.x;
    float yDist = node2.y - node.y;
    
    for(int k=0;k<nodeConn.length;k++)
    {
      Node searchNode = (Node)nodeConn[k];
     
      if(searchNode == node2)
      {
          mututalNode = true;
      }
    }
    
    if(mututalNode == true && sqrt(pow(xDist,2)+ pow(yDist,2)) > 50)
    {
        xTotal += xDist;
        yTotal += yDist;
        avCount++;
    }
    else if(mututalNode == true && sqrt(pow(xDist,2)+ pow(yDist,2)) <= 40)
    {
        xTotal -= xDist*5;
        yTotal -= yDist*5;
        avCount++;
    }
    else if(mututalNode == false && sqrt(pow(xDist,2)+ pow(yDist,2)) < 75)
    {
        xTotal -= xDist*2;
        yTotal -= yDist*2;
        avCount++;
    } 
  }
  
  if(avCount != 0)
  {
    xAverage = xTotal / avCount;
    yAverage = yTotal / avCount;
  }
  else
  {
    return;
  }
  
  if(sqrt(pow(xAverage,2) + pow(yAverage,2)) != 0)
  {
    //xComp = xAverage / 10;
    //yComp = yAverage / 10;
    xComp = xAverage / sqrt(pow(xAverage,2)+ pow(yAverage,2));
    yComp = yAverage / sqrt(pow(xAverage,2)+ pow(yAverage,2));
    
    node.x += xComp * (60 * temp);
    node.y += yComp * (60 * temp);
  }
  else
  {
    //println("no movement:" + node.name + " id:" + node.id + "\nxTotal: " + xTotal + "\nyTotal: " + yTotal + "\n" + node.nodeConnections);
  }
  
  return;
}

// callback used to give the access token back to the application
void facebookAccessToken(String _token) {
  
  //println(_token);
  _token = _token.substring(_token.indexOf("=") + 1, _token.length());
  token = _token;
  //println(token);
  // From this point on you can use the token to create Graph API requests:
  //String r = http.getWebPage("https://graph.facebook.com/me?fields=picture&"+token);

}

void responseReceived(HttpRequest request, HttpResponse response) {
  if (response.statusCode == 200) {
    JSONObject results = response.getContentAsJSONObject();
    String s_results = response.getContentAsString();
    
    if(results.get("friends") != null)
    {
      // get just the list of artists
      allFriends = results.get("friends").get("data");
      
      if(STORE_MODE) 
      {
        friendsOutput.print(s_results);
        friendsOutput.flush(); // Writes the remaining data to the file
        friendsOutput.close(); // Finishes the file
      }
      
      // we asked for a JSON response from Facebook, so use size() and get() to access elements
      for (int i = 0; i < allFriends.size(); i++) {
        // get the displayName element in the array and return as a String
        String id = allFriends.get(i).get("id").stringValue();
        String friendName = allFriends.get(i).get("name").stringValue();
        nodes.put(id, new Node(random(1200), random(700), friendName, allFriends.get(i).get("id").stringValue()));
        // print out the name
        //println("Name " + i + ": " + friendName + " ID: " + id);
      }
      Object[] nodeArray = nodes.keySet().toArray();
      /*
      for(int i=0;i<nodes.size();i++)
      {
        println(nodeArray[i]);
      }
      */
      findingMutuals = true;
      readyForNextMutual = true;
    }
    else if(findingMutuals == true)
    {
      
      if(STORE_MODE)
      {
        connectionsOutput = createWriter("data/friends/" + currentID);
        connectionsOutput.print(s_results);
        connectionsOutput.flush(); // Writes the remaining data to the file
        connectionsOutput.close(); // Finishes the file
      }
      
      JSONObject mutualConnections = results.get("data");
      
      for (int i = 0; i < mutualConnections.size(); i++) 
      {
        Node node1 = (Node)nodes.get(mutualConnections.get(i).get("id").stringValue());
        Node node2 = (Node)nodes.get(currentID);
        
        if(node1 == null || node2 == null)
        {
          println("err");
          continue;
        }
        
        //println(node2.name + " : " + node1.name);
        //println(node2.nodeConnections);
        node2.nodeConnections.put(mutualConnections.get(i).get("id").stringValue(), node1);
      }
      readyForNextMutual = true;
    }
  } else {
    // output the entire response as a string
    println(response.getContentAsString());
  }
}
