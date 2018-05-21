//
//  Resizing.swift
//  ResizableFormSheet
//
//  Created by Dabby Ndubisi on 2018-05-13.
//  Copyright © 2018 Dabby Ndubisi. All rights reserved.
//

import UIKit

enum ControllerSizeType {
	case formSheet
	case fullScreen
}

// MARK: - Resizing Policy
protocol ResizingPolicy {
	func sizeType(for viewController: UIViewController) -> ControllerSizeType
}

struct ModalResizingPolicy: ResizingPolicy {
	func sizeType(for viewController: UIViewController) -> ControllerSizeType {
		switch viewController {
		case is VC: return .formSheet
		case is OtherVC: return .fullScreen
		default: return .formSheet
		}
	}
}

// MARK: - Resizer
protocol Resizer {
	func resize(viewController: UIViewController, using policy: ResizingPolicy)
}

class NavigationModalResizer: Resizer {
	weak var navigationController: UINavigationController?
	private var lastSize: ControllerSizeType
	private var originalCornerRadius: CGFloat?
	
	init(navigationController: UINavigationController) {
		self.navigationController = navigationController
		
		// Assume size starts as regular formSheet
		lastSize = .formSheet
	}
	
	func resize(viewController: UIViewController, using policy: ResizingPolicy) {
		guard let navigationController = navigationController,
			navigationController.viewControllers.contains(viewController) else { return }
		
		// Obtain original corner radius of form sheet
		guard let originalCornerRadius = originalCornerRadius else {
			self.originalCornerRadius = navigationController.presentationController?.presentedView?.layer.cornerRadius
			resize(viewController: viewController, using: policy)
			return
		}
		
		let newSize = policy.sizeType(for: viewController)
		guard newSize != lastSize else { return }
		
		lastSize = newSize
		var contentSize = preferredContentSize(for: newSize)
		// account for nav bar
		contentSize.height -= 44.0
		
		// animate resize process
		let animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeIn) {
			navigationController.preferredContentSize = contentSize
			navigationController.presentationController?.presentedView?.layer.cornerRadius = newSize == .fullScreen ? 0.0 : originalCornerRadius
			// Manually trigger a layout pass to apply new size
			navigationController.presentationController?.containerView?.setNeedsLayout()
			navigationController.presentationController?.containerView?.layoutIfNeeded()
		}
		animator.startAnimation()
	}
	
	private func preferredContentSize(for sizeType: ControllerSizeType) -> CGSize {
		switch sizeType {
		case .formSheet:
			return CGSize(width: 540.0, height: 620.0)
		case .fullScreen:
			return UIScreen.main.bounds.size
		}
	}
}

// MARK: - First VC
class VC: UIViewController {
	var button = UIButton()
	
	var onButtonTapped: (() -> Void)?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = UIColor.white
		view.addSubview(button)
		button.setTitle("Press Me", for: .normal)
		button.setTitleColor(UIColor.blue, for: .normal)
		button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
		button.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
			])
		view.layoutIfNeeded()
	}
	
	@objc dynamic private func buttonTapped() {
		onButtonTapped?()
	}
}

// MARK: - Second VC
class OtherVC: UIViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = UIColor.green
	}
}

// MARK: - Router
class Router: NSObject, UINavigationControllerDelegate {
	let baseViewController: UIViewController
	private let navigationController: UINavigationController
	
	private var resizer: Resizer
	private var policy: ResizingPolicy
	
	var otherVC: OtherVC { return OtherVC() }
	
	init(baseViewController: UIViewController) {
		self.baseViewController = baseViewController
		navigationController = UINavigationController()
		resizer = NavigationModalResizer(navigationController: navigationController)
		policy = ModalResizingPolicy()
		
		super.init()
	}
	
	func begin() {
		let vc = VC()
		navigationController.setViewControllers([vc], animated: true)
		navigationController.modalPresentationStyle = .formSheet
		navigationController.delegate = self
		let otherVC = self.otherVC
		vc.onButtonTapped = { [navigationController] in
			navigationController.pushViewController(otherVC, animated: true)
		}
		baseViewController.present(navigationController, animated: true, completion: nil)
	}
	
	// MARK: UINavigationControllerDelegate
	func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
		// perform resizing after the navigation controller has displayed the new topViewController
		resizer.resize(viewController: viewController, using: policy)
	}
}
