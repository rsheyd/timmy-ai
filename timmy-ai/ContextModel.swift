//
//  ContextModel.swift
//  timmy-ai
//
//  Created by Roman Sheydvasser on 12/16/25.
//

import Foundation
import Combine

final class ContextModel: ObservableObject {
    @Published var snapshot: ContextSnapshot?

    init(snapshot: ContextSnapshot? = nil) {
        self.snapshot = snapshot
    }
}
