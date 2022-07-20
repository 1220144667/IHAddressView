//
//  ViewController.swift
//  IHAddressView
//
//  Created by hlf on 2022/7/16.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(button)
    }
    
    lazy var button: UIButton = {
        let button = UIButton(frame: CGRect(x: 60, y: 88, width: view.frame.size.width - 120, height: 44))
        button.setTitle("选择地址", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.addTarget(self, action: #selector(buttonClick(_:)), for: .touchUpInside)
        return button
    }()
    
    @objc func buttonClick(_ sender: UIButton) {
        IGAddressConfig.maxLevels = 4
        IGAddressConfig.isGradientLine = true
        let addressView = IHAddressView(frame: .zero)
        addressView.showAddressView() { [weak self] list in
            guard let self = self else { return }
            var address = ""
            for item in list {
                address += item.name
            }
            self.button.setTitle(address, for: .normal)
        }
    }
}

