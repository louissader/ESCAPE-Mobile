import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let skView = view as? SKView else { return }

        // Debug helpers (disable for App Store release)
        #if DEBUG
        skView.showsFPS = true
        skView.showsNodeCount = true
        #endif

        skView.ignoresSiblingOrder = true

        let scene = MenuScene(size: skView.bounds.size)
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
    }

    override var prefersStatusBarHidden: Bool { true }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .landscape }
}
