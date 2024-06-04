import UIKit

/// DSL for AutoLayout
protocol LayoutAnchor {

    func constraint(equalTo anchor: Self, constant: CGFloat) -> NSLayoutConstraint
    func constraint(greaterThanOrEqualTo anchor: Self, constant: CGFloat) -> NSLayoutConstraint
    func constraint(lessThanOrEqualTo anchor: Self, constant: CGFloat) -> NSLayoutConstraint
}

protocol LayoutDimension: LayoutAnchor {

    func constraint(equalToConstant constant: CGFloat) -> NSLayoutConstraint
    func constraint(greaterThanOrEqualToConstant constant: CGFloat) -> NSLayoutConstraint
    func constraint(lessThanOrEqualToConstant constant: CGFloat) -> NSLayoutConstraint

    func constraint(equalTo anchor: Self, multiplier: CGFloat) -> NSLayoutConstraint
}

extension NSLayoutAnchor: LayoutAnchor {}
extension NSLayoutDimension: LayoutDimension {}

class LayoutProperty<Anchor: LayoutAnchor> {

    fileprivate let anchor: Anchor
    fileprivate let kind: Kind

    enum Kind { case leading, trailing, top, bottom, centerX, centerY, width, height }

    init(anchor: Anchor, kind: Kind) {
        self.anchor = anchor
        self.kind = kind
    }
}

class LayoutAttribute<Dimension: LayoutDimension>: LayoutProperty<Dimension> {

    fileprivate let dimension: Dimension

    init(dimension: Dimension, kind: Kind) {
        self.dimension = dimension

    super.init(anchor: dimension, kind: kind)
    }
}

final class LayoutProxy {

    lazy var leading = property(with: view.leadingAnchor, kind: .leading)
    lazy var trailing = property(with: view.trailingAnchor, kind: .trailing)
    lazy var top = property(with: view.topAnchor, kind: .top)
    lazy var bottom = property(with: view.bottomAnchor, kind: .bottom)
    lazy var centerX = property(with: view.centerXAnchor, kind: .centerX)
    lazy var centerY = property(with: view.centerYAnchor, kind: .centerY)
    lazy var width = attribute(with: view.widthAnchor, kind: .width)
    lazy var height = attribute(with: view.heightAnchor, kind: .height)

    private let view: UIView

    fileprivate init(view: UIView) {
        self.view = view
    }

    private func property<A: LayoutAnchor>(with anchor: A, kind: LayoutProperty<A>.Kind) -> LayoutProperty<A> {
        return LayoutProperty(anchor: anchor, kind: kind)
    }

    private func attribute<D: LayoutDimension>(with dimension: D, kind: LayoutProperty<D>.Kind) -> LayoutAttribute<D> {
        return LayoutAttribute(dimension: dimension, kind: kind)
    }
}

extension LayoutAttribute {

    @discardableResult
    func equal(to constant: CGFloat, priority: UILayoutPriority? = nil) -> NSLayoutConstraint {
        let constraint = dimension.constraint(equalToConstant: constant)
        if let priority = priority {
            constraint.priority = priority
        }
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    func equal(to otherDimension: Dimension,
               multiplier: CGFloat,
               priority: UILayoutPriority? = nil) -> NSLayoutConstraint {
        let constraint = dimension.constraint(equalTo: otherDimension, multiplier: multiplier)
        if let priority = priority {
            constraint.priority = priority
        }
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    func greaterThanOrEqual(to constant: CGFloat, priority: UILayoutPriority? = nil) -> NSLayoutConstraint {
        let constraint = dimension.constraint(greaterThanOrEqualToConstant: constant)
        if let priority = priority {
            constraint.priority = priority
        }
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    func lessThanOrEqual(to constant: CGFloat, priority: UILayoutPriority? = nil) -> NSLayoutConstraint {
        let constraint = dimension.constraint(lessThanOrEqualToConstant: constant)
        if let priority = priority {
            constraint.priority = priority
        }
        constraint.isActive = true
        return constraint
    }
}

extension LayoutProperty {

    @discardableResult
    func equal(to otherAnchor: Anchor,
               offsetBy constant: CGFloat = 0,
               priority: UILayoutPriority? = nil) -> NSLayoutConstraint {
        let constraint = anchor.constraint(equalTo: otherAnchor, constant: constant)
        if let priority = priority {
            constraint.priority = priority
        }
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    func greaterThanOrEqual(to otherAnchor: Anchor,
                            offsetBy constant: CGFloat = 0,
                            priority: UILayoutPriority? = nil) -> NSLayoutConstraint {
        let constraint = anchor.constraint(greaterThanOrEqualTo: otherAnchor, constant: constant)
        if let priority = priority {
            constraint.priority = priority
        }
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    func lessThanOrEqual(to otherAnchor: Anchor,
                         offsetBy constant: CGFloat = 0,
                         priority: UILayoutPriority? = nil) -> NSLayoutConstraint {
        let constraint = anchor.constraint(lessThanOrEqualTo: otherAnchor, constant: constant)
        if let priority = priority {
            constraint.priority = priority
        }
        constraint.isActive = true
        return constraint
    }
}

extension UIView {

    /// Layout without adding to superview.
    func layout(using closure: (LayoutProxy) -> Void) {
        translatesAutoresizingMaskIntoConstraints = false
        closure(LayoutProxy(view: self))
    }

    /// Added as subview to `superview` and setup constraints.
    func layout(in superview: UIView, using closure: (LayoutProxy) -> Void) {
        superview.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        closure(LayoutProxy(view: self))
    }

    /// Layout in superview's bounds without adding to subviews.
    func layout(to superview: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        layout { proxy in
            proxy.bottom == superview.bottomAnchor
            proxy.top == superview.topAnchor
            proxy.leading == superview.leadingAnchor
            proxy.trailing == superview.trailingAnchor
        }
    }

    /// Add this view to superview and clip it edges. Can set custom insets for each side.
    func layout(in superview: UIView, with insets: UIEdgeInsets = .zero) {
        superview.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        layout { proxy in
            proxy.bottom == superview.bottomAnchor - insets.bottom
            proxy.top == superview.topAnchor + insets.top
            proxy.leading == superview.leadingAnchor + insets.left
            proxy.trailing == superview.trailingAnchor - insets.right
        }
    }

    /// Added as subview to `superview` and clipped to its `safeAreaLayoutGuide`.
    func layoutToSafeArea(in superview: UIView) {
        superview.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        layout { proxy in
            proxy.bottom == superview.safeAreaLayoutGuide.bottomAnchor
            proxy.top == superview.safeAreaLayoutGuide.topAnchor
            proxy.leading == superview.safeAreaLayoutGuide.leadingAnchor
            proxy.trailing == superview.safeAreaLayoutGuide.trailingAnchor
        }
    }

    /// Added as subview to `superview` and set custom inset for all edges.
    func layout(in superview: UIView, allEdges insets: CGFloat) {
        superview.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        layout { proxy in
            proxy.bottom == superview.bottomAnchor - insets
            proxy.top == superview.topAnchor + insets
            proxy.leading == superview.leadingAnchor + insets
            proxy.trailing == superview.trailingAnchor - insets
        }
    }
}

func + <A: LayoutAnchor>(lhs: A, rhs: CGFloat) -> (A, CGFloat) {
    return (lhs, rhs)
}

func - <A: LayoutAnchor>(lhs: A, rhs: CGFloat) -> (A, CGFloat) {
    return (lhs, -rhs)
}

/// Custom operator for UILayoutPriority - "~".
/// Example:
/// myView.layout(in: view) {
///    $0.top == view.topAnchor
///    $0.bottom <= view.bottomAnchor - 20
///    $0.bottom == anotherView.bottomAnchor + 20 ~ .defaultHigh   <<--
///    $0.leading == view.leadingAnchor + 10
///    $0.trailing == view.trailingAnchor - 10
/// }
infix operator ~: AdditionPrecedence

func ~ <A: LayoutAnchor>(lhs: A, rhs: UILayoutPriority) -> (A, UILayoutPriority) {
    return (lhs, rhs)
}

func ~ <A: LayoutAnchor>(lhs: (A, CGFloat), rhs: UILayoutPriority) -> ((A, CGFloat), UILayoutPriority) {
    return (lhs, rhs)
}

func ~ (lhs: CGFloat, rhs: UILayoutPriority) -> (CGFloat, UILayoutPriority) {
    return (lhs, rhs)
}

@discardableResult

// MARK: - ==

func == <A: LayoutAnchor>(lhs: LayoutProperty<A>, rhs: (A, CGFloat)) -> NSLayoutConstraint {
    return lhs.equal(to: rhs.0, offsetBy: rhs.1)
}

@discardableResult
func == <A: LayoutAnchor>(lhs: LayoutProperty<A>, rhs: ((A, CGFloat), UILayoutPriority)) -> NSLayoutConstraint {
    return lhs.equal(to: rhs.0.0, offsetBy: rhs.0.1, priority: rhs.1)
}

@discardableResult
func == <A: LayoutAnchor>(lhs: LayoutProperty<A>, rhs: (A, UILayoutPriority)) -> NSLayoutConstraint {
    return lhs.equal(to: rhs.0, priority: rhs.1)
}

@discardableResult
func == <A: LayoutAnchor>(lhs: LayoutProperty<A>, rhs: A) -> NSLayoutConstraint {
    return lhs.equal(to: rhs)
}

// MARK: - >=

@discardableResult
func >= <A: LayoutAnchor>(lhs: LayoutProperty<A>, rhs: A) -> NSLayoutConstraint {
    return lhs.greaterThanOrEqual(to: rhs)
}

@discardableResult
func >= <A: LayoutAnchor>(lhs: LayoutProperty<A>, rhs: (A, CGFloat)) -> NSLayoutConstraint {
    return lhs.greaterThanOrEqual(to: rhs.0, offsetBy: rhs.1)
}

@discardableResult
func >= <A: LayoutAnchor>(lhs: LayoutProperty<A>, rhs: ((A, CGFloat), UILayoutPriority)) -> NSLayoutConstraint {
    return lhs.greaterThanOrEqual(to: rhs.0.0, offsetBy: rhs.0.1, priority: rhs.1)
}

@discardableResult
func >= <A: LayoutAnchor>(lhs: LayoutProperty<A>, rhs: (A, UILayoutPriority)) -> NSLayoutConstraint {
    return lhs.lessThanOrEqual(to: rhs.0, priority: rhs.1)
}

// MARK: - <=

@discardableResult
func <= <A: LayoutAnchor>(lhs: LayoutProperty<A>, rhs: A) -> NSLayoutConstraint {
    return lhs.lessThanOrEqual(to: rhs)
}

@discardableResult
func <= <A: LayoutAnchor>(lhs: LayoutProperty<A>, rhs: (A, CGFloat)) -> NSLayoutConstraint {
    return lhs.lessThanOrEqual(to: rhs.0, offsetBy: rhs.1)
}

@discardableResult
func <= <A: LayoutAnchor>(lhs: LayoutProperty<A>, rhs: ((A, CGFloat), UILayoutPriority)) -> NSLayoutConstraint {
    return lhs.lessThanOrEqual(to: rhs.0.0, offsetBy: rhs.0.1, priority: rhs.1)
}

@discardableResult
func <= <A: LayoutAnchor>(lhs: LayoutProperty<A>, rhs: (A, UILayoutPriority)) -> NSLayoutConstraint {
    return lhs.lessThanOrEqual(to: rhs.0, priority: rhs.1)
}

// MARK: - Dimensions
// MARK: - ==
@discardableResult
func == <D: LayoutDimension>(lhs: LayoutAttribute<D>, rhs: CGFloat) -> NSLayoutConstraint {
    return lhs.equal(to: rhs)
}

@discardableResult
func == <D: LayoutDimension>(lhs: LayoutAttribute<D>, rhs: (CGFloat, UILayoutPriority)) -> NSLayoutConstraint {
    return lhs.equal(to: rhs.0, priority: rhs.1)
}

@discardableResult
func == <D: LayoutDimension>(lhs: LayoutAttribute<D>, rhs: LayoutAttribute<D>) -> NSLayoutConstraint {
    return lhs.equal(to: rhs.dimension)
}

// MARK: - *= Multiply 

@discardableResult
func *= <D: LayoutDimension>(lhs: LayoutAttribute<D>, rhs: (D, CGFloat)) -> NSLayoutConstraint {
    return lhs.equal(to: rhs.0, multiplier: rhs.1)
}

@discardableResult
func *= <D: LayoutDimension>(lhs: LayoutAttribute<D>, rhs: (LayoutAttribute<D>, CGFloat)) -> NSLayoutConstraint {
    return lhs.equal(to: rhs.0.dimension, multiplier: rhs.1)
}

@discardableResult
func *= <D: LayoutDimension>(lhs: LayoutAttribute<D>,
                             rhs: ((D, CGFloat), UILayoutPriority)) -> NSLayoutConstraint {
    return lhs.equal(to: rhs.0.0, multiplier: rhs.0.1, priority: rhs.1)
}

// MARK: - >=

@discardableResult
func >= <D: LayoutDimension>(lhs: LayoutAttribute<D>, rhs: CGFloat) -> NSLayoutConstraint {
    return lhs.greaterThanOrEqual(to: rhs)
}
@discardableResult
func >= <D: LayoutDimension>(lhs: LayoutAttribute<D>, rhs: (CGFloat, UILayoutPriority)) -> NSLayoutConstraint {
    return lhs.greaterThanOrEqual(to: rhs.0, priority: rhs.1)
}

// MARK: - <=

@discardableResult
func <= <D: LayoutDimension>(lhs: LayoutAttribute<D>, rhs: CGFloat) -> NSLayoutConstraint {
    return lhs.lessThanOrEqual(to: rhs)
}

@discardableResult
func <= <D: LayoutDimension>(lhs: LayoutAttribute<D>, rhs: (CGFloat, UILayoutPriority)) -> NSLayoutConstraint {
    return lhs.lessThanOrEqual(to: rhs.0, priority: rhs.1)
}
