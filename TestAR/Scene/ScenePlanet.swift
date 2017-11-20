//
//  ScenePlanet.swift
//  TestAR
//
//  Created by Justin Reid on 11/17/17.
//  Copyright © 2017 Justin Reid. All rights reserved.
//

import Foundation
import ARKit

/// Representation of a Planet that has been placed in the scene
class ScenePlanet {
    /// The planet data
    let planet: Planet
    
    var rootNode: SCNNode = SCNNode()
    var planetNode: SCNNode = SCNNode()
    var tapNode: SCNNode = SCNNode()
    
    init(baseData: Planet, planetScale: Float) {
        planet = baseData
        rootNode = SCNNode()
        rootNode.name = planet.name
        
        planetNode = createPlanetBody(planetData: planet)
        tapNode = createTappableArea()
        
        rootNode.addChildNode(planetNode)
        rootNode.addChildNode(tapNode)
        
        setScale(planetScale)
    }
    
    fileprivate func createTappableArea() -> SCNNode {
        let material = SCNMaterial()
        material.name = "tap"
        material.diffuse.contents = UIColor.clear
        
        let tapGeom = SCNPlane(width: 0.1, height: 0.1)
        tapGeom.materials = [material]
        
        let node = SCNNode(geometry: tapGeom)
        
        let directionConstraint = SCNBillboardConstraint()
        node.constraints = [directionConstraint]
        
        return node
    }
    
    fileprivate func createPlanetBody(planetData: Planet) -> SCNNode {
        let material = SCNMaterial()
        material.name = planet.name
        material.diffuse.contents = planet.image
        
        let sphere = SCNNode(geometry: SCNSphere(radius: 1))
        sphere.geometry?.materials = [material]
        
        return sphere
    }
    
    /// Resize the planet model
    func setScale(_ planetScale: Float) {
        let scaledRadius = planet.scaledRadius(planetSize: planetScale)
        planetNode.scale = SCNVector3Make(scaledRadius, scaledRadius, scaledRadius)
    }
    
    /// Enable the tap node
    func setTappable(_ isTappable: Bool) {
        tapNode.removeFromParentNode()
        
        if(isTappable) {
            rootNode.addChildNode(tapNode)
        }
    }
}
