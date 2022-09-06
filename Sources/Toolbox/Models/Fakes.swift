//
//  Fakes.swift
//  
//
//  Created  on 04.01.2020.
//  Copyright . All rights reserved.
//

import Foundation

public protocol Fakeble {
    static func fake() -> Self
}

extension String: Fakeble {
    public static func fake() -> String {
        return fake(components: 2)
    }
    
    public static func fake(components: Int) -> String {
        
        let strings = "Sed utro perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae abes illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt Neque porro quisquam est qui dolorem ipsum quia dolor sit amet consectetur adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur Quis autem vel eum iure reprehenderit qui indf eaeq voluptate velit esse quam nihil molestiae consequatur vel illum qui dolorem eum fugiat quo voluptas nulla pariatur"
            .replacingOccurrences(of: ",", with: "")
            .components(separatedBy: " ")
        
        return (0..<components).map{ _ in strings.randomElement()! }.joined(separator: " ")
    }
    
    public static func fakePersonImageURL() -> String {
        [
            "https://randomuser.me/api/portraits/women/67.jpg",
            "https://randomuser.me/api/portraits/women/81.jpg",
            "https://randomuser.me/api/portraits/women/1.jpg",
            "https://randomuser.me/api/portraits/women/92.jpg",
            "https://randomuser.me/api/portraits/women/8.jpg",
            "https://randomuser.me/api/portraits/men/33.jpg",
            "https://randomuser.me/api/portraits/men/74.jpg",
            "https://randomuser.me/api/portraits/men/55.jpg",
            "https://randomuser.me/api/portraits/men/80.jpg",
            "https://randomuser.me/api/portraits/men/43.jpg",
        ].randomElement()!
    }
    
    public static func fakeBoatImageURL() -> String {
        [
            "https://d18mr9iuob0gar.cloudfront.net/media/__sized__/cities/Photo_Feb_23_3_48_57_AM-thumbnail-750x500-85.jpg",
            "https://d18mr9iuob0gar.cloudfront.net/media/__sized__/cities/rental-Sail-boat-Hinckley-35feet-New_York-NY_top_destination-thumbnail-750x500-85.jpg",
            "https://d18mr9iuob0gar.cloudfront.net/media/__sized__/cities/catamaran-01-thumbnail-750x500-85.jpg",
            "https://d18mr9iuob0gar.cloudfront.net/media/boats/2021/06/rental-Motor-boat-b242_X-24feet-bMiami-bFL_LWh7wV9.jpg",
            "https://d18mr9iuob0gar.cloudfront.net/media/boats/2021/05/rental-Motor-boat-bSEARAY-40feet-bMiami-bFL_b89A45i.jpg",
            "https://d18mr9iuob0gar.cloudfront.net/media/boats/2018/04/rental-Motor-boat-Chaparral-30feet-Miami-FL_EKfMWYT.jpg",
            "https://d18mr9iuob0gar.cloudfront.net/media/boats/2021/04/rental-Motor-boat-bYAMAHA-21feet_rxyK82r.jpg",
            "https://d18mr9iuob0gar.cloudfront.net/media/boats/2018/01/rental-Sail-boat-Island_Packet_Yachts-38feet-Miami-FL_My5UNFD.jpg"
        ].randomElement()!
    }
    
    public static func fakeBeachImageURL() -> String {
        [
            "https://d18mr9iuob0gar.cloudfront.net/media/__sized__/cities/mb_ok-thumbnail-750x500-85.jpg",
            "https://d18mr9iuob0gar.cloudfront.net/media/__sized__/cities/yacht-charter-boat-rental-usvi-st-thomas_SA1pec9-thumbnail-750x500-85.jpg",
            "https://d18mr9iuob0gar.cloudfront.net/media/__sized__/cities/boat-rentals-yacht-charters-sailo-san-diego-thumbnail-750x500-85.jpg",
            "https://d18mr9iuob0gar.cloudfront.net/media/cityguide/city/things-to-do-by-boat-cabo-san-lucas-mexico-el-archo-sailo-yacht-rental1.jpg",
            "https://d18mr9iuob0gar.cloudfront.net/media/__sized__/cityguide/activity/things-to-do-by-boat-cabo-san-lucas-mexico-snorkeling-playa-chileno-s_0stdHAW-thumbnail-750x500-85.jpg",
        ].randomElement()!
    }
    
    public static func fakeID() -> String {
        return UUID().uuidString
    }
    
    public static func fakeName() -> String {
        ["Jack Smith", "Jane Black", "Dave Brown", "Paul White", "Lisa Simpson", "Harry Potter"].randomElement()!
    }
    
    public static func fakeLocationName() -> String {
        ["Miami", "The Bahamas", "California", "New York", "US Virgin Islands", "Athens", "Dubrovnik"].randomElement()!
    }
    
    public static func fakeLocationDescription() -> String {
        ["Best power yacht rentals in town for the best experiences on the west coast",
         "Weekly and multi-day rentals from Nassau",
         "Top rated yacht charters for sightseeing and whale watching",
         "Private Manhattan sunset cruises on Sailo verified boats"].randomElement()!
    }
    
    public static func fakeBlogURL() -> String {
        ["https://www.sailo.com/boating-destinations/sailing-in-italy/survival-guide-transportation/",
         "https://www.sailo.com/boating-destinations/sailing-in-italy/survival-guide-weather/",
         "https://www.sailo.com/boating-destinations/sailing-in-italy/survival-guide-italy-travel-essentials/",
         "https://www.sailo.com/discover-boating/destination-guides/Sicily-Italy-attractions-by-boat/"].randomElement()!
    }
    
    public static func fakeVideoURL() -> String {
        return [ "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
          "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
          "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
          "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
          "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4"
        ].randomElement()!
    }
    
    public static func fakePhoneNumber() -> String {
        return "+1631" + String(Int.fake(bound: 8_999_999) + 1_000_000)
    }
    
}

extension Int: Fakeble {
    
    public static func fake() -> Int {
        return fake(bound: 100)
    }
    
    public static func fake(bound: Int) -> Int {
        return Int.random(in: 0 ..< bound)
    }
    
}

extension Double: Fakeble {
    
    public static func fake() -> Double {
        return fake(min: 0, max: 1)
    }
    
    public static func fake(min: Double, max: Double) -> Double {
        let normilizer = Double(Int.fake(bound: 100000)) / Double(100000)
        return (max - min) * normilizer + min
    }
    
}

extension CGFloat: Fakeble {
    
    public static func fake() -> CGFloat {
        return fake(min: 0, max: 1)
    }
    
    public static func fake(min: CGFloat, max: CGFloat) -> CGFloat {
        let normilizer = CGFloat(Int.fake(bound: 100000)) / CGFloat(100000)
        return (max - min) * normilizer + min
    }
}

extension Date: Fakeble {
    
    public static func fake() -> Date {
        
        let delta = 24 * 3600 * 100
        let isFuture: Int = Bool.fake() ? 1 : -1
        
        let x = Int.fake(bound: delta) * isFuture
        
        return Date().addingTimeInterval(TimeInterval(x))
        
    }
}

extension Bool: Fakeble {
    public static func fake() -> Bool {
        let x = arc4random_uniform(2)
        return x == 0
    }
}

extension Array: Fakeble where Element: Fakeble {
    
    public static func fake(components: Int) -> Array<Element> {
        return .fake(min: 0, components: components, element: Element.fake() )
    }
    
    public static func fake( min: Int, components: Int, element: @autoclosure () -> Element ) -> Array<Element> {
        var res: [Element] = []
        for _ in 0..<(components + min) {
            res.append(element())
        }
        return res
    }
    
    public static func fake() -> Array<Element> {
        return fake(min: 2, components: .fake(bound: 5),
                    element: Element.fake())
    }
    
}

public extension CaseIterable {
    static func fake() -> Self {
        return allCases.randomElement()!
    }
}

import MapKit
extension MKCoordinateRegion: Fakeble {
    
    public static func fake() -> MKCoordinateRegion {
        .init(center: .init(latitude: .fake(min: 20, max: 30),
                                          longitude: .fake(min: -20, max: -30)),
                            latitudinalMeters: .fake(min: 0, max: 1_000_000),
                            longitudinalMeters: .fake(min: 0, max: 1_000_000))
    }
    
}

import RxSwift
public extension Fakeble {
    
    static var requestStub: Single<Self> {
        
        return Single.just(.fake()).delay(.milliseconds(500),
                                          scheduler: SerialDispatchQueueScheduler(qos: .default))
        
    }

    static var emptyRequestStub: Single<Void> {
        return Single.just( () ).delay(.milliseconds(500),
                                       scheduler: SerialDispatchQueueScheduler(qos: .default))
            .observe(on: MainScheduler.instance)
    }
    
}

extension Set: Fakeble where Element: Fakeble {
    public static func fake() -> Set<Element> {
        return [ Element.fake(), Element.fake(), Element.fake() ]
    }
}

extension Identifier: Fakeble where ID == String {
    public static func fake() -> Self {
        .init(rawValue: .fakeID())
    }
}

extension Identifier where ID == Int {
    public static func fake() -> Self {
        .init(rawValue: .fake(bound: 100_000))
    }
}
