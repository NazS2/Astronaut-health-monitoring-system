import org.seltar.Bytes2Web.*;

import http.requests.*;

/* 
ARDUINO TO PROCESSING

Read Serial messages from Arduino for use in Processing. 
*Even though Serial Library comes with install of Processing, upon first usage, you may be prompted to execute two sudo Terminal 
commands after entering your user password*

Created by Daniel Christopher 10/27/12
Public Domain

*/

import processing.serial.*; //import the Serial library

import java.util.List;
import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.params.*;
import org.apache.http.NameValuePair;
import org.apache.http.client.methods.HttpPut;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.client.entity.UrlEncodedFormEntity;

int end = 10;    // the number 10 is ASCII for linefeed (end of serial.println), later we will look for this to break up individual messages
String serial;   // declare a new string called 'serial' . A string is a sequence of characters (data type know as "char")
Serial port;  // The serial port, this is a new instance of the Serial class (an Object)

void setup() {
  port = new Serial(this, Serial.list()[3], 9600); // initializing the object by assigning a port and baud rate (must match that of Arduino)
  port.clear();  // function from serial library that throws out the first reading, in case we started reading in the middle of a string from Arduino
  serial = port.readStringUntil(end); // function that reads the string from serial port until a println and then assigns string to our string variable (called 'serial')
  serial = null; // initially, the string will be null (empty)
}

void draw() {
  while (port.available() > 0) { //as long as there is data coming from serial port, read it and store it 
    serial = port.readStringUntil(end);
  }
    if (serial != null) {  //if the string is not empty, print the following
      
      /*  Note: the split function used below is not necessary if sending only a single variable. However, it is useful for parsing (separating) messages when
          reading from multiple inputs in Arduino. Below is example code for an Arduino sketch
      */
      
        String[] a = split(serial, ',');  //a new array (called 'a') that stores values into separate cells (separated by commas specified in your Arduino program)
        int hum = parseInt(a[0]);
        int temp = parseInt(a[1]);
        println(":"+ hum + " - temp" + a[1]); //print Value1 (in cell 1 of Array - remember that arrays are zero-indexed)
        
       
  
        String url = "http://drmp.info/api/v001/resource/astronaut";
         
        ArrayList<NameValuePair> nameValuePairs = new ArrayList<NameValuePair>();
          nameValuePairs.add(new BasicNameValuePair("temp", a[1])); 
          nameValuePairs.add(new BasicNameValuePair("humidity", hum+"")); 
          nameValuePairs.add(new BasicNameValuePair("id",1+""));
          
        try
        {
          DefaultHttpClient httpClient = new DefaultHttpClient();
      
          HttpPut           httpPut   = new HttpPut( url );
          HttpParams        putParams = new BasicHttpParams();
          
          httpPut.setEntity(new UrlEncodedFormEntity(nameValuePairs));
          /*
                            putParams.setParameter( "temp", a[1] );
                            putParams.setParameter( "humidity", hum); // Configure the form parameters
                            putParams.setParameter( "id", 1); // Configure the form parameters
                            httpPut.setParams( putParams );    
                            */
          println( "executing request: " + httpPut.getRequestLine() );
          //println( putParams );  
          
          HttpResponse response = httpClient.execute( httpPut );
          HttpEntity   entity   = response.getEntity();
          
          
          println("----------------------------------------");
          println( response.getStatusLine() );
          println("----------------------------------------");
          
          if( entity != null ) entity.writeTo( System.out );
          if( entity != null ) entity.consumeContent();
      
          
          // When HttpClient instance is no longer needed, 
          // shut down the connection manager to ensure
          // immediate deallocation of all system resources
          httpClient.getConnectionManager().shutdown();       
          
        } catch( Exception e ) { e.printStackTrace(); }

    }
}

