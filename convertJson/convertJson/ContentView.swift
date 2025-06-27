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
    @State private var showingExporter = false

    var body: some View {
        VStack {
            // 헤더 영역
            HStack {
                Text("JSON to Create ML 변환기")
                    .font(.title2)
                    .bold()
                
                Spacer()
                
                // 변환 버튼
                Button("Create ML 형식으로 변환") {
                    convertJson()
                }
                .buttonStyle(.borderedProminent)
                .disabled(document.originalJsonData == nil)
                
                // 내보내기 버튼
                Button("변환된 JSON 내보내기") {
                    showingExporter = true
                }
                .buttonStyle(.bordered)
                .disabled(document.convertedJsonData == nil)
            }
            .padding()
            
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
            isPresented: $showingExporter,
            document: ConvertedJsonFile(data: document.exportConvertedJson() ?? Data()),
            contentType: .json,
            defaultFilename: "converted_for_createml"
        ) { result in
            switch result {
            case .success(let url):
                alertMessage = "파일이 성공적으로 저장되었습니다: \(url.lastPathComponent)"
                showingAlert = true
            case .failure(let error):
                alertMessage = "파일 저장 실패: \(error.localizedDescription)"
                showingAlert = true
            }
        }
    }
    
    private func convertJson() {
        document.convertToCreateMLFormat()
        alertMessage = "JSON이 Create ML 형식으로 변환되었습니다!"
        showingAlert = true
    }
}

// 파일 내보내기를 위한 구조체
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

#Preview {
    ContentView(document: .constant(convertJsonDocument()))
}
