//
//  Account.swift
//
//  Created by Sun on 2024/6/13.
//

import Foundation

import TonSwift

struct Account: Codable {
    let address: Address
    let balance: Int64
    let status: String
    let name: String?
    let icon: String?
    let isSuspended: Bool?
    let isWallet: Bool
}
