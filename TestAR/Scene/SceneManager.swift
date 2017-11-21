//
//  SceneManager.swift
//  TestAR
//
//  Created by Justin Reid on 11/17/17.
//  Copyright © 2017 Justin Reid. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

class SceneManager {
    private var _systemSize: Float = 4
    private var _planetSize: Float = 0.04
    private var _timeScale: Float = 100
    
    private static let worldOffset = SCNVector3Make(-2, 0, -3)
    /// How far from origin should the focus planet be
    private var offset = worldOffset
    /// Which planet should be at the origin
    private var focusPlanet: ScenePlanet?
    private var planetMap: [String:ScenePlanet]
    
    private var elapsedTime: Double = 0
    private var lastFrame: Double = 0
    
    public let rootNode: SCNNode
    
    init() {
        planetMap = [:]
        rootNode = SCNNode()
        
        /// Build all planet nodes
        createScenePlanet(planet: Planet.SUN, sceneRoot: rootNode)
    }
    
    public func getFocusPlanet() -> Planet {
        return focusPlanet?.planet ?? Planet.SUN
    }
    
    fileprivate func createScenePlanet(planet: Planet, sceneRoot: SCNNode) {
        let scenePlanet = ScenePlanet(baseData: planet, planetScale: planetSize)
        sceneRoot.addChildNode(scenePlanet.rootNode)
        
        planetMap[planet.name] = scenePlanet
        
        for child in planet.children {
            createScenePlanet(planet: child, sceneRoot: sceneRoot)
        }
    }
    
    /// The radius of the solar system orbit distances, in meters.
    var systemSize: Float {
        set(newSize) {
            _systemSize = newSize
        }
        get {
            return _systemSize
        }
    }
    
    /// The radius of Jupiter, in meters. The other planets will be to-scale.
    var planetSize: Float {
        set(newSize) {
            _planetSize = newSize
        }
        get {
            return _planetSize
        }
    }
    
    /// One year in seconds.
    var timeScale: Float {
        set(newSize) {
            _timeScale = newSize
        }
        get {
            return _timeScale
        }
    }
    
    /// The planet to focus on, and how far away to place that planet after all scaling shenanigans are done
    public func centerSystem(focusName: String) {
        guard let focusScenePlanet = planetMap[focusName] else {
            return
        }
        
        if(focusScenePlanet === focusPlanet || focusScenePlanet === planetMap[Planet.SUN.name]) {
            focusPlanet = planetMap[Planet.SUN.name]
            offset = SceneManager.worldOffset
        } else {
            focusPlanet = focusScenePlanet
            offset = focusScenePlanet.rootNode.worldPosition
        }
    }
    
    /// Update the scene
    public func update(renderer: SCNSceneRenderer, systemTime: TimeInterval, camera: ARCamera) -> [ScreenPlanet] {
        guard let rootScenePlanet = planetMap[Planet.SUN.name] else {
            return []
        }
        
        // Move planets to focus on one
        guard let focusScenePlanet = focusPlanet ?? planetMap[Planet.SUN.name] else {
            return []
        }
        
        // Passage of time
        if(lastFrame == 0) {
            elapsedTime = 0
        } else {
            elapsedTime = elapsedTime + (systemTime - lastFrame) * Double(timeScale)
        }
        lastFrame = systemTime
        
        // Scale the system up if we are focused on a planet
        var currentSystemScale = self.systemSize
        var currentPlanetScale = self.planetSize
        if(rootScenePlanet !== focusScenePlanet) {
            let zoomFactor = Planet.SOLAR_SYSTEM_SIZE / Planet.LUNA.orbitRadius
            currentSystemScale = Float(Double(self.systemSize) * zoomFactor)
            currentPlanetScale = Float(Double(self.planetSize) * zoomFactor)
        }
        
        // Position all planets based on 0,0,0
        positionPlanet(scenePlanet: rootScenePlanet, atRealTime: elapsedTime, parentPos: SCNVector3Make(0,0,0), parentRadius: rootScenePlanet.planetNode.scale.x, withSystemScale: currentSystemScale, withPlanetScale: currentPlanetScale)
        
        let focusOffset = SCNVector3Make(-focusScenePlanet.rootNode.worldPosition.x, -focusScenePlanet.rootNode.worldPosition.y, -focusScenePlanet.rootNode.worldPosition.z)
        let radiusOffset = SCNVector3Make(0, 0, focusScenePlanet.planetNode.scale.z * 1.5) // Should be offset by radius*cameraDirection at the time of zooming
        let totalOffset = SCNVector3Make(focusOffset.x + offset.x + radiusOffset.x, focusOffset.y + offset.y + radiusOffset.y, focusOffset.z + offset.z + radiusOffset.z)
        
        for scenePlanet in planetMap.values {
            scenePlanet.rootNode.localTranslate(by: totalOffset)
        }
        
        guard let pov = renderer.pointOfView else {
            return []
        }
        
        // Update planet properties
        var iconPoints:[ScreenPlanet] = []
        for scenePlanet in planetMap.values {
            let isFocus = isFocused(planet: scenePlanet.planet)
            let isMain = scenePlanet.planet === Planet.SUN || Planet.SUN.children.contains(where: {
                $0 === scenePlanet.planet
            })
            scenePlanet.setTappable(isFocus)

            // Collect 2d position if it is visible
            if((isFocus || isMain) && renderer.isNode(scenePlanet.rootNode, insideFrustumOf: pov)) {
                let v = renderer.projectPoint(scenePlanet.rootNode.worldPosition)
                let p = CGPoint(x: CGFloat(v.x), y: CGFloat(v.y))
                
                // Don't add points behind the camera
                if(v.z > 0) {
                    iconPoints.append(ScreenPlanet(position: p, planet: scenePlanet.planet))
                }
            }
        }
        
        return iconPoints
    }
    
    /// Is the planet the focused planet, or the immediate child of a focused planet
    fileprivate func isFocused(planet: Planet) -> Bool {
        let focus = focusPlanet?.planet ?? Planet.SUN
        
        return focus === planet || focus.children.contains(where: {
            $0 === planet
        })
    }
    
    fileprivate func positionPlanet(scenePlanet: ScenePlanet, atRealTime: TimeInterval, parentPos: SCNVector3, parentRadius: Float, withSystemScale: Float, withPlanetScale: Float) {
        let orbitsCompleted: Double
        if(scenePlanet.planet.orbitPeriod > 0) {
            orbitsCompleted = atRealTime / scenePlanet.planet.orbitPeriod
        } else {
            orbitsCompleted = 0
        }
        
        let orbitAngle = Double.pi * 2 * orbitsCompleted
        
        let scaledDistance = scenePlanet.planet.scaledOrbit(solarSystemSize: withSystemScale) + Double(parentRadius) // <-- cheating
        let scaledLocalPos = SCNVector3Make(Float(scaledDistance * cos(orbitAngle)), 0, Float(scaledDistance * sin(orbitAngle)))
        let scaledPos = SCNVector3Make(scaledLocalPos.x + parentPos.x, scaledLocalPos.y + parentPos.y, scaledLocalPos.z + parentPos.z)

        let rotationCompleted = atRealTime / scenePlanet.planet.planetPeriod
        let rotationAngle = Double.pi * 2 * rotationCompleted
        
        scenePlanet.rootNode.position = scaledPos
        scenePlanet.planetNode.rotation = SCNVector4Make(0, -1, 0, Float(rotationAngle))
        scenePlanet.setScale(withPlanetScale)
        
        let radius = scenePlanet.planetNode.scale.x
        
        // Position satellites
        for child in scenePlanet.planet.children {
            if let scenePlanet = planetMap[child.name] {
                positionPlanet(scenePlanet: scenePlanet, atRealTime: atRealTime, parentPos: scaledPos, parentRadius: radius, withSystemScale: withSystemScale, withPlanetScale: withPlanetScale)
            }
        }
    }
}
