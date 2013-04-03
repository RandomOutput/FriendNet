import java.net.*;
import java.io.*;

class HTTP {

  
  public String getWebPage(String address) {
    
    // criar o URL
    URL url = null;
    try {
      url = new URL(address);
    } 
    catch (MalformedURLException murle) {
      println("Bad URL: " + murle.getMessage());
      return null;
    }

    // Obter a HttpURLConnection
    HttpURLConnection urlConn = null;
    try {
      urlConn = (HttpURLConnection)url.openConnection();
      urlConn.setUseCaches(false);
      urlConn.connect();
    } 
    catch (IOException ioe) {
      println("Error connecting: " +  ioe.getMessage());
      return null;
    }


    // ler os cabeçalhos. Nao e' necessario, so para demonstrar
    String headerName = null;
    String headerValue = null;
    int i = 0;
    do {
      headerName = urlConn.getHeaderFieldKey(i);
      headerValue = urlConn.getHeaderField(i);
      //println(headerName + ": " + headerValue);
      i++;
    } while (headerValue != null);
    
    

    // Abrir a stream e ler
    try {
      BufferedReader in = new BufferedReader(new InputStreamReader(urlConn.getInputStream()));
      
      // vamos ler linha a linha e juntar as varias linhas usando um StringBuffer (e' mais eficiente do que concatenar Strings)
      StringBuffer sb = new StringBuffer();

      String line;
      do {
        line = in.readLine();
        if (line != null) {
          sb.append(line);
        }
      } 
      while(line != null);

      return sb.toString();
    }
    catch(Exception e) {
      println("Error reading: " + e.getMessage());
      return null;
    }
  }
  

  public String getWebPagePost(String address, String postData) {
    
    // criar o URL
    URL url = null;
    try {
      url = new URL(address);
    } 
    catch (MalformedURLException murle) {
      println("Bad URL: " + murle.getMessage());
      return null;
    }

    // Obter a HttpURLConnection
    HttpURLConnection urlConn = null;
    try {
      urlConn = (HttpURLConnection)url.openConnection();
      urlConn.setUseCaches(false);
      urlConn.setDoOutput(true);
      urlConn.connect();
    } 
    catch (IOException ioe) {
      println("Error connecting: " +  ioe.getMessage());
      return null;
    }

    // Obter a stream de output e escrever os dados
    try {
    DataOutputStream dstream = new DataOutputStream(urlConn.getOutputStream());
    dstream.writeBytes(postData);
    } catch (IOException ioe) {
      println("Erro ao escrever: " + ioe.getMessage());
    }

    // ler os cabeçalhos. Nao e' necessario, so para demonstrar
    String headerName = null;
    String headerValue = null;
    int i = 0;
    do {
      headerName = urlConn.getHeaderFieldKey(i);
      headerValue = urlConn.getHeaderField(i);
      //println(headerName + ": " + headerValue);
      i++;
    } while (headerValue != null);
    
    

    // Abrir a stream e ler
    try {
      BufferedReader in = new BufferedReader(new InputStreamReader(urlConn.getInputStream()));
      
      // vamos ler linha a linha e juntar as varias linhas usando um StringBuffer (e' mais eficiente do que concatenar Strings)
      StringBuffer sb = new StringBuffer();

      String line;
      do {
        line = in.readLine();
        if (line != null) {
          sb.append(line);
        }
      } 
      while(line != null);

      return sb.toString();
    }
    catch(Exception e) {
      println("Error reading: " + e.getMessage());
      return null;
    }
  }
  
}

