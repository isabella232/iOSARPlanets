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
    var textNode: SCNNode = SCNNode()
    
    var textGeometry: SCNText = SCNText()
    
    init(baseData: Planet, planetScale: Float) {
        planet = baseData
        rootNode = SCNNode()
        
        planetNode = createPlanetBody(planetData: planet)
        textNode = createText(name: planet.name)
        
        rootNode.name = "\(planet.name)_CoM"
        rootNode.addChildNode(planetNode)
        rootNode.addChildNode(textNode)
        //rootNode.addChildNode(createIcon())
        rootNode.addChildNode(createTappableArea())
        
        setScale(planetScale)
    }
    
    fileprivate func createTappableArea() -> SCNNode {
        let material = SCNMaterial()
        material.name = "tap"
        material.diffuse.contents = UIColor.clear
        
        let tapGeom = SCNPlane(width: 0.5, height: 0.5)
        tapGeom.materials = [material]
        
        let tapNode = SCNNode(geometry: tapGeom)
        
        // We can not put the billboard constraint directly onto a text node
        // Because Apple is broken
        // So this parent node only exists to hold the constraint
        let tapParentNode = SCNNode()
        tapParentNode.addChildNode(tapNode)
        
        let directionConstraint = SCNBillboardConstraint()
        tapParentNode.constraints = [directionConstraint]
        
        return tapParentNode
    }
    
    fileprivate func createIcon() -> SCNNode {
        let material = SCNMaterial()
        material.name = "icon"
        material.diffuse.contents = UIColor.white

        let iconGeom = SCNPlane(width: 0.364/2.0, height: 0.246/2.0)
        iconGeom.materials = [material]
        
        let iconNode = SCNNode(geometry: iconGeom)
        
        // We can not put the billboard constraint directly onto a text node
        // Because Apple is broken
        // So this parent node only exists to hold the constraint
        let iconParentNode = SCNNode()
        iconParentNode.addChildNode(iconNode)
        
        let directionConstraint = SCNBillboardConstraint()
        iconParentNode.constraints = [directionConstraint]
        
        return iconParentNode
    }
    
    fileprivate func createPlanetBody(planetData: Planet) -> SCNNode {
        let material = SCNMaterial()
        material.name = planet.name
        material.diffuse.contents = planet.image
        
        let sphere = SCNNode(geometry: SCNSphere(radius: 1))
        sphere.geometry?.materials = [material]
        sphere.name = "\(planet.name)_Surface"
        
        return sphere
    }
    
    /// Create a text node for this planet
    fileprivate func createText(name: String) -> SCNNode {
        textGeometry = SCNText(string: name, extrusionDepth: 0.1)
        textGeometry.flatness = 0.1
        
        let text = SCNNode(geometry: textGeometry)
        
        // Make the text anchor point center bottom
        let (textMin, textMax) = textGeometry.boundingBox
        text.pivot = SCNMatrix4MakeTranslation(textMin.x + (textMax.x - textMin.x) * 0.5, 0, 0)
        
        // We can not put the billboard constraint directly onto a text node
        // Because Apple is broken
        // So this parent node only exists to hold the constraint
        let textParentNode = SCNNode()
        textParentNode.addChildNode(text)
        
        let directionConstraint = SCNBillboardConstraint()
        textParentNode.constraints = [directionConstraint]
        textParentNode.position = SCNVector3Make(0, 1, 0)
        
        return textParentNode
    }
    func setScale(_ planetScale: Float) {
        let scaledRadius = planet.scaledRadius(planetSize: planetScale)
        planetNode.scale = SCNVector3Make(scaledRadius, scaledRadius, scaledRadius)
        
        let (textMin, textMax) = textGeometry.boundingBox
        let textWidth = textMax.x - textMin.x
        let desiredTextWidth = max(scaledRadius * 4, 0.05)
        let textScale = desiredTextWidth / textWidth
        textNode.childNodes[0].scale = SCNVector3Make(textScale, textScale, textScale)
        
        let textHeight = textMax.y - textMin.y
        textNode.position = SCNVector3Make(0, scaledRadius + textHeight * textScale * 1.5, 0)
        
    }
}
