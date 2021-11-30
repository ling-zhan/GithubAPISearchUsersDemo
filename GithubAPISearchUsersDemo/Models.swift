//
//  Models.swift
//  GithubAPISearchUsersDemo
//
//  Created by Ling on 2021/11/30.
//

import Foundation

struct UsersResponce: Codable {
    let items: [User]
}

struct User: Codable {
    let id = UUID()
    let login: String
    let avatar_url: String
}

let defaultUser = User(login: "Ling.Z", avatar_url: "https://avatars.githubusercontent.com/u/66713866?v=4")
