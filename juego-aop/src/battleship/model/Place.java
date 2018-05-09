

package battleship.model;

import battleship.model.Board;


public class Place {
	
    
    public final int x;
    public final int y;

    private boolean isHit;

    private Ship ship;

    private Board battleBoard;
    
    public Place(int x, int y, Board battleBoard) {
        this.x = x;
        this.y = y;
        this.battleBoard = battleBoard;
    }
    
    public int getX() {
    	return x;
    }
    public int getY() {
    	return y;
    }
    
    public boolean isHit() {
    	return isHit;
    }
    
    public boolean isHitShip() {
    	return isHit && !isEmpty();
    }
    
    public void hit() {
    	isHit = true;
    	battleBoard.hit(this);
    }
    public boolean hasShip() {
    	return ship != null;
    }
    
    public boolean isEmpty() {
    	return ship == null;
    }
    
    public void placeShip(Ship ship) {
    	this.ship = ship;
    	ship.addPlace(this);
    }
    
    
    public Ship ship() {
    	return ship;
    }
    public void reset() {
        isHit = false;
        if (ship != null) {
            ship.removePlace(this);
            ship = null;
        }
    }
}
