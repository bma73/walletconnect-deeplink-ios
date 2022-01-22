import SwiftUI

struct ContentView: View {
    
    @StateObject var viewModel = WalletConnectViewModel()
    
    var body: some View {
        if let accountId = viewModel.accountId {
            Text(accountId)
                .lineLimit(1)
                .truncationMode(.middle)
                .padding()
        } else {
            VStack {
                Button(action: {
                    viewModel.connect(to: .metaMask)
                }, label: {
                    Text("Connect to MetaMask")
                })
                    .padding()
                
                Button(action: {
                    viewModel.connect(to: .trust)
                }, label: {
                    Text("Connect to Trust")
                })
                    .padding()
            }
        }
    }
}
