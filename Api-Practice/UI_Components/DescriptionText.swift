import SwiftUI

struct DescriptionText: View {
    let description : String 
    var body: some View {
        Text(description)
            .font(.body)
    }
}
