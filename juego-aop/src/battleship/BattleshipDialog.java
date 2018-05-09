package battleship;

import java.awt.BorderLayout;
import java.awt.Dimension;
import java.awt.FlowLayout;
import java.awt.event.ActionEvent;
import java.util.Random;

import javax.swing.BorderFactory;
import javax.swing.JButton;
import javax.swing.JDialog;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;

import battleship.model.Board;
import battleship.model.Ship;
import battleship.model.Place;
import battleship.BoardPanel;

@SuppressWarnings("serial")
public class BattleshipDialog extends JDialog {

    private final static Dimension DEFAULT_DIMENSION = new Dimension(335, 440);

    private final static Random random = new Random();

    private final JButton playButton = new JButton("Play");

    private final JLabel msgBar = new JLabel("Shots: 0");
    
    private Board board;
    
    public BattleshipDialog() {
    	this(DEFAULT_DIMENSION);
    }
    
    public BattleshipDialog(Dimension dim) {
        super((JFrame) null, "Battleship");
        board = new Board(10);
        board.addBoardChangeListener(createBoardChangeListener());
        placeShips();
        configureGui();
        setSize(dim);
        //setResizable(false);
        setLocationRelativeTo(null);
    }
	
    /** Configure UI. */
    private void configureGui() {
        setLayout(new BorderLayout());
        add(makeControlPane(), BorderLayout.NORTH);
        add(makeBoardPane(), BorderLayout.CENTER);
    }
    
    private JPanel makeControlPane() {
    	JPanel content = new JPanel(new BorderLayout());
        JPanel buttons = new JPanel(new FlowLayout(FlowLayout.LEFT));
        buttons.setBorder(BorderFactory.createEmptyBorder(0,5,0,0));
        buttons.add(playButton);
        playButton.setFocusPainted(false);
        playButton.addActionListener(this::playButtonClicked);
        content.add(buttons, BorderLayout.NORTH);
        msgBar.setBorder(BorderFactory.createEmptyBorder(5,10,0,0));
        content.add(msgBar, BorderLayout.SOUTH);
        return content;
    }
    
    private JPanel makeBoardPane() {
    	return new BoardPanel(board);
    }
    
    /** Place ships randomly. */
    private void placeShips() {
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
    
    private void playButtonClicked(ActionEvent event) {
        if (isGameOver()) {
            startNewGame();
        } else {
            if (JOptionPane.showConfirmDialog(BattleshipDialog.this, 
                "juagar nueva partida?", "Battleship", JOptionPane.YES_NO_OPTION)
                == JOptionPane.YES_OPTION) {
                startNewGame();
            }
        }
    }
    
    private boolean isGameOver() {
        return board.isGameOver();
    }
        
    private void startNewGame() {
    	msgBar.setText("Disparos: 0");
        board.reset();
        placeShips();
        repaint();
    }
    
    private Board.BoardChangeListener createBoardChangeListener() {
    	return new Board.BoardChangeAdapter() {
            public void hit(Place place, int numOfShots) {
                showMessage("Disparos: " + numOfShots);
            }

            public void gameOver(int numOfShots) {
                showMessage("Todos los barcos destruidos con " + numOfShots + " disparos!");
            }
        }; 
    }
    
   
    private void showMessage(String msg) {
        msgBar.setText(msg);
    }
        
    public static void main(String[] args) {
        BattleshipDialog dialog = new BattleshipDialog();
        dialog.setVisible(true);
        dialog.setDefaultCloseOperation(DISPOSE_ON_CLOSE);
    }
}
