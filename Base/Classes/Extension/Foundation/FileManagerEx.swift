//
//  FileManagerEx.swift
//  Andmix
//
//  Created by remy on 2018/3/13.
//

import Foundation

private func path(_ domain: FileManager.SearchPathDomainMask) -> (FileManager.SearchPathDirectory) -> URL {
    return {
        return FileManager.default.urls(for: $0, in: domain)[0]
    }
}

extension FileManager {
    
    public static var userAppURL: URL {
        return path(.userDomainMask)(.applicationDirectory)
    }
    
    public static var userAppPath: String {
        return userAppURL.path
    }
    
    public static var userLibURL: URL {
        return path(.userDomainMask)(.libraryDirectory)
    }
    
    public static var userLibPath: String {
        return userLibURL.path
    }
    
    public static var userDocURL: URL {
        return path(.userDomainMask)(.documentDirectory)
    }
    
    public static var userDocPath: String {
        return userDocURL.path
    }
    
    public static var userCachesURL: URL {
        return path(.userDomainMask)(.cachesDirectory)
    }
    
    public static var userCachesPath: String {
        return userCachesURL.path
    }
    
    public static var userHomeURL: URL {
        return URL(fileURLWithPath: NSHomeDirectory(), isDirectory: true)
    }
    
    public static var userHomePath: String {
        return NSHomeDirectory()
    }
    
    public static var userTempURL: URL {
        return FileManager.default.temporaryDirectory
    }
    
    public static var userTempPath: String {
        return FileManager.default.temporaryDirectory.path
    }
}

extension FileManager {
    
    public static var ubiquityURL: URL? {
        guard let url = FileManager.default.url(forUbiquityContainerIdentifier: nil) else { return nil }
        return url
    }
}
