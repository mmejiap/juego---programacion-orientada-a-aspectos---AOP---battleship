/**
 * @author Miguel Mejia
 * @author Dany julca
 * @author kevin molina
 * @author bruno bedon 
 * 
 */


import static battleship.Constants.DEFAULT_BOARD_COLOR;

import battleship.*;
import battleship.model.*;

import static battleship.Constants.DEFAULT_HIT_COLOR;
import static battleship.Constants.DEFAULT_MISS_COLOR;
import static battleship.Constants.DEFAULT_TOP_MARGIN;

import java.awt.FlowLayout;
import java.awt.GridLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.BorderLayout;
import java.awt.Color;
import java.util.ArrayList;
import java.util.Random;

import javax.swing.BorderFactory;
import javax.swing.BoxLayout;
import javax.swing.JButton;
import javax.swing.JComboBox;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.border.Border;
import javax.swing.border.LineBorder;

privileged aspect AddStrategy{



	protected final static Color colorShowShips = Color.GREEN;	

	private JButton playButton = new JButton("Play");	
	private JButton practiceButton;						
	private JPanel buttonsPanel; 						
	
	public enum Strategy{Random, Sweep, Smart, Berserk}
	private JComboBox<Strategy> strategies = new JComboBox<Strategy>(Strategy.values());
	private Strategy strategy; 

	private Random random = new Random();		
	private ArrayList<Place> placesHit = new ArrayList<Place>();
	private Place target;						
	private Place search;
	private int [] sweepTarget ={28,1};			

	private SmallBoardPanel playerBoardPanel;	
	private Board playerBoard;					

	private boolean playMode = false;		
	private boolean practiceMode = false;	 
	private boolean turn = true;			
	private int unfairTurn = 0;				
	public enum Direction{LEFT, RIGHT, UP, DOWN};
	private Direction dir = Direction.LEFT;

//point cuts
	pointcut updateButtons(BattleshipDialog bd) : 
		call(private JPanel BattleshipDialog.makeControlPane()) && this(bd);
	//pointcut updateButtons2(BattleshipDialog bd) : call(private JPanel BattleshipDialog.makeControlPane()) && this(bd);

	pointcut attack() : 
		execution(void battleship.model.Place.hit());

	pointcut enablePanel() : 
		call(private JPanel BattleshipDialog.makeBoardPane());

	pointcut makeVisible(BattleshipDialog bd) : execution(* BattleshipDialog.*(..)) && target(bd);

	pointcut restartGame() : 
		call(private void BattleshipDialog.startNewGame());

	pointcut endGame() : 
		call(private void battleship.model.Board.isGameOver());

	
	
	
	
	//////////////////////////

	after(BattleshipDialog bd) returning(JPanel contents) : updateButtons(bd){
		updateButtons(contents);
		
		
		playButton.addActionListener(new ActionListener(){
			public void actionPerformed(ActionEvent e){
				if (JOptionPane.showConfirmDialog(bd, 
		                "Play a new game?", "Battleship", JOptionPane.YES_NO_OPTION)
		                == JOptionPane.YES_OPTION) {
		                bd.startNewGame();
		                if(!playMode){
		                	playMode = true;
		                }
		                practiceMode = false;
		                activateStrategy();
		            }
			}
		});

		
		practiceButton.addActionListener(new ActionListener(){
			public void actionPerformed(ActionEvent e){
				if (JOptionPane.showConfirmDialog(bd, 
		                "Practice game?", "Battleship", JOptionPane.YES_NO_OPTION)
		                == JOptionPane.YES_OPTION) {
		                bd.startNewGame();
		                if(playMode){
		                	playMode = false;
		                }
		                practiceMode = true;
		                deactivateStrategy();
		            }
			}
		});
	}

	
	after(BattleshipDialog bd): makeVisible(bd){
		bd.setSize(335, 550);
	}

	after() : attack(){
		
		if(strategy != Strategy.Berserk){
			if(turn) play();
			else changeTurn();
		}else if(strategy == Strategy.Berserk){
			if(unfairTurn++ < 3){
				play();
			}
			else{
				unfairTurn = 0;
				changeTurn();
			}
		}
		else if(strategy == null)
			return;
	}

	after() : restartGame(){
		playerBoard.reset();
		placesHit.removeAll(placesHit);
		placeShips(playerBoard);
	}

	after() returning(boolean status) : endGame(){
		if(status){
			System.out.println("Is game over? -> "+status);
		}
	}

	////////////////////////////////

	public void changeTurn(){
		turn = !turn;
	}

	public void play(){
		changeTurn();
		if(strategy == Strategy.Random)	randomStrategy();
		else if(strategy == Strategy.Sweep) sweepStrategy();
		else if(strategy == Strategy.Smart) smartStrategy();
		else if(strategy == Strategy.Berserk) berserkStrategy();
	}

	public void activateStrategy(){
		strategy = (Strategy)strategies.getSelectedItem();
	} 
	
	
	public void deactivateStrategy(){
		strategy = null;
	} 
	

	public void randomStrategy(){
		Place p = selectRandomPlace();
		playerBoardPanel.placeClicked(p);
		placesHit.add(p);
	}

	public void sweepStrategy(){

		Place p = selectSweepPlace();
		playerBoardPanel.placeClicked(p);
	}

	public void berserkStrategy(){
		Place p = selectRandomPlace();
		playerBoardPanel.placeClicked(p);
		placesHit.add(p);
	}

	public void smartStrategy(){
		System.out.println("Smart Strategy");

		/* TODO FIX INFINITE LOOP*/

		//		if(target != null){
		//			destroyTarget();
		//		}
		//		else{
		//			Place p = null;
		//			p = selectRandomPlace();
		//			playerBoardPanel.placeClicked(p);
		//			placesHit.add(p);
		//			if(p.hasShip())
		//				target = new Place(p.getX(), p.getY(), playerBoard);
		//		}
	}

	public void impossibleStrategy(){System.out.println("Impossible Strategy");}

	public boolean hunt(){

		selectSearchPlace();
		System.out.println("Selected to Search at: X"+search.getX()
		+", Y:"+search.getY());

		while((search.getX() > 10 && search.getX() < 1) 
				|| (search.getY() > 10 && search.getY() < 1)){
			changeDirection();
			selectSearchPlace();
			System.out.println("OUT OF BOUNDS");
			System.out.println("Changing Search to: X"+search.getX()
			+", Y:"+search.getY());
		}

		if(!search.isHit())
			playerBoardPanel.placeClicked(search);

		if(search.hasShip()){
			if(search.ship().isSunk()){
				this.target = null;
				return true;
			}
			else{
				target = search;
				return true;
			}
		}
		else
			return false;
	}

	public void destroyTarget(){
		while(target != null){
			System.out.println("Hunting!");
			hunt();
		}		
	}

	public void selectSearchPlace(){
		if(dir == Direction.LEFT)
			search = new Place(target.getX() + 1, target.getY(), playerBoard);
		else if(dir == Direction.RIGHT)
			search = new Place(target.getX() -1, target.getY(), playerBoard);
		else if(dir == Direction.UP)
			search = new Place(target.getX(), target.getY() +1, playerBoard);
		else
			search = new Place(target.getX(), target.getY() - 1, playerBoard);
	}

	public void changeDirection(){
		if(this.dir == Direction.LEFT)
			this.dir = Direction.DOWN;
		else if(this.dir == Direction.RIGHT)
			this.dir = Direction.UP;
		else if(this.dir == Direction.DOWN)
			this.dir = Direction.RIGHT;
		else
			this.dir = Direction.LEFT;
	}

	public Place selectRandomPlace(){
		Place p;
		int i, j;
		do {
			i = random.nextInt(98) + 26;
			j = random.nextInt(98) + 11;
			p = playerBoardPanel.locatePlace(i, j); 
		} while (p == null || placesHit.contains(p));
		return p;
	}

		public Place selectSweepPlace(){
		if(sweepTarget[1] == 101 && sweepTarget[0] < 121){
			sweepTarget[0] += 10;
			sweepTarget[1] = 11;
			return playerBoardPanel.locatePlace(sweepTarget[0], sweepTarget[1]); 		
		}
		sweepTarget[1] += 10;
		return playerBoardPanel.locatePlace(sweepTarget[0], sweepTarget[1]); 
	}



	public void updateButtons(JPanel contents){
		buttonsPanel = (JPanel)contents.getComponent(0);			// Catching button panel
		practiceButton = (JButton)buttonsPanel.getComponent(0);		// Catching button within panel
		practiceButton.setText("Practice");							//Updating play button		
		reconfigureGUI();		
		
	}


	public void reconfigureGUI(){

		buttonsPanel.removeAll();							
		buttonsPanel.setLayout(new BorderLayout());			

		playerBoardPanel = new SmallBoardPanel(new Board(10),		
				DEFAULT_TOP_MARGIN, 25, 10, DEFAULT_BOARD_COLOR, 
				DEFAULT_HIT_COLOR, DEFAULT_MISS_COLOR);

		playerBoard = playerBoardPanel.board;						

		
		JPanel northPanel = new JPanel(new FlowLayout(FlowLayout.LEADING, 25, 5));
		northPanel.add(practiceButton);
		northPanel.add(playButton);
		northPanel.add(strategies);

		
		JPanel centerPanel = new JPanel(new GridLayout(1,2));

		
		JPanel shipsPanel = new JPanel();
		BoxLayout boxlayout = new BoxLayout(shipsPanel, BoxLayout.Y_AXIS);
		shipsPanel.setLayout(boxlayout);

		Border paddingShipLabel = BorderFactory.createEmptyBorder(3,0,3,5);
		Border border = BorderFactory.createLineBorder(Color.LIGHT_GRAY); //TODO remove color

		JLabel ship1 = new JLabel("Porta aviones");
		JLabel ship2 = new JLabel("Battleship");
		JLabel ship3 = new JLabel("Submarinos");
		JLabel ship4 = new JLabel("Fragatas");
		JLabel ship5 = new JLabel("Minesweeper");
		ship1.setBorder(BorderFactory.createCompoundBorder(border, paddingShipLabel));
		ship2.setBorder(BorderFactory.createCompoundBorder(border, paddingShipLabel));
		ship3.setBorder(BorderFactory.createCompoundBorder(border, paddingShipLabel));
		ship4.setBorder(BorderFactory.createCompoundBorder(border, paddingShipLabel));
		ship5.setBorder(BorderFactory.createCompoundBorder(border, paddingShipLabel));

		shipsPanel.add(ship1);
		shipsPanel.add(ship2);
		shipsPanel.add(ship3);
		shipsPanel.add(ship4);
		shipsPanel.add(ship5);

		placeShips(playerBoard); //TODO do not reuse base code here

		centerPanel.add(shipsPanel);
		centerPanel.add(playerBoardPanel);

		
		buttonsPanel.add(northPanel,BorderLayout.NORTH);
		buttonsPanel.add(centerPanel, BorderLayout.CENTER);		

		//shipsPanel.setBorder(new LineBorder(Color.BLUE));
		centerPanel.setBorder(BorderFactory.createDashedBorder(Color.BLACK));
		northPanel.setBorder(new LineBorder(Color.MAGENTA));

	}

	public static void placeShips(Board board) {
		Random random = new Random();
		int size = board.size();
		for (Ship ship : board.ships()) {
			int i = 0;
			int j = 0;
			boolean dir = false;
			do {
				i = random.nextInt(size) + 1;
				j = random.nextInt(size) + 1;
				dir = random.nextBoolean();
			} while (!board.placeShip(ship, i, j, dir));
		}
	}
}
