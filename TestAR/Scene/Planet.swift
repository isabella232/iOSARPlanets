//
//  Planet.swift
//  TestAR
//
//  Created by Justin Reid on 9/1/17.
//  Copyright © 2017 Justin Reid. All rights reserved.
//

import Foundation
import UIKit
import ARKit

class Planet {
    static let MERCURY = Planet(name: "Mercury", image: #imageLiteral(resourceName: "MercuryColor.png"), orbitRadius: 5.78944e10, orbitPeriod: 7.6e6, planetRadius: 2440000, planetPeriod: 5067000)
    static let VENUS = Planet(name: "Venus", image: #imageLiteral(resourceName: "VenusColor.png"), orbitRadius: 1.0771e11, orbitPeriod: 19.4e6, planetRadius: 6.052e6, planetPeriod: 10087200)
    
    static let LUNA = Planet(name: "Luna", image: #imageLiteral(resourceName: "MoonColor.png"), orbitRadius: 385000000, orbitPeriod: 2.333e+6, planetRadius: 1736482, planetPeriod: 2360448)
    static let EARTH = Planet(name: "Earth", image: #imageLiteral(resourceName: "Earth.jpg"), orbitRadius: 1.496e11, orbitPeriod: 31558118.4, planetRadius: 6371393, planetPeriod: 86164.0905,
                              children: [LUNA])
    
    
    static let DEIMOS = Planet(name: "Deimos", image: #imageLiteral(resourceName: "DeimosColor.png"), orbitRadius: 2.346E+07, orbitPeriod: 109080, planetRadius: 6600, planetPeriod: 109080)
    static let PHOBOS = Planet(name: "Phobos", image: #imageLiteral(resourceName: "PhobosColor.png"), orbitRadius: 9.376E+06, orbitPeriod: 27552, planetRadius: 11266.7, planetPeriod: 27552)
    static let MARS = Planet(name: "Mars", image: #imageLiteral(resourceName: "MarsColor.png"), orbitRadius: 228e9, orbitPeriod: 59.4e6, planetRadius: 3390000, planetPeriod: 88800,
                             children: [DEIMOS, PHOBOS])
    
    static let GANYMEDE = Planet(name: "Ganymede", image: #imageLiteral(resourceName: "GanymedeColor.png"), orbitRadius: 2631277, orbitPeriod: 619200, planetRadius: 2634100, planetPeriod: 14568)
    static let IO = Planet(name: "Io", image: #imageLiteral(resourceName: "IoColor.png"), orbitRadius: 421648128, orbitPeriod: 152928, planetRadius: 1821294.6, planetPeriod: 152928)
    static let EUROPA = Planet(name: "Europa", image: #imageLiteral(resourceName: "EuropaColor.png"), orbitRadius: 670900000, orbitPeriod: 306806, planetRadius: 1560800, planetPeriod: 306806)
    static let CALLISTO = Planet(name: "Callisto", image: #imageLiteral(resourceName: "CallistoColor.png"), orbitRadius: 1882700000, orbitPeriod: 1441929, planetRadius: 2410000, planetPeriod: 1441929)
    static let JUPITER = Planet(name: "Jupiter", image: #imageLiteral(resourceName: "JupiterColor.png"), orbitRadius: 778e9, orbitPeriod: 370e6, planetRadius: 69.911e6, planetPeriod: 36000,
                                children: [GANYMEDE, IO, EUROPA, CALLISTO])
    
    static let MIMAS = Planet(name: "Mimas", image: #imageLiteral(resourceName: "MimasColor.png"), orbitRadius: 185539000, orbitPeriod: 81388, planetRadius: 198200, planetPeriod: 81388)
    static let ENCELADUS = Planet(name: "Enceladus", image: #imageLiteral(resourceName: "EnceladusColor.png"), orbitRadius: 237948000, orbitPeriod: 118368, planetRadius: 252100, planetPeriod: 118368)
    static let TETHYS = Planet(name: "Tethys", image: #imageLiteral(resourceName: "TethysColor.png"), orbitRadius: 294619000, orbitPeriod: 163036, planetRadius: 531100, planetPeriod: 163036)
    static let DIONE = Planet(name: "Dione", image: #imageLiteral(resourceName: "DioneColor.png"), orbitRadius: 377396000, orbitPeriod: 236390, planetRadius: 561400, planetPeriod: 236390)
    static let RHEA = Planet(name: "Rhea", image: #imageLiteral(resourceName: "RheaColor.png"), orbitRadius: 527108000, orbitPeriod: 390355, planetRadius: 763800, planetPeriod: 390355)
    static let TITAN = Planet(name: "Titan", image: #imageLiteral(resourceName: "TitanColor.png"), orbitRadius: 1221870000, orbitPeriod: 1377648, planetRadius: 2575500, planetPeriod: 1377648)
    static let SATURN = Planet(name: "Saturn", image: #imageLiteral(resourceName: "SaturnColor.png"), orbitRadius: 1.433e12, orbitPeriod: 930e6, planetRadius: 58.232e6, planetPeriod: 36840,
                               children: [MIMAS, ENCELADUS, TETHYS, DIONE, RHEA, TITAN])
    
    static let URANUS = Planet(name: "Uranus", image: #imageLiteral(resourceName: "UranusColor.png"), orbitRadius: 2.87e12, orbitPeriod: 2.7e9, planetRadius: 25.362e6, planetPeriod: 62040)
    static let NEPTUNE = Planet(name: "Neptune", image: #imageLiteral(resourceName: "NeptuneColor.png"), orbitRadius: 4.5029e12, orbitPeriod: 5.2e9, planetRadius: 24.622e6, planetPeriod: 57996)
    static let PLUTO = Planet(name: "Pluto", image: #imageLiteral(resourceName: "PlutoColor.png"), orbitRadius: 8.13064e12, orbitPeriod: 7820908000, planetRadius: 1.187e6, planetPeriod: 552096)
    
    static let SUN = Planet(name: "Sol", image: #imageLiteral(resourceName: "sun.jpg"), orbitRadius: 0, orbitPeriod: 0, planetRadius: /*695.7e6*/ 295.7e6, planetPeriod: 2.074e+6,
                            children: [MERCURY, VENUS, EARTH, MARS, JUPITER, SATURN, URANUS, NEPTUNE, PLUTO])
    
    public static let SOLAR_SYSTEM_SIZE: Double = EARTH.orbitRadius
    public static let PLANET_MAX_RADIUS: Double = JUPITER.planetRadius
    public static let ORBIT_TIME: Double = EARTH.orbitPeriod
    public static let ROTATION_TIME: Double = EARTH.planetPeriod
    
    private(set) var name: String
    private(set) var orbitRadius: Double // Average distance from sun in meters
    private(set) var orbitPeriod: Double // Average orbit time in seconds
    private(set) var planetRadius: Double // Average planet radius in meters
    private(set) var planetPeriod: Double // Rotation on planet in seconds (a day)
    private(set) var image: UIImage?
    private(set) var children: [Planet] // Planets orbiting this body
    
    init(name: String, image: UIImage?, orbitRadius: Double, orbitPeriod: Double, planetRadius: Double, planetPeriod: Double) {
        self.name = name
        self.image = image
        self.orbitPeriod = orbitPeriod
        self.orbitRadius = orbitRadius
        self.planetPeriod = planetPeriod
        self.planetRadius = planetRadius
        self.children = []
    }
    
    init(name: String, image: UIImage?, orbitRadius: Double, orbitPeriod: Double, planetRadius: Double, planetPeriod: Double, children: [Planet]) {
        self.name = name
        self.image = image
        self.orbitPeriod = orbitPeriod
        self.orbitRadius = orbitRadius
        self.planetPeriod = planetPeriod
        self.planetRadius = planetRadius
        self.children = children
    }
    
    public func scaledOrbit(solarSystemSize: Float) -> Double {
        return (orbitRadius / Planet.SOLAR_SYSTEM_SIZE) * Double(solarSystemSize)
    }
    
    public func scaledRadius(planetSize: Float) -> Float {
        return Float((planetRadius / Planet.PLANET_MAX_RADIUS) * Double(planetSize))
    }
    
    /// Scale orbital period so that 1 Earth years orbit happens in timeScale
    public func scaledOrbitPeriod(timeScale: Float) -> Double {
        return (orbitPeriod / Planet.ORBIT_TIME) * Double(timeScale)
    }
    
    public func scaledRotationPeriod(timeScale: Float) -> Double {
        return (planetPeriod / Planet.ROTATION_TIME) * Double(timeScale)
    }
}
