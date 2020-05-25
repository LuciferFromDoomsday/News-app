//
//  ContentView.swift
//  News app
//
//  Created by admin on 5/20/20.
//  Copyright © 2020 Naimankhan Ayan. All rights reserved.
//
import Foundation
import SwiftUI
import SwiftyJSON
import SDWebImageSwiftUI
import SwiftUIPullToRefresh

extension Collection {
    func enumeratedArray() -> Array<(offset: Int, element: Self.Element)> {
        return Array(self.enumerated())
    }
}
struct Movie : Hashable , Codable ,Identifiable{
    static var count : Int = 0
    var id: String
    var title : String
    var img : String
    var desc: String
    var rating : String
    var date : String
    var bcg : String

    
}
struct DetailView : View {
    var movie: Movie
    
    
    var body : some View {
        NavigationView{
            Form{
                ZStack(alignment: .bottom){
                    WebImage(url: URL(string: movie.img)!)
                        .resizable()
                        .cornerRadius(20)
                        .frame(height: 400)
                        .aspectRatio(contentMode: .fit)
                    Rectangle()
                        .opacity(0.25)
                        .blur(radius:10)
                    
                    Text(movie.date)
                        
                        .font(.title)
                        .fontWeight(.heavy)
                        .colorScheme(.light)
                        .padding(.top , 360)
                        
                        .foregroundColor(Color.black)
                        .background(Rectangle()
                            .fill(Color.white)
                            .frame(width: 500, height: 25)
                            .position(x:30 , y :375)
                            .clipped())
                    
                    ZStack {
                        
                        
                    
                        Text(movie.rating)
                            .font(.title)
                            .fontWeight(.heavy)
                            .colorScheme(.light)
                            .foregroundColor(Color.black)
                            .position(x:30 , y :50)
                            .background(Circle()
                                
                                .fill(Color.white)
                                
                                
                                
                                .frame(width: 50, height: 50)
                                .position(x:30 , y :50)
                                .clipped())
                        
                        
                    }
                    
                    
                    Spacer()
                    
                    
                    
                    
                    
                }
                .listRowInsets(EdgeInsets())
                Text(movie.desc)
                    .font(.footnote)
                    .lineLimit(nil)
                lineSpacing(12)
          
           
                
             
                
            }
            Spacer()
        }.edgesIgnoringSafeArea(.top)
        
        
    }
    
}

struct ContentView: View {
    
    
    @ObservedObject var data = getMovie()
    func shuffle() {
        self.data.shuffle()
    }
    
    var body: some View {
        
        NavigationView {
            
            Form{
                GeometryReader { g -> Text in
                    let frame = g.frame(in: CoordinateSpace.global)
                    if frame.origin.y > 250{
                        self.data.shuffle()
                        return Text("Loading....")
                    }
                    else{
                        return Text("")
                    }
                }
                List{
                ForEach(data.movies.enumeratedArray(), id: \.element) { index , i in
                    
                    NavigationLink(destination : DetailView(movie:i)){
                        MovieOnAppear(i)
                      .onAppear{
                            if index == Movie.count - 1{
                           self.data.addExtra()
                                            
                            
                        }
                        
                    }
                    }
                    
                }  .navigationBarTitle("News" , displayMode: .inline )
                
                
                
            }.id(UUID())
                    
            
        }
        
    }
    }
    
    struct MovieOnAppear : View {
        var movie : Movie
        var body: some View{
            ZStack(alignment: .center) {
                                       
                                       
                                       WebImage(url: URL(string: movie.bcg)!)
                                           .resizable()
                                           .cornerRadius(20)
                                           .frame(height: 400)
                                           .aspectRatio(contentMode: .fit)
                                           .brightness(-0.3)
                                       ZStack {
                                           
                                        Text(movie.rating)
                                               .font(.title)
                                               .fontWeight(.heavy)
                                               .colorScheme(.light)
                                               .foregroundColor(Color.black)
                                               .position(x:30 , y :50)
                                               .background(Circle()
                                                   
                                                   .fill(Color.white)
                                                   
                                                   
                                                   
                                                   .frame(width: 50, height: 50)
                                                   .position(x:30 , y :50)
                                                   .clipped())
                                           
                                       }
                                       
                                       VStack {
                                       Text(movie.title)
                                               .font(.title)
                                               .fontWeight(.heavy)
                                               .colorScheme(.light)
                                               .foregroundColor(Color.white)
                                               .frame(maxWidth: .infinity, alignment: .center)
                                           Text(movie.date)
                                               .font(.title)
                                               .fontWeight(.heavy)
                                               .colorScheme(.light)
                                               .padding(.top , 60)
                                               .foregroundColor(Color.white)
                                           }
                                       }
        }
        init(_ movie: Movie){
            self.movie = movie
        }
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
    
    
    
    class getMovie: ObservableObject {
        static var reloader  : Int = 0
        static var page : Int = 0
        @Published var movies = [Movie]()
        
        init () {
            
            addExtra()
        }
        func shuffle() {
            movies.shuffle()
            
        }
        
        func addExtra(){
            getMovie.page += 1
            let source  = "https://api.themoviedb.org/3/movie/popular?api_key=82bb3b5cf7b870891c07d7d362fe888a&language=en-US&page=\(getMovie.page)&region=kz"
            let url = URL(string: source)!
            let session = URLSession(configuration: .default)
            session.dataTask(with: url){
                (data , _ , error) in
                if error != nil {
                    print(error?.localizedDescription ?? "Data Task Error")
                }
                let json = try! JSON(data: data!)
                for data in json["results"]{
                    
                    let title = data.1["original_title"].stringValue
                    let date = data.1["release_date"].stringValue
                    let desc = data.1["overview"].stringValue
                    let img = "https://image.tmdb.org/t/p/original/" + data.1["poster_path"].stringValue
                    let id = data.1["id"].stringValue
                    let bcg = "https://image.tmdb.org/t/p/original/" + data.1["backdrop_path"].stringValue
                    let fixRating: Double? = Double(data.1["vote_average"].stringValue) ?? 0
                    let rating = String(round(100*fixRating!)/100)
                   
                    DispatchQueue.main.async{
                        
                        
                        self.movies.append(Movie(id: id, title: title, img: img,  desc: desc, rating: rating, date: date, bcg: bcg ))
                     
                        Movie.count += 1
                    }
                }
                
                
                
            }.resume()
        }
    }
}
