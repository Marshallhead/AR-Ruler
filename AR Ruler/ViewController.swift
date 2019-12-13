//
//  ViewController.swift
//  AR Ruler
//
//  Created by Macbook on 12/12/2019.
//  Copyright © 2019 Marshall Lawal. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    var dotNodes = [SCNNode]()//used to keep track of all the dot notes on the scene
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]// we use this to determine which part of the scene are a continuous surface so we can measure something on that surface
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {// detect users touch on the screen
        if let touchLocation = touches.first?.location(in: sceneView){
            let hitTestResults = sceneView.hitTest(touchLocation, types: .featurePoint)// convert 2D to 3D by performing hittest, hittest looks for featurepoint matching and 3d continuous surface
            
            if let hitResult = hitTestResults.first {//grab first object in hitest result
                addDot(at: hitResult) //pass 3D location to addDot
            }
        }
    }
    
    func addDot(at hitResult: ARHitTestResult) {
        let dotGeometry = SCNSphere(radius: 0.005)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        
        let dotNode = SCNNode(geometry: dotGeometry)
        
        dotNode.position = SCNVector3(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z)
        sceneView.scene.rootNode.addChildNode(dotNode)
        
        dotNodes.append(dotNode)//adding the red dot node to the array of nodes
        
        if dotNodes.count >= 2 {
            calculate()
        }
        
    }
    func calculate (){
        let start = dotNodes[0]//first red dot we put on  the scene to start measuring
        let end = dotNodes[1]
        
        let a = end.position.x - start.position.x
        let b = end.position.y - start.position.y
        let c = end.position.z - start.position.z
        
        let distance = sqrt(pow(a, 2) + pow(b, 2) + pow(c, 2))
        
        updateText(text: "\(abs(distance))", atPosition: end.position)
        
    }
    func updateText(text: String, atPosition position: SCNVector3/*text position)*/){
        
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        
        let textNode = SCNNode(geometry: textGeometry)
        
        textNode.position = SCNVector3(position.x, position.y + 0.01, position.z)
        
        textNode.scale = SCNVector3(0.01, 0.01, 0.01)
        
        sceneView.scene.rootNode.addChildNode(textNode)
    }
    
}
