//
//  TONTransfer.swift
//
//  Created by Sun on 2024/6/13.
//

import Foundation

import GRDB
import TonSwift

// MARK: - TONTransfer

public class TONTransfer: Action {
    // MARK: Nested Types

    enum CodingKeys: String, CodingKey {
        case sender
        case recipient
        case amount
        case comment
    }

    // MARK: Properties

    public let sender: WalletAccount
    public let recipient: WalletAccount
    public let amount: Int64
    public let comment: String?

    // MARK: Lifecycle

    init(
        eventID: String,
        index: Int,
        sender: WalletAccount,
        recipient: WalletAccount,
        amount: Int64,
        comment: String?
    ) {
        self.sender = sender
        self.recipient = recipient
        self.amount = amount
        self.comment = comment

        super.init(eventID: eventID, index: index)
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        sender = try container.decode(WalletAccount.self, forKey: .sender)
        recipient = try container.decode(WalletAccount.self, forKey: .recipient)
        amount = try container.decode(Int64.self, forKey: .amount)
        comment = try? container.decode(String.self, forKey: .comment)

        try super.init(from: decoder)
    }
}

// MARK: IActionRecord

extension TONTransfer: IActionRecord {
    func save(db: Database, index: Int, lt: Int64) throws {
        try TONTransferRecord.record(index: index, lt: lt, self).save(db)
        try WalletAccountRecord.record(recipient).save(db)
        try WalletAccountRecord.record(sender).save(db)
    }
}
