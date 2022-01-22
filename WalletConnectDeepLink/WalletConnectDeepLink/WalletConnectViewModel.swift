import Combine
import WalletConnectSwift
import UIKit
import UIKit

// Wallet list -> https://registry.walletconnect.org/data/wallets.json
enum Wallet: String {
    case metaMask = "https://metamask.app.link"
    case trust = "https://link.trustwallet.com"
}

class WalletConnectViewModel: ObservableObject {
    @Published var accountId: String?
    
    //Keep strong reference to client!!
    private (set) var client: Client?
    private (set) var wcURL: WCURL?
    private (set) var wallet: Wallet?
    
    func connect(to wallet: Wallet) {
        
        self.wallet = wallet
        
        let bridge = "https://safe-walletconnect.gnosis.io"
        //        let bridge = "https://bridge.walletconnect.org" // doesn't work ?!
        
        
        guard let key = randomKey(),
              let bridgeURL = URL(string: bridge) else {
                  return
              }
        
        let meta = Session.ClientMeta(name: "DeepLinkTest",
                                      description: "Deep Link Testing",
                                      icons: [],
                                      url: URL(string: "https://bjoernacker.de")!)
        
        let info = Session.DAppInfo(peerId: UUID().uuidString,
                                    peerMeta: meta)
        
        wcURL = WCURL(topic: UUID().uuidString,
                       bridgeURL: bridgeURL,
                       key: key)
        
        client = Client(delegate: self, dAppInfo: info)
        do {
            try client?.connect(to: wcURL!)
            print("Connect to", wcURL?.absoluteString ?? "")
        } catch {
            print("Can't connect", error)
        }
    }
    
    private func openDeepLink() {
        guard let wallet = wallet,
              let wcURL = wcURL,
              let uri = wcURL.absoluteString.addingPercentEncoding(withAllowedCharacters: .alphanumerics),
              let url = URL(string: "\(wallet.rawValue)/wc?uri=\(uri)"),
              UIApplication.shared.canOpenURL(url) else {
                  print("Can't create deeplink")
                  return
              }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    private func randomKey() -> String? {
        var bytes = [Int8](repeating: 0, count: 32)
        let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        if status == errSecSuccess {
            return Data(bytes: bytes, count: 32).toHexString()
        } else {
            return nil
        }
    }
}

//MARK: - ClientDelegate
extension WalletConnectViewModel: ClientDelegate {
    func client(_ client: Client, didFailToConnect url: WCURL) {
        print("Did fail to connect to URL", url)
    }
    
    func client(_ client: Client, didConnect url: WCURL) {
        print("Did connect to URL", url)
   
        // Connection to brigde established
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.openDeepLink()
        }
    }
    
    func client(_ client: Client, didConnect session: Session) {
        print("Did connect to session", session)
        // Successfully connected to session
        accountId = session.walletInfo?.accounts.first
    }
    
    func client(_ client: Client, didDisconnect session: Session) {
        print("Did disconnect from session", session)
    }
    
    func client(_ client: Client, didUpdate session: Session) {
        print("Session did update", session)
    }
}
