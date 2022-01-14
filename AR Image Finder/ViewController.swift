//
//  ViewController.swift
//  AR Image Finder
//
//  Created by Konstantin Ryabtsev on 14.01.2022.
//

import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    let videoPlayer: AVPlayer = {
        let url = Bundle.main.url(forResource: "replace_720", withExtension: "mov", subdirectory: "art.scnassets")!
        return AVPlayer(url: url)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        //let configuration = ARWorldTrackingConfiguration()
        //configuration.detectionImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil)
        //configuration.planeDetection = [.horizontal]
        
        let configuration = ARImageTrackingConfiguration()
        
        /*
        if ARImageTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) {
            configuration.frameSemantics.insert(.personSegmentationWithDepth)
        }
        */
        
        //configuration.maximumNumberOfTrackedImages = 2
        configuration.trackingImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil)!

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // Check that we've got an image anchor
        
        switch anchor {
        case let imageAnchor as ARImageAnchor:
            nodeAdded(node, for: imageAnchor)
        case let planeAnchor as ARPlaneAnchor:
            nodeAdded(node, for: planeAnchor)
        default:
            print(#line, #function, "Unknown anchor has been discovered")
        }
    }
    
    func nodeAdded(_ node: SCNNode, for imageAnchor: ARImageAnchor) {
        // Get image size
        let image = imageAnchor.referenceImage
        let size = image.physicalSize
        
        // Create plane of the same size
        let heigh = size.height * 1.05
        let width = size.width * 1.05
        let plane = SCNPlane(width: width, height: heigh)
        plane.firstMaterial?.diffuse.contents = videoPlayer
        
        videoPlayer.play()
        videoPlayer.volume = 1
                
        // Create plane node
        let planeNode = SCNNode(geometry: plane)
        planeNode.eulerAngles.x = -.pi / 2
        
        // Run animation
        planeNode.runAction(
            .sequence([
                .wait(duration: 41),
                .fadeOut(duration: 3),
                .removeFromParentNode()
            ])
        )
        
        // Add plane node to the given node
        node.addChildNode(planeNode)
        
    }
    
    func nodeAdded(_ node: SCNNode, for planeAnchor: ARPlaneAnchor) {
        print(#line, #function, "Plane \(planeAnchor) added")
    }
    
}
