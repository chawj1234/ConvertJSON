//
//  convertJsonDocument.swift
//  convertJson
//
//  Created by 차원준 on 6/27/25.
//

import SwiftUI
import UniformTypeIdentifiers

// Create ML 변환 타입 열거형
enum CreateMLConversionType: String, CaseIterable {
    case textClassification = "텍스트 분류"
    case imageClassification = "이미지 분류"
    case objectDetection = "객체 감지"
    case tabularData = "테이블 데이터"
    
    var description: String {
        switch self {
        case .textClassification:
            return "텍스트 분류용 - 배열 안의 딕셔너리 리스트"
        case .imageClassification:
            return "이미지 분류용 - 배열 안의 딕셔너리 리스트"
        case .objectDetection:
            return "객체 감지용 - 이미지별 어노테이션 정보"
        case .tabularData:
            return "테이블 데이터용 - 배열 안의 딕셔너리 리스트"
        }
    }
}

extension UTType {
    static var exampleText: UTType {
        UTType(importedAs: "com.example.plain-text")
    }
}

struct convertJsonDocument: FileDocument {
    var text: String
    var originalJsonData: Any?
    var convertedJsonData: Any?
    var conversionType: CreateMLConversionType = .textClassification

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
        
        var convertedData: Any
        
        switch conversionType {
        case .textClassification, .imageClassification, .tabularData:
            convertedData = convertToArrayFormat(jsonData)
        case .objectDetection:
            convertedData = convertToObjectDetectionFormat(jsonData)
        }
        
        convertedJsonData = convertedData
        
        // 변환된 데이터를 JSON 문자열로 변환하여 text에 저장
        if let jsonData = try? JSONSerialization.data(withJSONObject: convertedData, options: [.prettyPrinted]),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            text = jsonString
        }
    }
    
    // 배열 형태로 변환 (텍스트 분류, 이미지 분류, 테이블 데이터용)
    private func convertToArrayFormat(_ data: Any) -> [[String: Any]] {
        var resultArray: [[String: Any]] = []
        
        if let dictionary = data as? [String: Any] {
            // 단일 딕셔너리인 경우 - 그대로 배열에 추가
            resultArray.append(dictionary)
        } else if let array = data as? [Any] {
            // 이미 배열인 경우
            for item in array {
                if let itemDict = item as? [String: Any] {
                    // 딕셔너리면 그대로 추가
                    resultArray.append(itemDict)
                } else {
                    // 딕셔너리가 아니면 value로 감싸기
                    resultArray.append(["value": item])
                }
            }
        } else {
            // 기타 타입인 경우
            resultArray.append(["value": data])
        }
        
        return resultArray
    }
    
    // 객체 감지 형태로 변환
    private func convertToObjectDetectionFormat(_ data: Any) -> [String: Any] {
        if let dictionary = data as? [String: Any] {
            // 이미 딕셔너리 형태면 객체 감지 형식인지 확인
            if dictionary["image"] != nil || dictionary["annotations"] != nil {
                return dictionary
            } else {
                // 일반 딕셔너리면 객체 감지 템플릿 형태로 변환
                return [
                    "image": dictionary["image"] ?? "image_filename.jpg",
                    "annotations": dictionary["annotations"] ?? [
                        [
                            "label": "object",
                            "coordinates": [
                                "x": 0,
                                "y": 0,
                                "width": 100,
                                "height": 100
                            ]
                        ]
                    ]
                ]
            }
        } else if let array = data as? [Any] {
            // 배열인 경우 첫 번째 요소를 기준으로 변환
            if let firstItem = array.first as? [String: Any] {
                return convertToObjectDetectionFormat(firstItem)
            }
        }
        
        // 기본 객체 감지 템플릿 반환
        return [
            "image": "sample_image.jpg",
            "annotations": [
                [
                    "label": "sample_object",
                    "coordinates": [
                        "x": 0,
                        "y": 0,
                        "width": 100,
                        "height": 100
                    ]
                ]
            ]
        ]
    }
    
    // JSON 내보내기 함수
    func exportConvertedJson() -> Data? {
        guard let convertedData = convertedJsonData else { return nil }
        return try? JSONSerialization.data(withJSONObject: convertedData, options: [.prettyPrinted])
    }
    
    // CSV 형식으로 내보내기 함수
    func exportAsCSV() -> Data? {
        guard let convertedData = convertedJsonData as? [[String: Any]] else { return nil }
        
        // 첫 번째 딕셔너리에서 키들을 추출하여 헤더 생성
        guard let firstItem = convertedData.first else { return nil }
        let headers = Array(firstItem.keys).sorted()
        
        var csvString = headers.joined(separator: ",") + "\n"
        
        // 각 딕셔너리를 CSV 행으로 변환
        for item in convertedData {
            let values = headers.map { key in
                let value = item[key] ?? ""
                // CSV 형식에 맞게 이스케이프 처리
                if let stringValue = value as? String {
                    return "\"\(stringValue.replacingOccurrences(of: "\"", with: "\"\""))\""
                } else {
                    return "\(value)"
                }
            }
            csvString += values.joined(separator: ",") + "\n"
        }
        
        return csvString.data(using: .utf8)
    }
}
