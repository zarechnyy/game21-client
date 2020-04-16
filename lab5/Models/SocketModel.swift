//
//  SocketModels.swift
//  MyMessenger
//
//  Created by Yaroslav Zarechnyy on 4/8/20.
//  Copyright © 2020 Yaroslav Zarechnyy. All rights reserved.
//

import Foundation

struct SocketResponseCommand: Codable {
    var type: Int
    var model: Model
    
    init(type: Int, model: Model) {
        self.type = type
        self.model = model
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(Int.self, forKey: .type)
        self.type = type
        switch type {
        case 0:
            let payload = try container.decode(SocketMessageModel.self, forKey: .model)
            self.model = .create(payload)
        case 1:
            let payload = try container.decode(SocketCardModel.self, forKey: .model)
            self.model = .getCard(payload)
        default:
            self.model = .unsupported
        }
    }
}

enum Model: Codable {
    case create(SocketMessageModel)
    case getCard(SocketCardModel)
    case unsupported
}

struct SocketMessageModel: Codable {
    let message: String
}

struct SocketCardModel: Codable {
    var userScore: Int = 0
    var serverScore: Int = 0
}

extension Model {
    private enum CodingKeys: String, CodingKey {
        case message
        case card
        case serverScore
        case userScore
        case type
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .create(let model):
            try container.encode(model.message, forKey: .message)
        case .getCard(let model):
            try container.encode(model.serverScore, forKey: .serverScore)
            try container.encode(model.userScore, forKey: .userScore)
        case .unsupported:
            let context = EncodingError.Context(codingPath: [], debugDescription: "Invalid attachment.")
            throw EncodingError.invalidValue(self, context)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(Int.self, forKey: .type)
        switch type {
        case 0:
            let payload = try container.decode(SocketMessageModel.self, forKey: .message)
            self = .create(payload)
        case 1:
            let payload = try container.decode(SocketCardModel.self, forKey: .message)
            self = .getCard(payload)
        default:
            self = .unsupported
        }
    }
}
