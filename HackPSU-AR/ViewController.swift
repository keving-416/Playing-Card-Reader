//
//  ViewController.swift
//  HackPSU-AR
//
//  Created by Kevin Gardner on 3/16/19.
//  Copyright © 2019 HackAR. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var playingCardLabel: UILabel!
    @IBOutlet weak var playingCardLabelView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        playingCardLabelView.alpha = 0.0
        playingCardLabelView.layer.cornerRadius = 10
        
        // Create set of detection images from AR Resources folder in the Assets.xcassets folder
        guard let detectionImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }
        
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()
        
        // Add detection images to the ARConfiguration
        configuration.trackingImages = detectionImages

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        
        // Check for a detected image
        if let imageAnchor = anchor as? ARImageAnchor {
            // Store the name of the detected image
            let referenceImageName = imageAnchor.referenceImage.name
            
            // Asynchronously dispatch to the main thread (from a background thread) to update UI elements
            DispatchQueue.main.async {
                // Make the playing card label view visible
                self.playingCardLabelView.alpha = 1.0
                
                // Set the text of the playing card label to the name of the detected image, which should be
                //  name of the playing card
                self.playingCardLabel.text = referenceImageName
            }
        }
     
        return node
    }

    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
