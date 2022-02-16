//
//  FileManager+Ex.swift
//  WPCommand
//
//  Created by WenPing on 2022/2/10.
//

import UIKit

public extension WPSpace where Base == FileManager{

 
    
}

/*
 enum YPDirectories {
     case documents
     case library
     case libraryCaches
     case temp
 }

 // 文件管理
 class YPFileManager: NSObject {
     
     static let shared = YPFileManager()
     
     //四种路径
     func documentsDirectoryURL() -> URL {
         return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
     }
     
     func libraryDirectoryURL() -> URL {
         return FileManager.default.urls(for: FileManager.SearchPathDirectory.libraryDirectory, in: .userDomainMask).first!
     }
     
     func tempDirectoryURL() -> URL {
         return FileManager.default.temporaryDirectory
     }
     
     func librayCachesURL() -> URL {
         return FileManager.default.urls(for: FileManager.SearchPathDirectory.cachesDirectory, in: .userDomainMask).first!
     }
     
     func setupFilePath(directory: YPDirectories, name: String) -> URL {
         return getURL(for: directory).appendingPathComponent(name)
     }
     
     func getURL(for directory: YPDirectories) -> URL {
         switch directory {
         case .documents:
             return documentsDirectoryURL()
         case .libraryCaches:
             return librayCachesURL()
         case .library:
             return libraryDirectoryURL()
         case .temp:
             return tempDirectoryURL()
         }
     }
     
     /// 创建文件夹
     /// - Parameters:
     ///   - basePath: 文件夹所在主目录
     ///   - folderName: 文件夹名字或路径 -- name or folder1/folder2/name
     ///   - createIntermediates: 如果没有对应文件，是否需要创建
     ///   - attributes: attributes
     func createFolder(basePath: YPDirectories, folderName:String, createIntermediates: Bool = true, attributes: [FileAttributeKey : Any]? = nil) -> Bool {
         let filePath = setupFilePath(directory: basePath, name: folderName)
         do {
             try FileManager.default.createDirectory(atPath:filePath.path, withIntermediateDirectories: createIntermediates, attributes: attributes)
             return true
         } catch {
             return false
         }
     }
     
     /// 写
     /// - Parameters:
     ///   - content: 写入内容
     ///   - filePath: 文件路径
     ///   - options: options
     func writeFile(content: Data, filePath: URL, options: Data.WritingOptions = []) -> Bool {
         do {
             try content.write(to: filePath, options: options)
             return true
         } catch {
             return false
         }
     }
     
     /// 读
     /// - Parameter filePath: 文件路径
     func readFile(filePath: URL) -> Data? {
         let fileContents = FileManager.default.contents(atPath: filePath.path)
         if fileContents?.isEmpty == false {
             return fileContents
         } else {
             return nil
         }
     }
     
     /// 删
     /// - Parameter filePath: 文件路径
     func deleteFile(filePath: URL) -> Bool {
         do {
             try FileManager.default.removeItem(at: filePath)
             return true
         } catch {
             return false
         }
     }
     
     /// 移动
     /// - Parameters:
     ///   - formFileName: 文件/或路径 -- name or folder1/folder2/name
     ///   - fromDirectory: 来源
     ///   - toFileName: 文件/或路径 -- name or folder1/folder2/name
     ///   - toDirectory: 目标
     func moveFile(formFileName: String, fromDirectory: YPDirectories, toFileName: String, toDirectory: YPDirectories) -> Bool {
         let originURL = setupFilePath(directory: fromDirectory, name: formFileName)
         let destinationURL = setupFilePath(directory: toDirectory, name: toFileName)
         do {
             try FileManager.default.moveItem(at: originURL, to: destinationURL)
             return true
         } catch {
             return false
         }
     }
     
     /// 拷贝
     /// - Parameters:
     ///   - fileName: 文件/或路径 -- name or folder1/folder2/name
     ///   - fromDirectory: 来源
     ///   - toDirectory: 目标
     func copyFile(fileName: String, fromDirectory: YPDirectories, toDirectory: YPDirectories) throws {
         let originURL = setupFilePath(directory: fromDirectory, name: fileName)
         let destinationURL = setupFilePath(directory: toDirectory, name: fileName)
         return try FileManager.default.copyItem(at: originURL, to: destinationURL)
     }
     
     /// 是否存在
     /// - Parameter filePath: 路径
     func exists(filePath: String) -> Bool {
         if FileManager.default.fileExists(atPath: filePath) {
             return true
         } else {
             return false
         }
     }
     
     /// 是否可写
     /// - Parameter fileURL: 完整路径
     func isWritable(fileURL: String) -> Bool {
         if FileManager.default.isWritableFile(atPath: fileURL) {
             return true
         } else {
             return false
         }
     }
     
     /// 是否可读
     /// - Parameter filePath: 完整路径
     func isReadable(filePath: String) -> Bool {
         if FileManager.default.isReadableFile(atPath: filePath) {
             return true
         } else {
             return false
         }
     }
     
 }

 */
