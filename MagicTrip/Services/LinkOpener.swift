import SafariServices
import UIKit

struct LinkOpener {
    private static let trustedDomains: Set<String> = [
        "br.usembassy.gov", "gov.br", "disneyland.disney.go.com",
        "disneyworld.disney.go.com", "universalorlando.com",
        "visitorlando.com", "receita.fazenda.gov.br",
        "disabilityservicesatdisneyworld.com"
    ]

    @MainActor
    static func open(urlString: String, from viewController: UIViewController? = nil) {
        guard let url = URL(string: urlString),
              let host = url.host else { return }

        let isTrusted = trustedDomains.contains(where: { host.hasSuffix($0) })

        if isTrusted {
            present(url: url, from: viewController)
        } else {
            // Show confirmation alert for unknown domains
            let alert = UIAlertController(
                title: host,
                message: NSLocalizedString("Abrir este site externo?", comment: ""),
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancelar", comment: ""), style: .cancel))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Abrir", comment: ""), style: .default) { _ in
                present(url: url, from: viewController)
            })
            viewController?.present(alert, animated: true)
        }
    }

    private static func present(url: URL, from vc: UIViewController?) {
        let safari = SFSafariViewController(url: url)
        safari.preferredControlTintColor = UIColor(red: 0.83, green: 0.33, blue: 0.18, alpha: 1)
        vc?.present(safari, animated: true)
    }
}
