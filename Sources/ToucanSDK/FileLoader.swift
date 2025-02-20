////
////  File.swift
////  toucan
////
////  Created by Viasz-Kádi Ferenc on 2024. 10. 10..
////
//
//import Foundation
//import FileManagerKit
//
///// A structure for loading files from the filesystem.
//public struct FileLoader {
//
//    /// An enumeration representing possible errors that can occur while loading files.
//    public enum Error: Swift.Error {
//        /// Indicates that a file is missing at the specified URL.
//        case missing(URL)
//        /// Represents an error that occurred during file operations, with the associated error and URL.
//        case file(Swift.Error, URL)
//    }
//
//    /// A static instance of `FileLoader` configured to load YAML files.
//    static var yaml: FileLoader {
//        .init(extensions: ["yml", "yaml"])
//    }
//
//    /// The file manager used for accessing the filesystem.
//    let fileManager: FileManager = .default
//    /// An array of file extensions to search for when loading files.
//    let extensions: [String]
//
//    /// Loads the contents of files at the specified URL.
//    /// - Parameter url: The base URL to look for files.
//    /// - Returns: An array of file contents as strings.
//    /// - Throws: An error of type `FileLoader.Error` if the files cannot be found or read.
//    func loadContents(at url: URL) throws -> [String] {
//        let urls = extensions.map {
//            url.appendingPathExtension($0)
//        }
//        let existingUrls = urls.filter {
//            fileManager.fileExists(at: $0)
//        }
//
//        if existingUrls.isEmpty {
//            throw Error.missing(urls.first ?? url)
//        }
//
//        do {
//            return try existingUrls.map {
//                try String(contentsOf: $0, encoding: .utf8)
//            }
//        }
//        catch {
//            throw Error.file(error, url)
//        }
//    }
//
//    /// Finds and loads the contents of files in a specified directory.
//    /// - Parameter url: The directory URL to search for files.
//    /// - Returns: An array of file contents as strings.
//    /// - Throws: An error of type `FileLoader.Error` if the files cannot be read.
//    func findContents(at url: URL) throws -> [String] {
//        let urls = fileManager.listDirectory(at: url)
//            .filter {
//                extensions.contains(where: $0.hasSuffix)
//            }
//            .map {
//                url.appendingPathComponent($0)
//            }
//
//        do {
//            return try urls.map {
//                try String(contentsOf: $0, encoding: .utf8)
//            }
//        }
//        catch {
//            throw Error.file(error, url)
//        }
//    }
//}
