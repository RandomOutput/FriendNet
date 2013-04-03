import com.francisli.processing.http.*;
import com.francisli.processing.http.JSONObject;

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
int friendItterator = 0;
String currentID = "";

void setup()
{
  myClient = new HttpClient(this, "graph.facebook.com");
  myClient.useSSL = true;
  http = new HTTP();
  
  size(1200,700);
  background(50,50,100);
  nodes = new HashMap();
  //randomDist();
  
  auth = new FacebookOAuth(this, clientID, 500, 500, DFF_WAP, true);  
  
  // opens the browser window with the authentication page
  auth.authenticate(); 
}

void draw()
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
      }
  }
  
  Object[] nodeArray = nodes.values().toArray();
  
  for(int i=0;i<nodes.size();i++)
  {
    Node node = (Node)nodeArray[i];
    node.draw();
  }
}

// callback used to give the access token back to the application
void facebookAccessToken(String _token) {
  
  println(_token);
  _token = _token.substring(_token.indexOf("=") + 1, _token.length());
  token = _token;
  //println(token);
  // From this point on you can use the token to create Graph API requests:
  //String r = http.getWebPage("https://graph.facebook.com/me?fields=picture&"+token);

}

void responseReceived(HttpRequest request, HttpResponse response) {
  if (response.statusCode == 200) {
    JSONObject results = response.getContentAsJSONObject();
    
    if(results.get("friends") != null)
    {
      // get just the list of artists
      allFriends = results.get("friends").get("data");
   
      // we asked for a JSON response from Songkick, so use size() and get() to access elements
      for (int i = 0; i < allFriends.size(); i++) {
        // get the displayName element in the array and return as a String
        String id = allFriends.get(i).get("id").stringValue();
        String friendName = allFriends.get(i).get("name").stringValue();
        nodes.put(id, new Node(random(1200), random(700), friendName));
        // print out the name
        //println("Name " + i + ": " + friendName + " ID: " + id);
      }
      Object[] nodeArray = nodes.keySet().toArray();
  
      for(int i=0;i<nodes.size();i++)
      {
        println(nodeArray[i]);
      }
      findingMutuals = true;
      readyForNextMutual = true;
    }
    else if(findingMutuals == true)
    {
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
        
        println(node2.name + " : " + node1.name);
        
        stroke(100, 100, 200, 20);
        line(node1.x, node1.y, node2.x, node2.y);
        
      }
      readyForNextMutual = true;
    }
  } else {
    // output the entire response as a string
    println(response.getContentAsString());
  }
}
