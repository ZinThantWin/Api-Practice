import SwiftUI

struct MainScreen: View {
    @State var user : GithubUser?

    var body: some View {
        VStack(spacing: 10){
            AsyncImage(url: URL(string: user?.avatarUrl ?? "")) { phase in
                switch phase {
                case .empty:
                    Circle()
                        .foregroundColor(.secondary)
                        .frame(width: 150, height: 150)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                case .failure:
                    Circle()
                        .foregroundColor(.secondary)
                        .frame(width: 150, height: 150)
                @unknown default:
                    Circle()
                        .foregroundColor(.secondary)
                        .frame(width: 150, height: 150)
                }
            }
            
            
            UserName(userName: user?.name ?? "loading")
                .padding(.bottom, 30)
            DescriptionText(description: user?.bio ?? "this is the dummy description , it should be very long to test.")
            
            Button("get call"){
                Task{
                    await apiCall()
                }
            }
            Spacer()
        }.padding()
    }
    
    
    func apiCall()async{
        do{
            user = try await getUser()
        } catch GHError.invalidURL{
            print("URL error")
        } catch GHError.invalidData{
            print("data error")
        } catch GHError.invalidResponse{
            print("response error")
        } catch {
            print("error")
        }
    }
}



#Preview {
    MainScreen()
}


func getUser() async throws -> GithubUser {
    let endpoint: String = "https://api.github.com/users/sallen0400"
    guard let url = URL (string: endpoint) else {
        throw GHError.invalidURL
    }
    let (data,response) = try await URLSession.shared.data(from: url)

    guard let response = response as? HTTPURLResponse , response.statusCode == 200 else{
        throw GHError.invalidResponse
    }
    
    
    do {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(GithubUser.self, from: data)
    }catch{
        throw GHError.invalidData
    }
    
}

struct GithubUser : Codable {
    let avatarUrl : String
    let name : String
    let bio : String
}

enum GHError: Error{
    case invalidURL
    case invalidResponse
    case invalidData
}
