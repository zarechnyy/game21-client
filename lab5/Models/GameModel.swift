//
//  GameModel.swift
//  lab5
//
//  Created by Yaroslav Zarechnyy on 4/15/20.
//  Copyright © 2020 Yaroslav Zarechnyy. All rights reserved.
//

import Foundation

struct GameModel {
    
    enum Winner {
        case user, server, draw
    }
    
    private var userScore: Int = 0
    private var serverScore: Int = 0
    
    mutating func update(_ userScore: Int, _ serverScore: Int) {
        self.userScore += userScore
        self.serverScore += serverScore
    }
    
    func getCurrentScore() -> (Int, Int) {
        return (userScore, serverScore)
    }
    
    func isGameFinished() -> Bool {
        return userScore >= 21 || serverScore >= 21 ? true : false
    }
    
    func whoWins() -> Winner {
        if userScore >= 21 && serverScore >= 21 {
            return Winner.draw
        }
        if userScore >= 21 {
            return Winner.user
        }
        return Winner.server
    }
    
    mutating func clear() {
        self.userScore = 0
        self.serverScore = 0
    }
}
