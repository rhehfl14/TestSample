//
//  ViewController.swift
//  TestProject
//
//  Created by 이철우 on 2021/09/10.
//

import UIKit
import RxSwift
import RxCocoa
import WebKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnStrAdd: UIButton!
    @IBOutlet weak var segmentControl: CustomSegmentedControl!
    @IBOutlet weak var webView: WKWebView!
    
//    let observer = PublishSubject<[String]>()
    let disposeBack = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let observer = PublishSubject<[String]>()
        //        observer
        
        Observable.from(optional: ["a", "b", "c", "d", "e"])
            .bind(to: tableView.rx.items) { (tableView: UITableView, index: Int, element: String) -> UITableViewCell in
                
                var cell: UITableViewCell?
                if index % 2 == 0 {
                    guard let firstCell = tableView.dequeueReusableCell(withIdentifier: "TestViewCell") as? TestViewCell else {
                        return UITableViewCell()
                    }
                    firstCell.labelTitle.text = element
                    cell = firstCell
                    
                } else {
                    guard let secondCell = tableView.dequeueReusableCell(withIdentifier: "TestRightViewCell") as? TestRightViewCell else {
                        return UITableViewCell()
                    }
                    secondCell.labelTitle.text = element
                    cell = secondCell
                }
                return cell ?? UITableViewCell()
                
            }.disposed(by: disposeBack)
        
        segmentControl.initView(buttonTitles: ["test1", "test2", "test3"], selectImage: UIColor.white.imageWithColor())
        
        segmentControl.rx
            .selectChagne
            .asObservable()
            .subscribe(onNext: { index in
                
                print("index \(index)")
        }).disposed(by: disposeBack)
        
        btnStrAdd.rx
            .tap
            .bind { [weak self] in
                guard let self = self else { return }
                
                self.segmentControl.inputSubTitle(index: 1,
                                                  subTitle: "123",
                                                  textFont: UIFont(name: "AppleSDGothicNeo-Regular", size: 16) ?? UIFont().withSize(16),
                                                  selectTextColor: .red,
                                                  deSelectTextColor: .blue)
                
                guard let url = URL(string: "https://netflix.com") else { return }
                var request = URLRequest(url: url)
                
                request.httpMethod = "POST"
                
                self.webView.load(request)
                
            }.disposed(by: disposeBack)
    }
}
extension ViewController {
//extension ViewController: UITableViewDelegate, UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        0
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        UITableViewCell()
//    }
    
}

extension UIColor {
    /// 컬러를 이미지로 변경
    /// - Parameter color: 컬러
    /// - Returns: 컬러를 가진 이미지
    func imageWithColor() -> UIImage {
      let rect: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1)
      UIGraphicsBeginImageContextWithOptions(CGSize(width: 1, height: 1), false, 0)
      self.setFill()
      UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
      UIGraphicsEndImageContext()
      return image
    }
}

extension UIView {
    /// 뷰의 라운드를 그린다.
    /// - Parameters:
    ///   - color: 색상 (필수)
    ///   - borderWidth: 테두리굵기 (기본1)
    ///   - cornerRadius: 모서리 둥글기 (기본10)
    ///   - masked: 테두리 둥글기 방향 (전방향)
    func borderRound(color: UIColor, borderWidth: CGFloat = 1.0, cornerRadius: CGFloat = 10.0, masked: CACornerMask = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]) {
        self.layer.masksToBounds = true
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = borderWidth
        self.clipsToBounds = true
        self.layer.cornerRadius = cornerRadius
        self.layer.maskedCorners = masked
    }
}


class TestViewCell: UITableViewCell {
    
    @IBOutlet weak var labelTitle: UILabel!
}


class TestRightViewCell: UITableViewCell {
    
    @IBOutlet weak var labelTitle: UILabel!
}

extension String {
    func setAttributedStr(font: UIFont, color: UIColor) -> NSMutableAttributedString {
        let attrStr = NSMutableAttributedString()
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: color, .font: font]
        attrStr.append(NSAttributedString(string: self, attributes: attributes))
        return attrStr
    }
}
