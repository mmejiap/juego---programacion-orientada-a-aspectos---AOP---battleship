/**
 * 
 * @author Miguel Mejia
 * @author Dany julca
 * @author kevin molina
 * @author bruno bedon 
 * 
 * 
 * 
 */

package battleship.model;

import java.util.*;
import java.util.stream.IntStream;

import battleship.model.Ship;
import battleship.model.Place;


public class Board {

    
    private final int size;

    
    private int numOfShots;

    private final List<Place> places;
    

    private static List<Ship> defaultShips() {
        return Arrays.asList(new Ship[] { 
                new Ship("Aircraft carrier", 5),
                new Ship("Battleship", 4),
                new Ship("Frigate", 3),
                new Ship("Submarine", 3),
                new Ship("Minesweeper", 2), });
    }
      
    private final List<Ship> ships;
    
    private final List<BoardChangeListener> listeners;
  
    public Board(int size) {
        this(size, defaultShips());
    }

    public Board(int size, Iterable<Ship> ships) {
        this.size = size;
        numOfShots = 0;
        places = new ArrayList<Place>(size * size);
        for (int x = 1; x <= size; x++) {
            for (int y = 1; y <= size; y++) {
                places.add(new Place(x, y, this));
            }
        }
        this.ships = new ArrayList<>();
        ships.forEach(e -> this.ships.add(e));
        listeners = new ArrayList<BoardChangeListener>();
    }
    
    public void reset() {
        numOfShots = 0;
        places.stream().forEach(p -> p.reset());
    }
    
    public boolean placeShip(Ship ship, int x, int y, boolean dir) {
    	int len = ship.size();
    	if (dir // horizontal? 
    	    && (x + len - 1 <= this.size)  
    	    && IntStream.range(x, x + len) 
    		    .allMatch(i -> at(i, y).isEmpty())) {
    	    IntStream.range(x, x + len).forEach(i -> at(i,y).placeShip(ship));
    	    return true;
    	}
    	if (!dir 
    	    && (y + len - 1 <= this.size)
    	    && IntStream.range(y, y + len)
    		    .allMatch(j -> at(x, j).isEmpty())) {
    	    IntStream.range(y, y + len).forEach(j -> at(x,j).placeShip(ship));
    	    return true;
    	}
    	return false;
    }

    public boolean placeShip(Ship ship, Place place, boolean dir) {
    	return placeShip(ship, place.getX(), place.getY(), dir);
    }
    
    public Iterable<Place> places() {
        return places;
    }
    
    public Iterable<Ship> ships() {
        return ships;
    }
    
    public Ship ship(String name) {
    	return ships.stream().filter(s -> s.name().equals(name))
    	        .findFirst().orElse(null);
    }

    public Place at(int x, int y) {
        for (Place p: places) {
            if (p.getX() == x && p.getY() == y) {
                return p;
            }
        }
        return null; 
    }

    public int size() {
        return size;
    }

    public int numOfShots() {
        return numOfShots;
    }
    
    public boolean isGameOver() {
    	return ships.stream().allMatch(s -> s.isSunk());
    }
    

	public void hit(Place place) {
        if (!place.isHit()) {
            place.hit();
            return;
        }
        numOfShots++;
        notifyHit(place, numOfShots);

        if (!place.isEmpty()) {
            if (place.ship().isSunk()) {
                notifyShipSunk(place.ship());
                if (isGameOver()) {
                    notifyGameOver(numOfShots);
                }
            }
        }
	}

    public void addBoardChangeListener(BoardChangeListener listener) {
    	if (!listeners.contains(listener)) {
    	    listeners.add(listener);
    	}
    }
    
    public void removeBoardChangeListener(BoardChangeListener listener) {
        listeners.remove(listener);
    }
    
    private void notifyHit(Place place, int numOfShots) {
    	for (BoardChangeListener listener: listeners) {
    	    listener.hit(place, numOfShots);
    	}
    }
    
    private void notifyGameOver(int numOfShots) {
    	for (BoardChangeListener listener: listeners) {
    	    listener.gameOver(numOfShots);
    	}
    }
    
    private void notifyShipSunk(Ship ship) {
    	for (BoardChangeListener listener: listeners) {
    	    listener.shipSunk(ship);
    	}
    }
    
    
    public interface BoardChangeListener {
    	
    	void hit(Place place, int numOfShots);
    	
    	void gameOver(int numOfShots);
    	
    	void shipSunk(Ship ship);
    }

    
    public static class BoardChangeAdapter implements BoardChangeListener {
    	public void hit(Place place, int numOfShots) {}
    	public void gameOver(int numOfShots) {}
    	public void shipSunk(Ship ship) {}
    }
    
}
