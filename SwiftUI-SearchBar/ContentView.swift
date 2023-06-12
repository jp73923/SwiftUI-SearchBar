//
//  ContentView.swift
//  SwiftUI-SearchBar
//
//  Created by macOS on 12/06/23.
//

import SwiftUI

struct ContentView: View {
    
    @State private var arrProducts : [Product] = []
    @State private var searchItem = ""
    
    var filterProducts : [Product] {
        guard !searchItem.isEmpty else { return arrProducts }
        return arrProducts.filter { $0.title.localizedCaseInsensitiveContains(searchItem) }
    }
    
    var body: some View {
        NavigationStack {
            List(filterProducts, id: \.id) { follower in
                HStack(spacing: 20) {
                    AsyncImage(url: URL(string: follower.image)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: SwiftUI.ContentMode.fit)
                            .cornerRadius(5)
                    } placeholder: {
                        Image("")
                            .resizable()
                            .foregroundColor(.secondary)
                            .frame(width: 100, height: 100)
                        ProgressView().progressViewStyle(.circular)
                    }
                    .frame(width: 100, height: 100)
                    
                    Text(follower.title)
                        .font(.title3)
                }
            }
            .navigationTitle("Products")
            .task {
                do {
                    arrProducts = try await getProducts()
                } catch GHError.invalidURL {
                    print("Invalid URL")
                } catch GHError.invalidResponse {
                    print("Invalid Resposne")
                } catch GHError.invalidData {
                    print("Invalid Data")
                } catch {
                    print("Unexpected error")
                }
            }
            .searchable(text: $searchItem, prompt: "Search Products")
        }

    }
    
    func getProducts() async throws -> [Product] {
        let endpoint = "https://fakestoreapi.com/products"
        
        guard let url = URL(string: endpoint) else {
            throw GHError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw GHError.invalidResponse
        }
                
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode([Product].self, from: data)
        } catch {
            throw GHError.invalidData
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct Product:Codable {
    let id: Int
    let title: String
    let image: String
}

enum GHError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}
