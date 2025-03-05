//
//  DataModelType.swift
//  Base
//
//  Created by remy on 2018/4/29.
//

import SwiftyJSON

//public protocol DataModelable {
//    
//    static func toModel(_ jsonData: JSON) -> Self?
//    // Self不能用在非参数类型,非返回值类型的位置
//    // https://stackoverflow.com/questions/40270118/protocol-requirement-cannot-be-satisfied-by-a-non-final-class-because-it-uses-s
////    static func toModels(_ jsonData: JSON) -> [Self]
//}
//
//// Self在类中只能用作方法的返回值类型,因此通过协议约束使用
//public extension DataModelable where Self: DataModelType {
//    
//    static func toModel(_ jsonData: JSON) -> Self? {
//        return ModelCreater<Self>.toModel(jsonData)
//    }
//    
//    static func toModels(_ jsonData: JSON) -> [Self] {
//        return ModelCreater<Self>.toModels(jsonData)
//    }
//}
//
//open class DataModelType: DataModelable {
//    
//    required public init() {}
//    
//    open func dataToProperty(json: JSON) {}
//}
//
//private class ModelCreater<T: DataModelType> {
//    
//    static func toModel(_ jsonData: JSON) -> T? {
//        if jsonData.type == .dictionary {
//            let model = T.init()
//            model.dataToProperty(json: jsonData)
//            return model
//        }
//        return nil
//    }
//    
//    static func toModels(_ jsonData: JSON) -> [T] {
//        if let arr = jsonData.array {
//            var modelArr: [T] = []
//            arr.forEach {
//                if let model = self.toModel($0) {
//                    modelArr.append(model)
//                }
//            }
//            return modelArr
//        }
//        return []
//    }
//}

public protocol DataModelable {
    init(json: JSON?)
}

public extension DataModelable {
    init() {
        self.init(json: nil)
    }
    
    static func toModel(_ jsonData: JSON) -> Self? {
        guard jsonData.type != .null else { return nil }
        return Self.init(json: jsonData)
    }
    
    static func toModels(_ jsonData: JSON) -> [Self] {
        guard let arr = jsonData.array else { return [] }
        return toModels(arr)
    }
    
    static func toModels(_ jsonData: [JSON]) -> [Self] {
        var models: [Self] = []
        jsonData.forEach {
            guard let model = self.toModel($0) else { return }
            models.append(model)
        }
        return models
    }
}
