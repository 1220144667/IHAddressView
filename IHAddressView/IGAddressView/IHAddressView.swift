//
//  IHAddressView.swift
//  iGenealogy
//
//  Created by hlf on 2022/6/29.
//
import UIKit

class IHAddressView: UIView {
    typealias CompletionBlock = (_ list: [IHAreaData]) -> ()
    /// 传递的数据
    public var callBackBlock: CompletionBlock?
    //省、市/区、县、镇、村（由maxLevels确定具体数据）
    private var addressList:[[IHAreaData]] = []
    //标题数组
    private var titleList = ["请选择"]
    //选择结果数组
    private var result: [IHAreaData] = []
    //按钮数组
    private var buttonList: [UIButton] = []
    //数据列表数组
    private var tableViewList: [UITableView] = []
    //判断是滚动还是点击
    private var isClick: Bool = false
    // MARK: - Lazy
    private lazy var containView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: IH.screen_height, width: IH.screen_width, height: IGAddressConfig.viewHeight))
        view.backgroundColor = UIColor.white
        view.setCorner(byRoundingCorners: [.topLeft, .topRight], radii: 8.0)
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 16, y: 0, width: 160, height: 52))
        label.text = "请选择地址"
        label.textColor = IGAddressConfig.textColor
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .left
        return label
    }()
    
    private lazy var cancelBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: IH.screen_width - 44 - 16, y: 0, width: 44, height: 52)
        btn.setTitle("取消", for: .normal)
        btn.setTitleColor(IGAddressConfig.textColor, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16)
        btn.addTarget(self, action: #selector(cancelBtnClicked(btn:)), for: .touchUpInside)
        return btn
    }()
    
    private lazy var sepLineView: UIView = {
        let view = UIView(frame: CGRect(x: 16, y: 52, width: IH.screen_width - 32, height: 1))
        view.backgroundColor = UIColor.black.withAlphaComponent(0.12)
        return view
    }()
    
    private lazy var titleScrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 53, width: IH.screen_width, height: 44))
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var lineView: UIView = {
        let lineView = UIView(frame: .zero)
        lineView.backgroundColor = IGAddressConfig.textColor
        return lineView
    }()
    
    private lazy var contentScrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: self.titleScrollView.frame.maxY, width: IH.screen_width, height: IGAddressConfig.viewHeight - self.titleScrollView.frame.maxY))
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("初始化View")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let currentPoint = touches.first?.location(in: self)
        if !self.containView.frame.contains(currentPoint ?? CGPoint()) {
            self.dismiss()
        }
    }
    
    private func setupUI() {
        self.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.frame = CGRect(x: 0, y: 0, width: IH.screen_width, height: IH.screen_height)
        IH.keyWindow.addSubview(self)
        self.addSubview(self.containView)
        self.containView.addSubview(self.titleLabel)
        self.containView.addSubview(self.cancelBtn)
        self.containView.addSubview(self.sepLineView)
        self.containView.addSubview(self.titleScrollView)
        self.containView.addSubview(self.contentScrollView)
    }
    
    public func setupAllTitle(index: Int) {
        for view in self.titleScrollView.subviews {
            view.removeFromSuperview()
        }
        self.buttonList.removeAll()
        var x: CGFloat = 16
        for (i, title) in self.titleList.enumerated() {
            let font = UIFont.systemFont(ofSize: 14)
            let titleLenth: CGFloat = IH.labelWithWidth(text: title, font: font)
            let titleBtn: UIButton = UIButton(type: .custom)
            titleBtn.tag = i
            titleBtn.setTitle(title, for: .normal)
            titleBtn.setTitleColor(IGAddressConfig.textColor, for: .normal)
            titleBtn.setTitleColor(IGAddressConfig.selectTextColor, for: .selected)
            titleBtn.isSelected = false
            titleBtn.titleLabel?.font = font
            titleBtn.frame = CGRect(x: x, y: 2, width: titleLenth, height: 40)
            x += titleLenth + 6
            titleBtn.addTarget(self, action: #selector(titleBtnClicked(btn:)), for: .touchUpInside)
            self.buttonList.append(titleBtn)
            // 选中
            if i == index {
                self.titleBtnClicked(btn: titleBtn)
            }
            self.titleScrollView.addSubview(titleBtn)
            self.titleScrollView.contentSize = CGSize(width: x, height: 0)
        }
        self.contentScrollView.contentSize = CGSize(width: CGFloat(self.titleList.count) * IH.screen_width, height: 0)
    }
    
    private func setupOneTableView(btnTag: Int) {
        var tableView: UITableView
        if self.tableViewList.count == 0 {
            tableView = UITableView(frame: .zero, style: .plain)
            tableView.frame = CGRect(x: CGFloat(btnTag) * IH.screen_width, y: 0, width: IH.screen_width, height: self.contentScrollView.frame.size.height)
            tableView.tag = btnTag
            tableView.delegate = self
            tableView.dataSource = self
            tableView.backgroundColor = UIColor.clear
            tableView.separatorStyle = .none
            self.contentScrollView.addSubview(tableView)
            self.tableViewList.append(tableView)
            self.getAreaData(tag: 0, completion: nil)
        } else {
            if btnTag < self.tableViewList.count {
                tableView = self.tableViewList[btnTag]
            } else {
                tableView = UITableView(frame: .zero, style: .plain)
                tableView.frame = CGRect(x: CGFloat(btnTag) * IH.screen_width, y: 0, width: IH.screen_width, height: self.contentScrollView.frame.size.height)
                tableView.tag = btnTag
                tableView.delegate = self
                tableView.dataSource = self
                tableView.backgroundColor = UIColor.clear
                tableView.separatorStyle = .none
                self.contentScrollView.addSubview(tableView)
                self.tableViewList.append(tableView)
            }
        }
    }
    
    // MARK: - Fuction
    @objc private func cancelBtnClicked(btn: UIButton) {
        self.dismiss()
    }
    
    @objc private func titleBtnClicked(btn: UIButton) {
        for tempBtn in self.buttonList {
            tempBtn.isSelected = false
        }
        btn.isSelected = true
        self.isClick = true
        self.setupOneTableView(btnTag: btn.tag)
        UIView.animate(withDuration: 0.25) {
            self.lineView.frame = CGRect(x: btn.frame.minX + btn.frame.width * 0.25, y: btn.frame.height - 3, width: btn.frame.width * 0.5, height: 3)
        }
        if IGAddressConfig.isGradientLine {
            self.lineView.backgroundColor = UIColor.clear
            self.lineView.setGradientColor(colors: [IGAddressConfig.themColor.cgColor, IGAddressConfig.themColor.withAlphaComponent(0.2).cgColor], startPoint: CGPoint(x: 0, y: 0.5), endPoint: CGPoint(x: 1.0, y: 0.5), corner: 2)
        }
        self.titleScrollView.addSubview(self.lineView)
        self.contentScrollView.contentOffset = CGPoint(x: CGFloat(btn.tag) * IH.screen_width, y: 0)
    }
}

extension IHAddressView {
    public func showAddressView(completion: @escaping CompletionBlock) {
        self.callBackBlock = completion
        setupUI()
        UIView.animate(withDuration: 0.25) { [self] in
            self.containView.frame = CGRect(x: 0, y: IH.screen_height - IGAddressConfig.viewHeight, width: IH.screen_width, height: IGAddressConfig.viewHeight)
        }
        setupAllTitle(index: 0)
    }
    
    private func dismiss() {
        UIView.animate(withDuration: 0.25) { [self] in
            self.containView.frame = CGRect(x: 0, y: IH.screen_height, width: IH.screen_width, height: IGAddressConfig.viewHeight)
        } completion: { (finish) in
            if finish {
                self.removeFromSuperview()
            }
        }
    }
}

// MARK: -UIScrollViewDelegate
extension IHAddressView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.contentScrollView {
            let offset: CGFloat = scrollView.contentOffset.x / IH.screen_width
            let offsetIndex: Int = Int(offset)
            if offset != CGFloat(offsetIndex) {
                self.isClick = false
            }
            if self.isClick == false {
                if offset == CGFloat(offsetIndex) {
                    let titleBtn: UIButton = self.buttonList[offsetIndex]
                    self.titleBtnClicked(btn: titleBtn)
                }
            }
        }
    }
}

// MARK: -UITableViewDelegate, UITableViewDataSource
extension IHAddressView: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !self.addressList.isEmpty {
            let list = self.addressList[tableView.tag]
            return list.count
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let addressCellIdentifier = "IGAddressCellIdentifier"
        var cell = tableView.dequeueReusableCell(withIdentifier: addressCellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style:.default, reuseIdentifier: addressCellIdentifier)
        }
        let list = self.addressList[tableView.tag]
        let model = list[indexPath.row]
        cell?.textLabel?.text = model.name
        cell?.textLabel?.font = UIFont.systemFont(ofSize: 14)
        cell?.textLabel?.textColor = UIColor.black
        cell?.selectionStyle = .none
        return cell ?? UITableViewCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let tag = tableView.tag
        let list = self.addressList[tableView.tag]
        let model = list[indexPath.row]
        // 修改标题
        self.titleList[tag] = model.name == "" ? "请选择" : model.name
        // 修改选中的index
        if self.result.count > tag {
            self.result[tableView.tag] = model
        } else {
            self.result.append(model)
        }
        if self.buttonList.count == (tag + 1) {
            self.titleList.append("请选择")
        }
        // 网络请求获取市
        self.getAreaData(tag: tag + 1, code: model.id) {
            self.setupAllTitle(index: tag)
            self.dismiss()
            if self.callBackBlock != nil {
                self.callBackBlock!(self.result)
            }
        }
        if (tag + 1) == IGAddressConfig.maxLevels {
            if self.result.count < IGAddressConfig.maxLevels {
                print("数据错误！请联系管理员")
                return
            }
            self.setupAllTitle(index: tag)
            self.dismiss()
            if self.callBackBlock != nil {
                self.callBackBlock!(self.result)
            }
        }
    }
}
// MARK: -网络获取省市县街道
extension IHAddressView {
    func getAreaData(tag: Int, code: String = "0", completion: (() -> Void)?) {
        IGAreaProvider.loadAreaDataAtAreaId(code) { list in
            if list.isEmpty {
                if completion != nil {
                    completion!()
                }
                return
            }
            if tag < self.addressList.count {
                self.addressList[tag] = list
            }else {
                self.addressList.append(list)
            }
            self.setupAllTitle(index: tag)
            self.tableViewList[tag].reloadData()
        }
    }
}

//MARK:view的扩展
extension UIView {
    /// 设置某几个角的圆角
    public func setCorner(byRoundingCorners corners: UIRectCorner, radii: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radii, height: radii))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
    }
    
    /// 设置渐变颜色
    public func setGradientColor(colors: [CGColor], startPoint: CGPoint, endPoint: CGPoint, corner: CGFloat) {
        self.removeAllSublayers()
        let gradientLayer = CAGradientLayer()
        gradientLayer.cornerRadius = corner
        gradientLayer.frame = self.bounds
        // 设置渐变的主颜色(可多个颜色添加)
        gradientLayer.colors = colors
        // startPoint与endPoint分别为渐变的起始方向与结束方向, 它是以矩形的四个角为基础的,默认是值是(0.5,0)和(0.5,1)
        // (0,0)为左上角 (1,0)为右上角 (0,1)为左下角 (1,1)为右下角
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        // 将gradientLayer作为子layer添加到主layer上
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    /// 移除渐变
    public func removeAllSublayers() {
        guard let sublayers =  self.layer.sublayers else {
            return
        }
        for layer in sublayers {
            layer.removeFromSuperlayer()
        }
    }
}
