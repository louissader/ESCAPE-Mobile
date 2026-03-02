import UIKit
import SpriteKit

class GameViewController: UIViewController {

    // Create the SKView programmatically — no storyboard needed
    override func loadView() {
        let skView = SKView()
        skView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view = skView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let skView = view as! SKView
        skView.ignoresSiblingOrder = true
        #if DEBUG
        skView.showsFPS = true
        skView.showsNodeCount = true
        #endif
    }

    // Present the scene AFTER layout so bounds reflect the final landscape size.
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let skView = view as! SKView
        // Only present once — viewDidLayoutSubviews is called multiple times.
        guard skView.scene == nil else { return }
        let scene = MenuScene(size: skView.bounds.size)
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
    }

    override var prefersStatusBarHidden: Bool { true }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .landscape }
}
