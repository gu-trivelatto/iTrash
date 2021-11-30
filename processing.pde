//---------------------------Laboratorio Digital---------------------------------------
// Arquivo: sonar_processing_p1_2021
// Projeto: Experiencia 6 - Sistema de Sonar (Parte 2)
//-------------------------------------------------------------------------------------
// Descricao:
//            sketch processing: interface para radar com sensor ultrassônico
// 
//            baseado em código disponível no site:
//            http://howtomechatronics.com/projects/arduino-radar/
//
//-------------------------------------------------------------------------------------
// Revisoes:
//     Data        Versao  Autor             Descricao
//     28/10/2015  1.0     Edson Midorikawa  adaptacao inicial do sketch
//     21/10/2019  2.0     Edson Midorikawa  configuracao da interface serial
//     08/10/2021  3.0     Edson Midorikawa  adaptado para MQTT
//     13/10/2021  3.1     Edson Midorikawa  ajustado para configuração de credenciais
//-------------------------------------------------------------------------------------
//

import java.io.IOException;

// MQTT
import mqtt.*;

String user   = "grupo1-bancadaB1";
String passwd = "L%40Bdygy1B1";      // manter %40
String broker = "3.141.193.238";     //
String port   = "80";

MQTTClient client;
String clientID;

// variaveis
String angle="";
String distance="";
String data="";
String noObject;
float  pixsDistance;
int    iAngle, iDistance;
int    index1=0;
int    index2=0;
PFont  orcFont;

// keystroke
int whichKey = -1;  // variavel mantem tecla acionada


// funcao setup()
void setup() {
  size (500, 350);
  //translate(0,20); 
  smooth();

  orcFont = loadFont("OCRAExtended-24.vlw");

  // MQTT
  client = new MQTTClient(this);
  clientID = new String("labead-mqtt-processing-" + random(0,100));
  println("clientID=" + clientID);
  client.connect("mqtt://" + user + ":" + passwd + "@" + broker + ":" + port, clientID, false);

}

// funcao draw
void draw() {
    pushMatrix();
    translate(0,40);
    fill(98,245,31);
    textFont(orcFont);
    noStroke();
    fill(0,7);
    rect(0, -40, width, 480+40);
    
    fill(98,245,31); // verde
    // chama funcoes para desenhar o radar
    drawRadar(); 
    drawLine();
    drawObject();
    drawText();
    popMatrix();
}

// funcao drawRadar()
void drawRadar() {
    pushMatrix();
    //
    fill(255,255,255);
    text("PCS3645 LabDig II (2021)", 10, 0);
    text("LabEAD/MQTT", 10, 30);
    //
    translate(480,480);
    noFill();
  
    strokeWeight(2);
    stroke(98,245,31);
    // arcoss
    arc(0,0,800,800,PI,TWO_PI);
    arc(0,0,600,600,PI,TWO_PI);
    arc(0,0,400,400,PI,TWO_PI);
    arc(0,0,200,200,PI,TWO_PI);

    // desenha segmentos radiais
    line(-480,0,480,0);
    line(0,0,-480*cos(radians(30)),-480*sin(radians(30)));
    line(0,0,-480*cos(radians(60)),-480*sin(radians(60)));
    line(0,0,-480*cos(radians(90)),-480*sin(radians(90)));
    line(0,0,-480*cos(radians(120)),-480*sin(radians(120)));
    line(0,0,-480*cos(radians(150)),-480*sin(radians(150)));
    line(-480*cos(radians(30)),0,480,0);
    popMatrix();
}

// funcao drawObject()
void drawObject() {
    pushMatrix();
    translate(480,480);
    strokeWeight(20); 
    stroke(255,10,10); // vermelho
    pixsDistance = iDistance*10.0; // calcula distancia em pixels
    // limita faixa de apresentacao
    if(iDistance < 50) {
      // desenha objeto
      point(pixsDistance*cos(radians(iAngle)),-pixsDistance*sin(radians(iAngle)));
    }
    popMatrix();
}   


// funcao drawLine()
void drawLine() {
    pushMatrix();
    strokeWeight(10);
    stroke(30,250,60);
    translate(480,480);
    // desenha linha do sonar
    line(0,0,470*cos(radians(iAngle)),-470*sin(radians(iAngle)));
    popMatrix();
}

// funcao drawText()
void drawText() {
  
    pushMatrix();
    // limita detecao de objetos a 100 cm
    if(iDistance > 100) {
      noObject = "Não Detectado";
    }
    else {
      noObject = "Detectado";
    }
    fill(0,0,0);
    noStroke();
    rect(0, 481, width, 540);
    fill(98,245,31);
    textSize(12);
    text("10cm",590,470);
    text("20cm",690,470);
    text("30cm",790,470);
    text("40cm",890,470);
    textSize(20);
    // imprime dados do sonar
    text("Objeto: " + noObject, 120, 525);
    text("Ângulo: " + iAngle +"°", 500, 525);
    text("Distância: ", 680, 525);
    if(iDistance<50) {
      text("          " + iDistance +" cm", 700, 525);
    }
    else {
      text("          ---", 700, 525);  
    }
    textSize(12);
    fill(98,245,60);
    translate(485+480*cos(radians(30)),468-480*sin(radians(30)));
    rotate(-radians(-60));
    text("30°",0,0);
    resetMatrix();
    translate(482+480*cos(radians(60)),505-480*sin(radians(60)));
    rotate(-radians(-30));
    text("60°",0,0);
    resetMatrix();
    translate(473+480*cos(radians(90)),510-480*sin(radians(90)));
    rotate(radians(0));
    text("90°",0,0);
    resetMatrix();
    translate(462+480*cos(radians(120)),515-480*sin(radians(120)));
    rotate(radians(-30));
    text("120°",0,0);
    resetMatrix();
    translate(467+480*cos(radians(150)),525-480*sin(radians(150)));
    rotate(radians(-60));
    text("150°",0,0);
    popMatrix(); 
}


// funcao keyPressed - processa tecla acionada
void keyPressed() {
  whichKey = key;

  client.publish(user + "/key", ""+key);
  client.publish(user + "/RX", ""+key);
  println("tecla acionada = " + key);
}


// funcoes para conexao com MQTT

void clientConnected() {
  println("cliente conectado");

  client.subscribe(user + "/dadosonar");

}

void messageReceived(String topic, byte[] payload) {

    println("nova mensagem: " + topic + " - " + new String(payload));
  
    // processa dado
    data = new String(payload);
    println("data= " + data);
  
    data = data.substring(0,data.length()-1);  // remove '.'
    index1 = data.indexOf(","); // encontra posicao da ',' e retorna na variavel "index1"
    angle= data.substring(0, index1); // le dado da posicao 0 ate index1 (angulo)
    distance= data.substring(index1+1, data.length()); // le dado a partir da posicao index1+1 até o final (distancia) 
      
    // converte variaveis do tipo String variables para Integer
    iAngle = int(angle);
    iDistance = int(distance);

    println("iAngle= " + iAngle + ", iDistance= " + iDistance);
}

void connectionLost() {
  println("conexao perdida");
}
