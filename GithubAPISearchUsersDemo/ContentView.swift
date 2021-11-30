//
//  ContentView.swift
//  GithubAPISearchUsersDemo
//
//  Created by Ling on 2021/11/30.
//

import SwiftUI

struct ContentView: View {
    @StateObject var userVM = UserViewModel.init()
    
    @FocusState var nameIsFocused: Bool
    
    @State var progresToggle: Bool = false
    @State var scrollUpdateToggle: Bool = true
    @State var btnDisabledToggle: Bool = false
    
    @State var searchName: String = ""
    @State var page: Int = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.blue)
                        .padding(.vertical, 15)
                        .padding(.leading, 20)
                    TextField("Search Name", text: $searchName)
                        .submitLabel(.return)
                        .focused($nameIsFocused)
                    Button("Search") {
                        getUsers()
                    }.padding()
                        .disabled(btnDisabledToggle)
                }
                .overlay(RoundedRectangle(cornerRadius: 15).stroke(.blue,lineWidth: 1))
                .padding(20)
                
                ZStack {
                    if userVM.users.isEmpty {
                        self.noResultView()
                    }else {
                        ScrollView {
                            LazyVStack(spacing: 20) {
                                ForEach(0..<userVM.users.count, id: \.self) { index in
                                    CardView(user: $userVM.users[index])
                                        .onAppear(perform: {
                                            self.handleScrollUpdate(itemCount: userVM.users.count, displayIndex: index)
                                        })
                                } // end ForEach
                            }
                        }
                    }
                    self.progressView()
                        .opacity(progresToggle == true ? 1 : 0)
                }

            } // end VStack
            .navigationTitle("Search Users")
        }.navigationViewStyle(StackNavigationViewStyle())
    }
    
    func noResultView() -> some View {
        GeometryReader { geometry in
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title)
                    .foregroundColor(.gray)
                    .padding(.top, geometry.size.height / 4)
                Text("No results found")
                    .font(.title2)
                    .foregroundColor(.gray)
                    .padding(.top, geometry.size.height / 4)
            }.frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
        }
    }
    
    func progressView() -> some View {
        GeometryReader { geometry in
            ZStack { ProgressView() }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }.background(Color("bgColor"))
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension ContentView {
    func getUsers() {
        self.refreshSearchState()
        self.progresToggle.toggle()
        self.btnDisabledToggle.toggle()
        userVM.getGithubapiUsers(name: searchName, page: page, success: { resopnce in
            DispatchQueue.main.async {
                userVM.users = resopnce.items
                self.progresToggle.toggle()
                self.btnDisabledToggle.toggle()
            }
        }, failure: {error in
            self.progresToggle.toggle()
            self.btnDisabledToggle.toggle()
            print("api error \(error)")
        })
    } // end func
    
    func refreshSearchState() {
        nameIsFocused = false
        scrollUpdateToggle = true
        userVM.users = []
    } // end func
    
    func handleScrollUpdate(itemCount: Int, displayIndex: Int) {
        if scrollUpdateToggle {
            if itemCount < 15 {
                scrollUpdateToggle = false
                return
            }else {
                if displayIndex == itemCount - 2 {
                    self.scrollUpdateToggle = false
                    page += 1
                    
                    // http
                    userVM.getGithubapiUsers(name: searchName, page: page, success: { resopnce in
                        let newLists = resopnce.items
                        if newLists.count < 15 {
                            DispatchQueue.main.async {
                                for list in newLists {
                                    self.userVM.users.append(list)
                                }
                            } // end DispatchQueue
                        }else {
                            DispatchQueue.main.async {
                                for list in newLists {
                                    self.userVM.users.append(list)
                                }
                                self.scrollUpdateToggle = true
                            } // end DispatchQueue
                        } // end if
                    }, failure: {error in
                        print("api error \(error)")
                    })
                } // end if
            } // end if
        } // end if
    } // end func
}

struct CardView: View {
    @Binding var user: User
    var body: some View {
        VStack {
            HStack(spacing: 20) {
                AsyncImage(url: URL(string: user.avatar_url)) { image in
                    image.resizable()
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 80, height: 80)
                        .foregroundColor(Color.black.opacity(0.8))
                        .background(.white)
                }
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                Text(user.login)
                    .font(.title3.bold())
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .padding()
        }
        .padding(.vertical, 6)
        .background(
            LinearGradient(gradient: Gradient(colors: [.red, .purple]), startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(15)
        .padding(.horizontal)
        .shadow(radius: 0.5)
    }
}
