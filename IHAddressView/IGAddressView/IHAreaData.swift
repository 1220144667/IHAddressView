//
//  IHAreaData.swift
//  iGenealogy
//
//  Created by hlf on 2022/6/29.
//

import Foundation
import UIKit

struct IGAreaProvider {
    static var sourceList: [IHAreaData] = []
    //获取本地数据
    static func loadAreaDataAtAreaId(_ areaId: String, completion: @escaping (([IHAreaData]) -> Void)) {
        var dataList: [IHAreaData] = []
        for item in self.getSourceList() {
            if areaId == item.parentid {
                dataList.append(item)
            }
        }
        completion(dataList)
        //这里替换成自己的网络数据加载方案
        /*
         var para: [String: Any] = [:]
         if !areaId.isEmpty {
             para["code"] = areaId
         }
        IG.Network.post(.getArea, para, [IHAreaData].self) { response in
            guard let result = response.result else { return }
            completion(result)
        } _: { error in
            dlog(message: error)
        }
         */
    }
    
    static func getSourceList() -> [IHAreaData] {
        if sourceList.isEmpty {
            let path: String = Bundle.main.path(forResource: "adress", ofType: "txt")!
            var encodingPath: String = ""
            do {
                encodingPath = try String.init(contentsOfFile: path, encoding: String.Encoding.utf8)
            }catch {
                print("发生错误")
            }
            let resData: Data = encodingPath.data(using: String.Encoding.utf8) ?? Data()
            var areas: [IHAreaData]?
            do {
                let jsonDecoder = JSONDecoder()
                areas = try jsonDecoder.decode([IHAreaData].self, from: resData)
            } catch {
                print(error)
            }
            sourceList = areas ?? []
        }
        return sourceList
    }
}

//数据模型
struct IHAreaData: Codable {
    var id: String = ""
    var parentid: String = ""
    var name: String = ""
}

//一些自定义配置
struct IGAddressConfig {
    //可选级别（默认5级）
    static var maxLevels: Int = 5
    //title
    static var title: String = "请选择地址"
    //取消按钮
    static var cancel: String = "取消"
    //主题色
    static var themColor: UIColor = UIColor.black
    //文本颜色
    static var textColor: UIColor = UIColor.black
    //选中结果文本颜色
    static var selectTextColor: UIColor = UIColor.init(red: 133.0/255, green: 92.0/255, blue: 92.0/255, alpha: 1)
    //设置是否线条渐变
    static var isGradientLine: Bool = false
    //弹窗高度
    static var viewHeight: CGFloat = 400.0
}

struct IH {
    //屏幕宽高
    public static var screen_width: CGFloat {
        return UIScreen.main.bounds.size.width
    }
    public static var screen_height: CGFloat {
        return UIScreen.main.bounds.size.height
    }
    // 当前window
    public static var keyWindow: UIWindow {
        return self.getKeyWindow() ?? UIWindow.init(frame: UIScreen.main.bounds)
    }
    
    public static func getKeyWindow() -> UIWindow? {
        if #available(iOS 14.0, *){
            if let window = UIApplication.shared.connectedScenes.compactMap({$0 as? UIWindowScene}).first?.windows.first{
                return window
            }else{
                return nil
            }
        }else if #available(iOS 13.0, *){
            if let window = UIApplication.shared.connectedScenes.filter({$0.activationState == .foregroundActive}).compactMap({$0 as? UIWindowScene}).first?.windows.filter({$0.isKeyWindow}).first{
                return window
            }else if let window = UIApplication.shared.delegate?.window {
                return window
            }else{
                return nil
            }
        }else{
            if let window = UIApplication.shared.delegate?.window {
                return window
            }else{
                return nil
            }
        }
    }
    /// 通过文字计算label的宽度（单行文字的情况）
    public static func labelWithWidth(text: String, font: UIFont) -> CGFloat {
        let statusLabelText: NSString = text as NSString
        let size = CGSize(width: 500000, height: 500000)
        let attr = [NSAttributedString.Key.font: font]
        let strSize = statusLabelText.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attr, context: nil).size
        return strSize.width
    }
}
