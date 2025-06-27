//
//  convertJsonDocument.swift
//  convertJson
//
//  Created by 차원준 on 6/27/25.
//

import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static var exampleText: UTType {
        UTType(importedAs: "com.example.plain-text")
    }
}

struct convertJsonDocument: FileDocument {
    var text: String
    var originalJsonData: Any?
    var convertedJsonData: [[String: Any]]?

    init(text: String = "Hello, world!") {
        self.text = text
        self.originalJsonData = nil
        self.convertedJsonData = nil
    }

    static var readableContentTypes: [UTType] { [.json, .exampleText] }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let string = String(data: data, encoding: .utf8)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        text = string
        
        // JSON 파싱 시도
        if let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) {
            originalJsonData = jsonData
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = text.data(using: .utf8)!
        return .init(regularFileWithContents: data)
    }
    
    // Create ML용 데이터 변환 함수
    mutating func convertToCreateMLFormat() {
        guard let jsonData = originalJsonData else { return }
        
        // 데이터를 배열로 감싼 딕셔너리 리스트로 변환
        var convertedArray: [[String: Any]] = []
        
        if let dictionary = jsonData as? [String: Any] {
            // 단일 딕셔너리인 경우
            convertedArray.append(["data": dictionary])
        } else if let array = jsonData as? [Any] {
            // 이미 배열인 경우, 각 요소를 딕셔너리로 감싸기
            for item in array {
                convertedArray.append(["data": item])
            }
        } else {
            // 기타 타입인 경우
            convertedArray.append(["data": jsonData])
        }
        
        convertedJsonData = convertedArray
        
        // 변환된 데이터를 JSON 문자열로 변환하여 text에 저장
        if let jsonData = try? JSONSerialization.data(withJSONObject: convertedArray, options: [.prettyPrinted]),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            text = jsonString
        }
    }
    
    // JSON 내보내기 함수
    func exportConvertedJson() -> Data? {
        guard let convertedData = convertedJsonData else { return nil }
        return try? JSONSerialization.data(withJSONObject: convertedData, options: [.prettyPrinted])
    }
}
