//
//  MuniRoute.swift
//  Pods
//
//  Created by Adam Boyd on 2015-12-02.
//
//

import Foundation

private let tlRouteIDEncoderString = "tlRouteIDEncoder"

public class MuniRoute: TransitRoute {
    
    public var tlRouteID: String = ""
    
    //MARK: - NSCoding
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        //Custom MuniRoute properties
        tlRouteID = aDecoder.decodeObjectForKey(tlRouteIDEncoderString) as! String
    }
    
    public override func encodeWithCoder(aCoder: NSCoder) {
        super.encodeWithCoder(aCoder)
        
        //Custom MuniRoute properties
        aCoder.encodeObject(tlRouteID, forKey: tlRouteIDEncoderString)
    }
}