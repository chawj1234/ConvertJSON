//
//  convertJsonApp.swift
//  convertJson
//
//  Created by 차원준 on 6/27/25.
//

import SwiftUI

@main
struct convertJsonApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: convertJsonDocument()) { file in
            ContentView(document: file.$document)
        }
    }
}
