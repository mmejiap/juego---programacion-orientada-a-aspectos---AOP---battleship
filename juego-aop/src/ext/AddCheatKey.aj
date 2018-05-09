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

import java.awt.Color;


import java.awt.Graphics;
import java.awt.event.ActionEvent;
import java.awt.event.KeyEvent;
import static battleship.Constants.*;

import javax.swing.AbstractAction;
import javax.swing.ActionMap;
import javax.swing.InputMap;
import javax.swing.JComponent;
import javax.swing.KeyStroke;

import battleship.BoardPanel;
import battleship.model.*;
 
public privileged aspect AddCheatKey {

	private boolean BoardPanel.peek = false;
	protected static int left = DEFAULT_LEFT_MARGIN;
	protected static int top = DEFAULT_TOP_MARGIN;
	protected static int pSize = DEFAULT_PLACE_SIZE;
	protected final static Color colorShowShips = Color.WHITE;
	protected final static Color colorHideShips = new Color(51, 153, 255);
	
	pointcut cheat(BoardPanel boardPanel) : execution(* BoardPanel.*(..)) && target(boardPanel);
	after(BoardPanel boardPanel) : cheat(boardPanel) {
	    	ActionMap actionMap = boardPanel.getActionMap();
	    	int condition = JComponent.WHEN_IN_FOCUSED_WINDOW;
	    	InputMap inputMap = boardPanel.getInputMap(condition);
	    	String cheat = "Cheat";
	    	inputMap.put(KeyStroke.getKeyStroke(KeyEvent.VK_F5, 0), cheat);
	    	actionMap.put(cheat, new KeyAction(boardPanel, cheat));
	    	
	    }
	
    @SuppressWarnings("serial")
    private static class KeyAction extends AbstractAction {
       private final BoardPanel boardPanel;
       
       public KeyAction(BoardPanel boardPanel, String command) {
           this.boardPanel = boardPanel;
           putValue(ACTION_COMMAND_KEY, command);
       }
       
       
       public void actionPerformed(ActionEvent event) {
    	   if(!boardPanel.peek)
    	   {
    		   boardPanel.drawShips(boardPanel.getGraphics(), colorShowShips);
    		   boardPanel.peek = true;
    		   System.out.println("CHEATING");
    	   }
    	   else
    	   {
    		   boardPanel.drawShips(boardPanel.getGraphics(), colorHideShips);
    		   boardPanel.peek = false;
    		   System.out.println("NORMAL");
    	   }
       } 
    }
    
    private void BoardPanel.drawShips(Graphics g, Color color) {

    	final Color oldColor = g.getColor();

    	for (Place p: board.places()) 
        {
			if (p.hasShip()) {
				g.setColor(color);
				if(p.ship().isHorizontal()){
					g.drawRect((left + (p.getX() - 1) * pSize )+1, (top + (p.getY() - 1) * pSize)+1,
							pSize-2, pSize-2);
                }
				else{
					g.drawRect((left + (p.getX() - 1) * pSize )+1, (top + (p.getY() - 1) * pSize)+1,
							pSize-2, pSize-2);
				}
                
            }
    	}
    	g.setColor(oldColor);
    }
    
    void around(BoardPanel panel, Graphics g) : execution(void BoardPanel.drawPlaces(Graphics)) && target(panel) && args(g) {

    	proceed(panel, g);
    	if(panel.peek)
    	{
    		panel.drawShips(g, colorShowShips);
    	}
    }

   
}