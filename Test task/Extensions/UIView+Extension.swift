//
//  UIView+Extension.swift
//  Test task
//
//  Created by oleh yeroshkin on 04.06.2024.
//

import UIKit

extension UIView {
    // Return class name for use it in Register cells
    static var identifier: String {
        return String(describing: self)
    }
}

extension UITableView {
    func register<T: UITableViewCell>(cell: T.Type) {
        register(T.self, forCellReuseIdentifier: T.identifier)
    }

    func dequeueCell<T: UITableViewCell>(for indexPath: IndexPath) -> T {
        return dequeueReusableCell(withIdentifier: T.identifier, for: indexPath) as! T
    }
}
