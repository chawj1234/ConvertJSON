//
//  ContentView.swift
//  convertJson
//
//  Created by 차원준 on 6/27/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @Binding var document: convertJsonDocument
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingJsonExporter = false
    @State private var showingCsvExporter = false

    var body: some View {
        VStack {
            // 헤더 영역
            HStack {
                Text("JSON to Create ML 변환기")
                    .font(.title2)
                    .bold()
                
                Spacer()
            }
            .padding()
            
            // 변환 타입 선택 영역
            VStack(alignment: .leading, spacing: 8) {
                Text("Create ML 변환 타입 선택")
                    .font(.headline)
                
                Picker("변환 타입", selection: $document.conversionType) {
                    ForEach(CreateMLConversionType.allCases, id: \.self) { type in
                        VStack(alignment: .leading) {
                            Text(type.rawValue)
                                .font(.body)
                            Text(type.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .tag(type)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal)
            
            // 버튼 영역
            HStack {
                // 변환 버튼
                Button("Create ML 형식으로 변환") {
                    convertJson()
                }
                .buttonStyle(.borderedProminent)
                .disabled(document.originalJsonData == nil)
                
                Spacer()
                
                // JSON 내보내기 버튼
                Button("JSON으로 내보내기") {
                    showingJsonExporter = true
                }
                .buttonStyle(.bordered)
                .disabled(document.convertedJsonData == nil)
                
                // CSV 내보내기 버튼
                Button("CSV로 내보내기") {
                    showingCsvExporter = true
                }
                .buttonStyle(.bordered)
                .disabled(document.convertedJsonData == nil || document.conversionType == .objectDetection)
            }
            .padding(.horizontal)
            
            // 상태 표시
            HStack {
                if document.originalJsonData != nil {
                    Label("JSON 파일이 로드되었습니다", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else {
                    Label("JSON 파일을 로드해주세요", systemImage: "exclamationmark.circle")
                        .foregroundColor(.orange)
                }
                
                Spacer()
                
                if document.convertedJsonData != nil {
                    Label("변환 완료", systemImage: "arrow.right.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            
            Divider()
            
            // 선택된 변환 타입 정보 표시
            if document.originalJsonData != nil {
                VStack(alignment: .leading, spacing: 4) {
                    Text("선택된 변환 타입: \(document.conversionType.rawValue)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text(document.conversionType.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
            
            // 텍스트 에디터
            TextEditor(text: $document.text)
                .font(.system(.body, design: .monospaced))
                .padding()
        }
        .alert("알림", isPresented: $showingAlert) {
            Button("확인") { }
        } message: {
            Text(alertMessage)
        }
        .fileExporter(
            isPresented: $showingJsonExporter,
            document: ConvertedJsonFile(data: document.exportConvertedJson() ?? Data()),
            contentType: .json,
            defaultFilename: "converted_for_createml"
        ) { result in
            handleExportResult(result, type: "JSON")
        }
        .fileExporter(
            isPresented: $showingCsvExporter,
            document: ConvertedCsvFile(data: document.exportAsCSV() ?? Data()),
            contentType: .commaSeparatedText,
            defaultFilename: "converted_for_createml"
        ) { result in
            handleExportResult(result, type: "CSV")
        }
    }
    
    private func convertJson() {
        document.convertToCreateMLFormat()
        alertMessage = "\(document.conversionType.rawValue) 형식으로 변환되었습니다!"
        showingAlert = true
    }
    
    private func handleExportResult(_ result: Result<URL, Error>, type: String) {
        switch result {
        case .success(let url):
            alertMessage = "\(type) 파일이 성공적으로 저장되었습니다: \(url.lastPathComponent)"
            showingAlert = true
        case .failure(let error):
            alertMessage = "\(type) 파일 저장 실패: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}

// JSON 파일 내보내기를 위한 구조체
struct ConvertedJsonFile: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    
    var data: Data
    
    init(data: Data) {
        self.data = data
    }
    
    init(configuration: ReadConfiguration) throws {
        data = configuration.file.regularFileContents ?? Data()
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: data)
    }
}

// CSV 파일 내보내기를 위한 구조체
struct ConvertedCsvFile: FileDocument {
    static var readableContentTypes: [UTType] { [.commaSeparatedText] }
    
    var data: Data
    
    init(data: Data) {
        self.data = data
    }
    
    init(configuration: ReadConfiguration) throws {
        data = configuration.file.regularFileContents ?? Data()
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: data)
    }
}

#Preview {
    ContentView(document: .constant(convertJsonDocument()))
}
