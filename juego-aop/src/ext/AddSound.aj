/**

 * @author Miguel Mejia
 * @author Dany julca
 * @author kevin molina
 * @author bruno bedon 
 * 
 * 
 * 
 */
package ext;
import battleship.model.Ship;
import java.io.*;
import javax.sound.sampled.*;

public aspect AddSound{
	/** directorio de sonidos */
    private static final String SOUND_DIR = "./src/sounds/";

    /** play del sonido */
    public static void playAudio(String filename) {
      try {
    	  File audio = new File(SOUND_DIR + filename);
          AudioInputStream audioIn = AudioSystem.getAudioInputStream(audio);
          Clip clip = AudioSystem.getClip();
          clip.open(audioIn);
          clip.start();
      } catch (UnsupportedAudioFileException 
            | IOException | LineUnavailableException e) {
          e.printStackTrace();
      }
    }

	pointcut hitSound() : execution(void battleship.model.Place.hit());
	pointcut sinkSound(): call(void battleship.model.Board.notifyShipSunk(Ship));
	
	before() : hitSound()
	{
		playAudio("explosion.wav");
		System.out.println("test-explosion explosion");
	}
	after() : sinkSound()
	{
		playAudio("sink.wav");
		System.out.println("Test-explosion hundido");
	}
}