//
//  UserViewModel.swift
//  GithubAPISearchUsersDemo
//
//  Created by Ling on 2021/11/30.
//

import Foundation

class UserViewModel: ObservableObject {
    @Published var users: [User] = [defaultUser]
    
    func getGithubapiUsers(name: String,
                           page: Int,
                           success: @escaping (UsersResponce) -> Void,
                           failure: @escaping ((String) -> Void)) {
        
        // 查詢 匹配用戶名中包含"name"一詞的用戶，每頁15筆資料
        let serverUrl = "https://api.github.com/search/users?q=\(name)in:login&per_page=15&page=\(page)"
        
        guard let url = URL(string: serverUrl) else {
            failure("error"); return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                failure("ERR_HTTP_CONNECTION")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200:
                    if let data = data {
                        if let decodedStruct = try? JSONDecoder().decode(UsersResponce.self, from: data) {
                            success(decodedStruct)
                        }else {
                            failure("ERR_JSON_TRANSFORM")
                        }
                    }else {
                        failure("ERR_HTTP_NOT_RETURN_DATA")
                    }
                default:
                    failure("ERR_HTTP_REJECTED_REQUEST")
                }
            }else {
                failure("ERR_HTTP_RESPONSE")
            } // end if
        }.resume() // end URLSession
    }
    
}
