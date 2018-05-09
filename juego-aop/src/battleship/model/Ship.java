package battleship.model;

import java.util.ArrayList;
import java.util.List;

import battleship.model.Place;


public class Ship {

    
    private String name;
    
    
    private int size;

    private List<Place> places;

    public Ship(String name, int size) {
        this.name = name;
        this.size = size;
        places = new ArrayList<Place>(size);
    }
    
    public String name() {
    	return name;
    }
    public int size() {
    	return size;
    }
    
    public Place head() {
    	return places.get(0);
    }
    
    public Place tail() {
    	return places.get(places.size() - 1);
    }
    
    public boolean isHorizontal() {
    	return head().getY() == tail().getY();
    }
    public boolean isVertical() {
    	return head().getX() == tail().getX();
    }
    
    public Iterable<Place> places() {
        return places;
    }
    
    public boolean isSunk() {
        return size == places.size()
                && places.stream().allMatch(p -> p.isHit());
    }

    public void addPlace(Place place) {
        if (!places.contains(place)) {
            places.add(place);
        }
        if (place.ship() != this) {
            place.placeShip(this);
        }
    }
    public void removePlace(Place place) {
        places.remove(place);
    }
	
    public boolean isDeployed() {
        return !places.isEmpty();
    }
	
    public void removePlaces() {
        List<Place> copies = new ArrayList<>(places);
        for (Place p : copies) {
            p.reset(); 
        }
    }
    
}
