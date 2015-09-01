//
//  SwiftBus.swift
//  SwiftBus
//
//  Created by Adam on 2015-08-29.
//  Copyright (c) 2015 com.adam. All rights reserved.
//

import Foundation

class SwiftBus {
    static let sharedController = SwiftBus()
    
    private var _transitAgencies:[String : TransitAgency] = [:]
    
    private init() {
        println("SwiftBus initialized")
    }
    
    /**
    Gets the list of agencies from the nextbus API or what is already in memory if getAgencies has been called before
    
    agencies.keys.array will return a list of the keys used
    agencies.values.array will return a list of TransitAgencies
    
    :param: closure Code that is called after the dictionary of agencies has loaded
    */
    func transitAgencies(closure: ((agencies:[String : TransitAgency]) -> Void)?) {
        
        if _transitAgencies.count > 0 {
            
            //Transit agency data is in memory, provide that
            if let innerClosure = closure as ([String : TransitAgency] -> Void)! {
                innerClosure(_transitAgencies)
            }
            
        } else {
            
            //We need to load the transit agency data
            let connectionHandler = ConnectionHandler()
            connectionHandler.requestAllAgencies({(agencies:[String : TransitAgency]) -> Void in
                //Insert this closure around the inner one because the agencies need to be saved
                self._transitAgencies = agencies
                
                if let innerClosure = closure as ([String : TransitAgency] -> Void)! {
                    innerClosure(agencies)
                }
            })
            
        }
    }
    
    /**
    The dictionary of transit agencies is saved in memory, but if it needs to be refreshed, this method can be called
    
    :param: closure Code that is called after the TransitAgency dictionary has been refreshed
    */
    func refreshTransitAgencies(closure: ((agencies:[String : TransitAgency]) -> Void)?) {
        //We need to load the transit agency data
        let connectionHandler = ConnectionHandler()
        connectionHandler.requestAllAgencies({(agencies:[String : TransitAgency]) -> Void in
            //Insert this closure around the inner one because the agencies need to be saved
            self._transitAgencies = agencies
            
            if let innerClosure = closure as ([String : TransitAgency] -> Void)! {
                innerClosure(agencies)
            }
        })
        
    }
    
    /**
    Gets the TransitRoutes for a particular agency. If the list of agencies hasn't been downloaded, this functions gets them first
    
    :param: agencyTag the transit agency that this will download the routes for
    :param: closure   Code that is called after all the data has loaded
    */
    func routesForAgency(agencyTag: String, closure: ((agencies:[String : TransitRoute]) -> Void)?) {
        
        //Getting all the agencies
        transitAgencies({(innerAgencies:[String : TransitAgency]) -> Void in
            
            if innerAgencies[agencyTag] != nil {
                
                //The agency exists & we need to load the transit agency data
                let connectionHandler = ConnectionHandler()
                connectionHandler.requestAllRouteData(agencyTag, closure: {(agencyRoutes:[String : TransitRoute]) -> Void in

                    //Saving the routes for the agency
                    self._transitAgencies[agencyTag]?.agencyRoutes = agencyRoutes
                    
                    //Return the transitRoutes for the agency
                    if let innerClosure = closure as ([String : TransitRoute] -> Void)! {
                        innerClosure(agencyRoutes)
                    }
                })
            } else {
                
                //The agency doesn't exist, return an empty dictionary
                if let innerClosure = closure as ([String : TransitRoute] -> Void)! {
                    innerClosure([String : TransitRoute]())
                }
            }
        })
        
    }
    
    /**
    Gets the TransitStop object that contains a list of TransitStops in each direction and the location of each of those stops
    
    :param: routeTag  the route that is being looked up
    :param: agencyTag the agency for which the route is being looked up
    :param: closure   the code that gets called after the data is loaded
    */
    func routeConfiguration(routeTag: String, forAgency agencyTag: String, closure:((route: TransitRoute?) -> Void)?) {
        
        //Getting all the routes for the agency
        routesForAgency(agencyTag, closure: {(transitRoutes:[String : TransitRoute]) -> Void in
            if transitRoutes[routeTag] != nil {
                
                //If the route exists, get the route configuration
                let connectionHandler = ConnectionHandler()
                connectionHandler.requestRouteConfiguration(routeTag, fromAgency: agencyTag, closure: {(route:TransitRoute?) -> Void in
                    
                    //If there were no problems getting the route
                    if let transitRoute = route as TransitRoute! {
                        self._transitAgencies[agencyTag]?.agencyRoutes[routeTag] = route
                        
                        //Call the closure
                        if let innerClosure = closure as (TransitRoute? -> Void)! {
                            innerClosure(transitRoute)
                        }
                        
                    }
                })
                
            } else {
                //If the route doesn't exist, return nil
                if let innerClosure = closure as (TransitRoute? -> Void)! {
                    innerClosure(nil)
                }
            }
        })
    }
    
    /*
        List of calls that are pulled live each time
        -Stop predictions
        -Vehicle locations
        
        List of calls that are not pulled live each time
        -Agency list
        -List of lines in an agency
        -List of stops per line
    */
}