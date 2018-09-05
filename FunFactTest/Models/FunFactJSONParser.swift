//
//  FunFactJSONParser.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 7/11/18.
//  Copyright © 2018 Rushi Dolas. All rights reserved.
//

import Foundation
import MapKit

class FunFactJSONParser {
    
    struct ListOfLandmarks: Decodable {
        var listOfLandmarks: [Landmark]
        
        enum CodingKeys: String, CodingKey {
            case listOfLandmarks = "List_Of_Landmarks"
        }
    }
    struct Landmark: Decodable {
        let landmarkID: String
        let landmarkName: String
        let landmarkAddress: String
        let landmarkCity: String
        let landmarkState: String
        let landmarkZip: String
        let landmarkCountry: String
        let landmarkType: String
        let latitude: String
        let longitude: String
        let listOfFunFacts: [FunFact]
        
        enum CodingKeys: String, CodingKey {
            case landmarkID = "Landmark_ID"
            case landmarkName = "Landmark_Name"
            case landmarkAddress = "Landmark_Address"
            case landmarkCity = "Landmark_City"
            case landmarkState = "Landmark_State"
            case landmarkZip = "Landmark_Zip"
            case landmarkCountry = "Landmark_Country"
            case landmarkType = "Landmark_Type"
            case latitude = "Latitude"
            case longitude = "Longitude"
            case listOfFunFacts = "List_Of_Fun_Facts"
            
        }
    }
    struct FunFact: Decodable {
        let funFactID: String
        let funFactDescription: String
        let likes: String
        let dislikes: String
        let verificationFlag: String
        let imageName: String
        let disputeFlag: String
        let submittedBy: String
        let dateSubmitted: String
        let source: String
        
        enum CodingKeys: String, CodingKey {
            case funFactID = "Fun_fact_ID"
            case funFactDescription = "Fun_Fact_Description"
            case likes = "Likes"
            case dislikes = "Dislikes"
            case verificationFlag = "Verification_Flag"
            case imageName = "Image_Name"
            case disputeFlag = "Dispute_Flag"
            case submittedBy = "Submitted_By"
            case dateSubmitted = "Date_Submitted"
            case source = "Source"
        }
    }
    
    func getData()  {
        do {
            let path = Bundle.main.path(forResource: "ListOfFunFacts", ofType: "json")
            let data = try Data(contentsOf: URL(fileURLWithPath: path!), options: .mappedIfSafe)
            let myStructArray = try JSONDecoder().decode(ListOfLandmarks.self, from: data)
            print(myStructArray.listOfLandmarks[1].listOfFunFacts[0].funFactDescription)
        }
        catch {
            print (error)
        }
    }
    
    func getAddresses() -> [String]{
        var addressList = [String]()
        do {
            let path = Bundle.main.path(forResource: "ListOfFunFacts", ofType: "json")
            let data = try Data(contentsOf: URL(fileURLWithPath: path!), options: .mappedIfSafe)
            let listOfL = try JSONDecoder().decode(ListOfLandmarks.self, from: data)
            
            for landmark in listOfL.listOfLandmarks {
                addressList.append(landmark.landmarkAddress)
            }
        }
        catch {
            print (error)
        }
        return addressList
    }
    
    func createFunFactAnnotations() -> [FunFactAnnotation] {
        var funFactAnnotations = [FunFactAnnotation]()
        do {
            let path = Bundle.main.path(forResource: "ListOfFunFacts", ofType: "json")
            let data = try Data(contentsOf: URL(fileURLWithPath: path!), options: .mappedIfSafe)
            let listOfL = try JSONDecoder().decode(ListOfLandmarks.self, from: data)
            var annotation: FunFactAnnotation
            
            for landmark in listOfL.listOfLandmarks {
                let image = Utils.resizeImage(image: UIImage(named: landmark.listOfFunFacts[0].imageName)!, targetSize: CGSize(width: 70, height: 70))
                annotation = FunFactAnnotation(landmarkID: landmark.landmarkID,
                                               title: landmark.landmarkName,
                                               address: landmark.landmarkAddress,
                                               type: landmark.landmarkType,
                                               coordinate: CLLocationCoordinate2D(latitude: Double(landmark.latitude)!, longitude: Double(landmark.longitude)!))
                funFactAnnotations.append(annotation)
            }
        }
        catch {
            print (error)
        }
        return funFactAnnotations
        
    }
    
    func getLandmark (forID: String) -> Landmark {
        var landmark = Landmark(landmarkID: "", landmarkName: "", landmarkAddress: "", landmarkCity: "", landmarkState: "", landmarkZip: "", landmarkCountry: "", landmarkType: "", latitude: "", longitude: "", listOfFunFacts: [])
        do {
            let path = Bundle.main.path(forResource: "ListOfFunFacts", ofType: "json")
            let data = try Data(contentsOf: URL(fileURLWithPath: path!), options: .mappedIfSafe)
            let listOfL = try JSONDecoder().decode(ListOfLandmarks.self, from: data)
            
            for landm in listOfL.listOfLandmarks {
                if (landm.landmarkID == forID) {
                    landmark = landm
                }
            }
        }
        catch {
            print (error)
        }
        return landmark
    }
}
