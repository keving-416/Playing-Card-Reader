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
import AVFoundation

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var playingCardLabel: UILabel!
    @IBOutlet weak var playingCardLabelView: UIView!
    
    let synthesizer = AVSpeechSynthesizer()
    
    var currentAnchor: ARAnchor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = false
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        do {
            // Set up audio session to allow for audio playback when phone is on silent mode
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        }
        catch let error {
            // report for an error
            print("Error in AVAudioSession: \(String(describing: error))")
        }
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
        
        // Set maximum number of tracked images
        //configuration.maximumNumberOfTrackedImages = 1

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

            // Safely unwrap currentAnchor
            if let pastAnchor = currentAnchor {
                // Remove the anchor from the sceneView session
                sceneView.session.remove(anchor: pastAnchor)
            }
            
            // Asynchronously dispatch to the main thread (from a background thread) to update UI elements
            DispatchQueue.main.async {
                // Make the playing card label view visible
                self.playingCardLabelView.alpha = 1.0
                
                // Synthesize speech of the playing card label whenever it is set
                let utterance = AVSpeechUtterance(string: referenceImageName!)
                utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                utterance.rate = 0.55
                
                self.synthesizer.speak(utterance)
                
                // Set the text of the playing card label to the name of the detected image, which should be
                //  name of the playing card
                self.playingCardLabel.text = referenceImageName
                
                // Fade the playCardLabelView out
                UIView.animate(withDuration: 0.2, delay: 1.2, options: [], animations: {
                    self.playingCardLabelView.alpha = 0.0
                })
            }
            
            // Set current anchor
            currentAnchor = anchor
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
