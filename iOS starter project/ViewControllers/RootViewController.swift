//
//  RootViewController.swift
//  iOS starter project
//
//  Created by Davide Ceresola on 03/04/21.
//

import UIKit

class RootViewController: BaseViewController {
    
    private var coordinator: RootCoordinator!
    
    private var currentChildViewController: UIViewController? {
        return children.first
    }
    
    private lazy var loadingActivityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var loadingMessageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = "Loading..."
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.isHidden = true
        return label
    }()

    private lazy var loadingContentView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = 5.0
        view.axis = .vertical
        view.addArrangedSubview(self.loadingActivityIndicator)
        view.addArrangedSubview(self.loadingMessageLabel)
        return view
    }()
    
    override var childForStatusBarStyle: UIViewController? {
        return currentChildViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(loadingContentView)
        installLayoutConstraints()
    }
    
    private func installLayoutConstraints() {

        NSLayoutConstraint.activate([
            loadingContentView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingContentView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

    }

    
    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)

        if children.isEmpty {
            startLoading()
        }

    }
    
    //  MARK: - RootCoordinated
    func start(coordinator: RootCoordinator) {

        self.coordinator = coordinator

        self.children.forEach {
            ($0 as? RootCoordinated)?.start(coordinator: coordinator)
        }

    }
    
    
    //  MARK: - Utils
    func presentChildViewController(_ controller: UIViewController, completion presentCompletion: ((Bool) -> Void)? = nil) {

        let currentController = currentChildViewController
        currentController?.willMove(toParent: nil)

        addChild(controller)

        controller.view.frame = view.bounds
        controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        controller.beginAppearanceTransition(true, animated: true)
        view.insertSubview(controller.view, aboveSubview: loadingContentView)

        let completion: (Bool) -> Void = { [weak self] finished in

            self?.stopLoading()

            controller.endAppearanceTransition()
            controller.didMove(toParent: self)

            if let currentController = currentController {
                RootViewController.completeDismissal(of: currentController)
            }
            presentCompletion?(finished)
        }

        controller.view.alpha = 0

        UIView.animate(withDuration: 0.2, animations: {
            controller.view.alpha = 1
        }, completion: completion)

    }
    
    private static func completeDismissal(of childViewController: UIViewController) {

        if childViewController.presentedViewController != nil,
            childViewController.presentedViewController?.presentingViewController == childViewController {
            childViewController.dismiss(animated: false, completion: nil)
        }

        childViewController.beginAppearanceTransition(false, animated: true)
        childViewController.view.removeFromSuperview()
        childViewController.endAppearanceTransition()

        childViewController.removeFromParent()

    }
    
    func dismissChildViewController() {

        guard let controller = currentChildViewController else {
            return
        }

        startLoading()

        controller.willMove(toParent: nil)

        let completion: (Bool) -> Void = { _ in
            RootViewController.completeDismissal(of: controller)
        }

        let finalFrame = controller.view.frame.applying(.init(translationX: 0, y: view.frame.height))

        UIView.animate(withDuration: 0.2, animations: {
            controller.view.frame = finalFrame
        }, completion: completion)

    }
    
    //  MARK: - Loading
    private func startLoading() {
        loadingActivityIndicator.startAnimating()
        loadingContentView.isHidden = false
    }

    private func stopLoading() {
        loadingActivityIndicator.stopAnimating()
        loadingContentView.isHidden = true
    }
}

