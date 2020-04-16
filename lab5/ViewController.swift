//
//  ViewController.swift
//  lab5
//
//  Created by Yaroslav Zarechnyy on 4/15/20.
//  Copyright © 2020 Yaroslav Zarechnyy. All rights reserved.
//

import UIKit
import Starscream

enum GameState {
    case pending
    case inProgress
}

class ViewController: UIViewController {

    @IBOutlet weak var userScoreLabel: UILabel!
    @IBOutlet weak var serverScoreLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    
    var socket: WebSocket!
    var gameState: GameState = .pending
    var currentGameModel = GameModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let request = URLRequest(url: URL(string: "ws://localhost:3000/ws")!)
        socket = WebSocket(request: request)
        socket.delegate = self
        socket.connect()
    }

    private func startGame() {
        let model = SocketResponseCommand(type: 0, model: .create(SocketMessageModel(message: "Start game")))
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(model)
            socket.write(data: data, completion: nil)
        } catch {
            print(error)
        }
    }
    
    private func getCard() {
        let model = SocketResponseCommand(type: 1, model: .create(SocketMessageModel(message: "Get card!")))
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(model)
            socket.write(data: data, completion: nil)
        } catch {
            print(error)
        }
    }
    
    private func showFinishedAlert() {
        let alert: UIAlertController!
        self.socket.disconnect()
        self.gameState = .pending
        
        switch self.currentGameModel.whoWins() {
        case .server:
            alert = UIAlertController(title: "Server is winner", message: nil, preferredStyle: .alert)
        case .user:
            alert = UIAlertController(title: "You are winner", message: nil, preferredStyle: .alert)
        case .draw:
            alert = UIAlertController(title: "Draw!", message: nil, preferredStyle: .alert)
        }
        
        alert.addAction(UIAlertAction(title: "Play again!", style: .default, handler: { (action) in
            self.socket.connect()
            self.currentGameModel.clear()
            self.userScoreLabel.text = "0"
            self.serverScoreLabel.text = "0"
            self.actionButton.setTitle("Play", for: .normal)
        }))
        present(alert, animated: true, completion: nil)
    }
}


//MARK: - Actions
extension ViewController {
    
    @IBAction func gameButtonAction(_ sender: UIButton) {
        switch gameState {
        case .pending:
            startGame()
            self.actionButton.setTitle("Get card!", for: .normal)
        case .inProgress:
            getCard()
        }
    }
}

extension ViewController: WebSocketDelegate {
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        print(event)
        switch event {
        case .text(let message):
            print(message)
            do {
                let decoder = JSONDecoder()
                let jsonData = Data(message.utf8)
                let model = try decoder.decode(SocketResponseCommand.self, from: jsonData)
                switch model.model {
                case .getCard(let cards):
                    self.currentGameModel.update(cards.userScore, cards.serverScore)
                    let score = self.currentGameModel.getCurrentScore()
                    self.userScoreLabel.text = "\(score.0)"
                    self.serverScoreLabel.text = "\(score.1)"
                    if self.currentGameModel.isGameFinished() {
                        self.showFinishedAlert()
                    }
                case .create(_):
                    self.gameState = .inProgress
                case .unsupported:
                    break
                }
            } catch let error {
                print(error)
            }
        default:
            break
        }
    }
}
