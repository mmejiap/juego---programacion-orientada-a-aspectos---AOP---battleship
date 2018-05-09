import java.awt.Color;
import java.awt.Graphics;
import javax.swing.JPanel;

import battleship.model.Board;
import battleship.model.Place;
import static battleship.Constants.*;


@SuppressWarnings("serial")
public class SmallBoardPanel extends JPanel{

    protected final int topMargin;

    protected final int leftMargin;

    protected int placeSize;

    protected int boardSize;

    protected Color boardColor;

    protected final Color hitColor;

    protected final Color missColor;

    protected final Color lineColor = DEFAULT_LINE_COLOR;

    protected final Board board;
    
    protected Color colorShowShips;

    public SmallBoardPanel(Board battleBoard) {
     this(battleBoard, 
         DEFAULT_TOP_MARGIN, DEFAULT_LEFT_MARGIN, DEFAULT_PLACE_SIZE,
         DEFAULT_BOARD_COLOR, DEFAULT_HIT_COLOR, DEFAULT_MISS_COLOR);
     this.colorShowShips = new Color(116,214,0);
    }
    
    public SmallBoardPanel(Board board,
            int topMargin, int leftMargin, int placeSize,
            Color boardColor, Color hitColor, Color missColor) {
     this.board = board;
     this.boardSize = board.size();
     this.topMargin = topMargin;
     this.leftMargin = leftMargin;
     this.placeSize = placeSize;
     this.boardColor = boardColor;
     this.hitColor = hitColor;
     this.missColor = missColor;
     this.colorShowShips = new Color(116,214,0);
     
    }
    
    private void placeClicked(Place place) {
        if (!board.isGameOver() && !place.isHit()) {
            place.hit();
            repaint();                 
        }
    }
    
    private Place locatePlace(int x, int y) {
        //
        // +--------------
        // |    TM
        // |   +---+---+-- 
        // |LM |TS |   |   
        // |   +---+---+--
        //
        int ix = (x - leftMargin) / placeSize;
        int iy = (y - topMargin)  / placeSize;
        if (x > leftMargin && y > topMargin
            && ix < boardSize && iy < boardSize) {
            return board.at(ix + 1, iy + 1);
        }
        return null;
    }
    
    @Override
    public void paint(Graphics g) {
        super.paint(g); // clear the background
        drawGrid(g);
        drawShipsNPlaces(g);
        
    }

    private void drawGrid(Graphics g) {
        Color oldColor = g.getColor(); 

        
  final int frameSize = boardSize * placeSize;
        g.setColor(boardColor);
        g.fillRect(leftMargin, topMargin, frameSize, frameSize);
        
        
        g.setColor(lineColor);
        int x = leftMargin;
        int y = topMargin;
        for (int i = 0; i <= boardSize; i++) {
            g.drawLine(x, topMargin, x, topMargin + frameSize);
            g.drawLine(leftMargin, y, leftMargin + frameSize, y);
            x += placeSize;
            y += placeSize;
        }

        g.setColor(oldColor);
    }
    private void drawShipsNPlaces(Graphics g)
    {
    	final Color oldColor = g.getColor();

    	for(Place p: board.places())
    	{
    		if(p.hasShip())
    		{
    			int x = leftMargin + (p.getX() - 1) * placeSize;
    			int y = topMargin + (p.getY() - 1) * placeSize;
    			g.setColor(colorShowShips);
    			g.fillRect(x + 1, y + 1, placeSize - 1, placeSize - 1);
    		}
    		if (p.isHit()) {
				int x = leftMargin + (p.getX() - 1) * 10;
				int y = topMargin + (p.getY() - 1) * 10;
				g.setColor(p.isEmpty() ? missColor : hitColor);
				g.fillRect(x + 1, y + 1, placeSize - 1, placeSize - 1);
				if (p.hasShip() && p.ship().isSunk()) {
					g.setColor(Color.BLACK);
					g.drawLine(x + 1, y + placeSize - 1, x + placeSize - 1, y + placeSize - 1);
					g.drawLine(x + 1, y + placeSize - 1, x + placeSize - 1,
							y + 1);
				}
			}
		}

		g.setColor(oldColor);
    }

}