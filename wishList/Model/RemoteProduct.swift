//
//  RemoteProduct.swift
//  wishList
//
//  Created by t2023-m0074 on 4/9/24.
//

import UIKit
// URLSeesion
struct RemoteProduct: Decodable {
    let id: Int
    let title: String
    let description: String
    let price: Double
    let thumbnail: URL
}
