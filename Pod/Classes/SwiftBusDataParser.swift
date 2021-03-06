//
//  SwiftBusParser.swift
//  Pods
//
//  Created by Adam on 2015-09-21.
//
//

import Foundation
import SWXMLHash

class SwiftBusDataParser: NSObject {
    
    /**
    Creating all the transit agencies from the xml, calls the allAgenciesCompletion when done
    
    - parameter xml:    xml gotten from calling NextBus's API
    - parameter completion:code that gets called when fetch of information is complete
    */
    func parseAllAgenciesData(_ xml: XMLIndexer, completion: (_ agencies: [String: TransitAgency]) -> Void) {
        let agenciesXML:[XMLIndexer] = xml["body"].children
        var transitAgencies:[String : TransitAgency] = [:]
        
        //Creating all the agencies
        for agencyXML:XMLIndexer in agenciesXML {
            
            //If all the proper elements exist
            if let agencyTag = agencyXML.element?.allAttributes["tag"]?.text, let agencyTitle = agencyXML.element?.allAttributes["title"]?.text, let agencyRegion = agencyXML.element?.allAttributes["regionTitle"]?.text {
                
                let newAgency:TransitAgency = TransitAgency(agencyTag: agencyTag, agencyTitle: agencyTitle, agencyRegion: agencyRegion)
                
                //Some agencies have a shortTitle
                if let agencyShortTitle = agencyXML.element?.allAttributes["shortTitle"]?.text {
                    newAgency.agencyShortTitle = agencyShortTitle
                }
    
                transitAgencies[agencyTag] = newAgency
            }
        }
        
        completion(transitAgencies)
        
    }
    
    /**
    Creating all the TransitRoutes from the xml, calls allRoutesForAgencyCompletion when done
    
    - parameter xml:    XML gotten from NextBus's API
    - parameter completion:code that gets called when fetch of information is complete
    */
    func parseAllRoutesData(_ xml: XMLIndexer, completion: (_ agencyRoutes: [String: TransitRoute]) -> Void) {
        var transitRoutes:[String : TransitRoute] = [:]
        
        //Going through all lines and saving them
        for child in xml["body"].children {
            
            if let routeTag = child.element?.allAttributes["tag"]?.text, let routeTitle = child.element?.allAttributes["title"]?.text {
                //If we can create all the routes
                let currentRoute:TransitRoute = TransitRoute(routeTag: routeTag, routeTitle: routeTitle)
                transitRoutes[routeTag] = currentRoute
            }
        }
        
        completion(transitRoutes)
        
    }
    
    /**
    Parsing the route configuration data
    
    - parameter xml:    XML gotten from NextBus's API
    - parameter completion:code that gets called when fetch of information is complete
    */
    func parseRouteConfiguration(_ xml: XMLIndexer, completion:(_ route: TransitRoute?) -> Void) {
        let currentRoute = TransitRoute()
        var stopDirectionDict: [String: [String]] = [:]
        var allStopsDictionary: [String: TransitStop] = [:]
        var allPathArrays: [[PathPoint]] = []
        
        var routeConfig: [String: XMLAttribute] = xml["body"]["route"].element?.allAttributes ?? [:]
        
        //Creating the route from the current information
        guard let routeTag = routeConfig["tag"]?.text, let routeTitle = routeConfig["title"]?.text, let latMin = routeConfig["latMin"]?.text, let latMax = routeConfig["latMax"]?.text, let lonMin = routeConfig["lonMin"]?.text, let lonMax = routeConfig["lonMax"]?.text, let routeColorHex = routeConfig["color"]?.text, let oppositeColorHex = routeConfig["oppositeColor"]?.text else {
            //Couldn't get the route information, return
            completion(currentRoute)
            return
        }
        
        currentRoute.routeTag = routeTag
        currentRoute.routeTitle = routeTitle
        currentRoute.latMin = (latMin as NSString).doubleValue
        currentRoute.latMax = (latMax as NSString).doubleValue
        currentRoute.lonMin = (lonMin as NSString).doubleValue
        currentRoute.lonMax = (lonMax as NSString).doubleValue
        currentRoute.routeColor = routeColorHex
        currentRoute.oppositeColor = oppositeColorHex
        currentRoute.representedRouteColor = SwiftBusColor(rgba: "#" + routeColorHex)
        currentRoute.representedOppositeColor = SwiftBusColor(rgba: "#" + oppositeColorHex)
        
        let stopDirections:XMLIndexer = xml["body"]["route"]["direction"]
        
        for stopDirection in stopDirections.all {
            //For each direction, eg. "Inbound to downtown", "Inbound to Caltrain", "Outbound to Ocean Beach"
            if let currentDirection:String = stopDirection.element?.allAttributes["title"]?.text, let directionTag:String = stopDirection.element?.allAttributes["tag"]?.text {
            
                stopDirectionDict[currentDirection] = []
                currentRoute.directionTagToName[directionTag] = currentDirection
                
                for child in stopDirection.children {
                    //For each stop per direction
                    
                    if let tag:String = child.element?.allAttributes["tag"]?.text {
                        stopDirectionDict[currentDirection]?.append(tag)
                    }
                    
                }
                
            }
            
        }
        
        //Now we need to go through all the named stops, and add the proper direction to them
        let stops = xml["body"]["route"]["stop"]
        
        //Going through the stops and creating TransitStop objects
        for stop in stops.all {
            if let routeTitle = xml["body"]["route"].element?.allAttributes["title"]?.text, let routeTag = xml["body"]["route"].element?.allAttributes["tag"]?.text, let stopTitle = stop.element?.allAttributes["title"]?.text, let stopTag = stop.element?.allAttributes["tag"]?.text, let stopLat = stop.element?.allAttributes["lat"]?.text, let stopLon = stop.element?.allAttributes["lon"]?.text {
                let stop = TransitStop(routeTitle: routeTitle, routeTag: routeTag, stopTitle: stopTitle, stopTag: stopTag)
                stop.lat = Double(stopLat) ?? 0
                stop.lon = Double(stopLon) ?? 0
                
                allStopsDictionary[stopTag] = stop
            }
        }
    
        //Going through all stops IN ORDER and add them to an array of transit stops
        for stopDirection in stopDirectionDict.keys {
            //For each direction
            
            currentRoute.stops[stopDirection] = []
            
            for stopTag in stopDirectionDict[stopDirection] ?? [] {
                //For each stop per direction
                
                if let transitStop = allStopsDictionary[stopTag] {
                    //Getting the stop from the dictionary of all stops and adding it to the correct direction for the current TransitRoute
                    transitStop.direction = stopDirection
                    currentRoute.stops[stopDirection]?.append(transitStop)
                }
               
            }
        }
        
        // parsing paths
        let paths = xml["body"]["route"]["path"]
        for path in paths.all {
            var points = [PathPoint]()
            for point in path.children {
                if let lat:String = point.element!.allAttributes["lat"]?.text, let lon:String = point.element!.allAttributes["lon"]?.text {
                    points.append(PathPoint(lat: (lat as NSString).doubleValue, lon: (lon as NSString).doubleValue))
                }
            }
            allPathArrays.append(points)
        }

        currentRoute.pathsOnRoute = allPathArrays
        
        completion(currentRoute)

    }
    
    /**
    Parsing the vehicle location data
    
    - parameter xml:    XML gotten from NextBus's API
    - parameter completion:code that gets called when fetch of information is complete
    */
    func parseVehicleLocations(_ xml: XMLIndexer, completion: (_ locations:[String : [TransitVehicle]]) -> Void) {
        let vehicles = xml["body"]
        var dictionaryOfVehicles:[String : [TransitVehicle]] = [:]
        
        for vehicle in vehicles.children {
            let attributes = vehicle.element?.allAttributes
            
            if let vehicleID = attributes?["id"]?.text, let directionTag = attributes?["dirTag"]?.text, let lat = attributes?["lat"]?.text, let lon = attributes?["lon"]?.text, let secondsSinceLastReport = attributes?["secsSinceReport"]?.text, let heading = attributes?["heading"]?.text {
                let speedKmH = attributes?["speedKmHr"]?.text ?? "0" // some agencies like TTC doesn't report speed

                //If all the proper attributes exist
                let newVehicle = TransitVehicle(vehicleID: vehicleID, directionTag: directionTag, lat: lat, lon: lon, secondsSinceReport: secondsSinceLastReport, heading: heading, speedKmH: speedKmH)
                
                //If there is a leading vehicle
                if let leadingVehicleId = attributes?["leadingVehicleId"]?.text {
                    newVehicle.leadingVehicleId = Int(leadingVehicleId)!
                }
            
                //Adding newVehicle to the dictionary if it hasn't been created
                if dictionaryOfVehicles[directionTag] == nil {
                    dictionaryOfVehicles[directionTag] = [newVehicle]
                } else {
                    dictionaryOfVehicles[directionTag]?.append(newVehicle)
                }
                
            }
        }
        
        completion(dictionaryOfVehicles)

    }
    
    func parseStationPredictions(_ xml: XMLIndexer, completion: (_ predictions: PredictionGroup) -> Void) {
        let predictions = xml["body"]
        var predictionDict:[String : [String : [TransitPrediction]]] = [:]
        
        //For each route that the user wants to get predictions for
        for route in predictions.children {
            if let routeTitle = route.element?.allAttributes["routeTag"]?.text {
                if let _ = predictionDict[routeTitle] {
                    let newPredictions = parsePredictions(route, useDirectionAsKey: false)
                    if let newStopTag = newPredictions.keys.first {
                        //There should only be one key because we are using the stop as a key and only parsing the predictions for one stop
                        predictionDict[routeTitle]?[newStopTag] = newPredictions[newStopTag]
                    }
                } else {
                    predictionDict[routeTitle] = parsePredictions(route, useDirectionAsKey: false)
                }
            }
        }
        
        completion(predictionDict)
        
    }
    
    /**
    Parsing the stop prediction data
    
    - parameter xml:    XML gotten from NextBus's API
    - parameter completion:code that gets called when fetch of information is complete
    */
    func parseStopPredictions(_ xml: XMLIndexer, completion:(_ predictions: [DirectionName: [TransitPrediction]], _ messages: [TransitMessage]) -> Void) {
        let predictions = xml["body"]["predictions"]
        var messageArray: [TransitMessage] = []
        
        let predictionDict: [String: [TransitPrediction]] = parsePredictions(predictions, useDirectionAsKey: true)
        
        let messages = predictions["message"]
        
        for message in messages.all {
            //Going through the messages and adding them
            if let messageTitle = message.element?.allAttributes["text"]?.text, let priority = message.element?.allAttributes["priority"]?.text {
                messageArray.append(TransitMessage(message: messageTitle, priority: TransitMessagePriority(priority)))
            }
        }
        
        completion(predictionDict, messageArray)
        
    }
    
    /// Parses the predictions for one in all directions at one stop
    ///
    /// - Parameters:
    ///   - predictionXML: xml to parse
    ///   - useDirectionAsKey: if true, uses the direction of the prediction as key instead of the stop
    /// - Returns: dict of predictions
    private func parsePredictions(_ predictionXML: XMLIndexer, useDirectionAsKey: Bool) -> [String: [TransitPrediction]] {
        var predictions:[String : [TransitPrediction]] = [:]
        
        guard let stopTag = predictionXML.element?.allAttributes["stopTag"]?.text else { return [:] }
        
        //Getting all the predictions
        for direction in predictionXML.children {
            
            //Making sure this is a valid element
            if let directionName = direction.element?.allAttributes["title"]?.text {
                
                let keyForPredictions = useDirectionAsKey ? directionName : stopTag
                if predictions[keyForPredictions] == nil {
                    predictions[keyForPredictions] = []
                }
                
                for prediction in direction.children {
                    //Getting each individual prediction in minutes
                    
                    if let predictionInMinutes = Int((prediction.element?.allAttributes["minutes"]?.text) ?? ""), let predictionInSeconds = Int((prediction.element?.allAttributes["seconds"]?.text) ?? ""), let vehicleTag = Int((prediction.element?.allAttributes["vehicle"]?.text) ?? "") {
                        //If all the elements exist
                        
                        let newPrediction = TransitPrediction(predictionInMinutes: predictionInMinutes, predictionInSeconds: predictionInSeconds, vehicleTag: vehicleTag)
                        
                        //Number of vehicles is optionally provided by the API
                        if let numberOfVechiles = prediction.element?.allAttributes["vehiclesInConsist"]?.text {
                            newPrediction.numberOfVehicles = Int(numberOfVechiles)!
                        }
                        
                        newPrediction.directionName = directionName
                        
                        predictions[keyForPredictions]?.append(newPrediction)
                    }
                }
            }
        }
        
        return predictions
    }
}
