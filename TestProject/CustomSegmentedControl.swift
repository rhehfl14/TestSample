//
//  CustomSegmentedControl.swift
//  TestProject
//
//  Created by 이철우 on 2021/09/23.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxGesture

class CustomSegmentedControl: UIView, CustomSegmentedControlDelegate {
    
    
    /// SubTitle 구조체
    struct SubTitle {
        var subTitle: String = ""
        var subTitleFont: UIFont? = nil
        var titleSelectColor: UIColor? = nil
        var titleDeSelectColor: UIColor? = nil
        
        mutating func setSubTitle(subTitle: String, subTitleFont: UIFont, titleSelectColor: UIColor, titleDeSelectColor: UIColor) {
            self.subTitle = subTitle
            self.subTitleFont = subTitleFont
            self.titleSelectColor = titleSelectColor
            self.titleDeSelectColor = titleDeSelectColor
        }
    }
    
    /// DisposeBack
    let disposeBack = DisposeBag()
    
    /// 현재 Delegate
    weak var delegate: CustomSegmentedControlDelegate?
    
    /// Segment의 Index
    var currentIndex: Int = 0
    
    
    /// 현재 선택된 배경 및 선택안된 배경이미지
    private var selectImage: UIImage? = nil
    private var nonSelectImage: UIImage? = nil
    
    /// TitleFont
    private var titleFont: UIFont? = nil
    
    
    /// Title Select Color, Title DeSelect Color
    private var titleSelectColor: UIColor? = nil
    private var titleDeSelectColor: UIColor? = nil
    
    /// 내부 선택 버튼(타이틀표시)
    private var buttons: [UIButton] = []
    
    /// Title옆에 표시 될 서브타이틀
    private var subTitles: [SubTitle] = []
    
    /// 버튼 타이틀 표시
    private var buttonTitles: [String]? = nil {
        didSet {
            guard let buttonTitles = self.buttonTitles else { return }
            subTitles.removeAll()
            
            // 버튼 셋팅 및 타이틀 셋팅
            let addBtn = { [weak self] (title: String, beforeBtn: UIView?) -> UIButton? in
                
                guard let self = self else { return nil }
                let button = UIButton()
                self.addSubview(button)
                    
                if let beforeBtn = beforeBtn {
                    button.snp.makeConstraints { make in
                        make.leading.equalTo(beforeBtn.snp_trailingMargin).offset(8)
                        make.top.equalTo(4)
                        make.bottom.equalTo(-4)
                        make.width.equalTo((self.frame.width/CGFloat(buttonTitles.count)) - CGFloat(4 * buttonTitles.count))
                    }
                    
                    button.setTitleColor(self.titleDeSelectColor, for: .normal)
                } else {
                    button.snp.makeConstraints { make in
                        make.top.equalTo(4)
                        make.leading.equalTo(6)
                        make.bottom.equalTo(-4)
                        make.width.equalTo((self.frame.width/CGFloat(buttonTitles.count)) - CGFloat(4 * buttonTitles.count))
                    }
                    
                    button.setTitleColor(self.titleSelectColor , for: .normal)
                }
                
                button.setTitle(title, for: .normal)
                button.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 16)
                button.borderRound(color: .clear, borderWidth: 0, cornerRadius: 25)
                
                return button
            }
            
            var beforeBtn: UIView? = nil
            buttonTitles.enumerated().forEach { [weak self] (index, title) in
                let btn = addBtn(title, beforeBtn)
                beforeBtn = btn
                guard let self = self, let superBtn = btn else { return }
                superBtn.tag = index
                self.buttons.append(superBtn)
                
                subTitles.append(SubTitle())
            }
            
            registerGestureView()
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addView()
    }
    
    // MARK: - Init
    
    /// Segment 초기화
    /// - Parameters:
    ///   - buttonTitles: Segment에 셋팅 될 Title
    ///   - selectImage: Segment에서 선택되었을때의 배경색
    ///   - backgroundColor: Segment의 기본 배경 색
    ///   - textFont: Segment의 Title Font
    ///   - selectTextColor: Segment에서 선택되었을때의 TextColor
    ///   - deSelectTextColor: Segment에서 선택되지 않았을때의 TextColor
    func initView(buttonTitles: [String],
                  selectImage: UIImage,
                  backgroundColor: UIColor = UIColor(red: 241, green: 241, blue: 241, alpha: 1.0),
                  textFont: UIFont = UIFont(name: "AppleSDGothicNeo-Bold", size: 16) ?? UIFont().withSize(16),
                  selectTextColor: UIColor = .black,
                  deSelectTextColor: UIColor = .red)
    {
        
        guard !buttonTitles.isEmpty else { return }
        self.selectImage = selectImage
        self.backgroundColor = backgroundColor
        self.nonSelectImage = backgroundColor.imageWithColor()
        self.titleFont = textFont
        self.titleSelectColor = selectTextColor
        self.titleDeSelectColor = deSelectTextColor
        self.buttonTitles = buttonTitles
        self.borderRound(color: .clear, borderWidth: 0, cornerRadius: 25)
    }
    
    
    /// SubTitle 셋팅
    /// - Parameters:
    ///   - index: 셋팅될 SubTitle의 Index
    ///   - subTitle: Subtitle
    ///   - textFont: Subtitle의 Font
    ///   - selectTextColor: Segment에서 선택되었을때의 TextColor
    ///   - deSelectTextColor: Segment에서 선택되지 않았을때의 TextColor
    func inputSubTitle(index: Int,
                       subTitle: String,
                       textFont: UIFont = UIFont(name: "AppleSDGothicNeo-Regular", size: 16) ?? UIFont().withSize(16),
                       selectTextColor: UIColor = .cyan,
                       deSelectTextColor: UIColor = .blue) {
        
        guard let btnTitles = self.buttonTitles, btnTitles.count > index else { return }
        var subTitleStruct = subTitles[index]
        subTitleStruct.setSubTitle(subTitle: subTitle,
                                   subTitleFont: textFont,
                                   titleSelectColor: selectTextColor,
                                   titleDeSelectColor: deSelectTextColor)
        
        subTitles[index] = subTitleStruct
        
        setSubTitle()
    }
    
    
    
    // MARK: - Private
    
    /// 제스처용 View 등록
    private func registerGestureView() {
        guard let firstBtn = self.buttons.first else { return }
        
        // 이미지 표시할 View 생성
        let backgroundView = UIImageView()
        self.insertSubview(backgroundView, belowSubview: firstBtn)
        backgroundView.snp.makeConstraints { make in
            
            make.top.equalTo(4)
            make.leading.equalTo(6)
            make.width.equalTo(firstBtn.snp.width)
            make.height.equalTo(firstBtn.snp.height)
        }
        backgroundView.image = self.selectImage
        backgroundView.borderRound(color: .clear, borderWidth: 0, cornerRadius: 25)
        
        
        // 제스처를 취할 View 생성
        let view = UIView()
        view.backgroundColor = .clear
        self.addSubview(view)
        view.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        // tap 제스처 (터치) 등록
        view.rx.tapGesture()
            .when(.recognized)
            .withUnretained(self)
            .subscribe(onNext: { (owner, gesture) in
                let location = gesture.location(in: owner)
                let index = Int(location.x/firstBtn.frame.width)
                owner.moveSelectView(view: backgroundView, index: index)
                
        }).disposed(by: disposeBack)

        // pan 제스처 (드래그) 등록
        view.rx.panGesture()
            .when(.began, .changed, .ended, .failed, .cancelled)
            .withUnretained(self)
            .subscribe(onNext: { (owner, gesture) in
                let location = gesture.location(in: owner)
                let index = Int(location.x/firstBtn.frame.width)
                owner.moveSelectView(view: backgroundView, index: index)
        }).disposed(by: disposeBack)
    }
    
    /// 제스처를 통해 이벤트를 취득할 View, 구독쪽으로 index보냄
    /// - Parameters:
    ///   - view: 에니메이션이 동작할 View
    ///   - index: 해당 Index
    private func moveSelectView(view: UIView, index: Int) {

        guard buttons.count > index, currentIndex != index else { return }
        currentIndex = index
        
        let btn = buttons[index]
        event(index: index, btn: btn)
        
        UIView.animate(withDuration: 0.1, animations: {
            view.frame.origin = CGPoint(x: btn.frame.origin.x, y: btn.frame.origin.y)
        })
    }
    
    /// 버튼이벤트 발생
    /// - Parameters:
    ///   - index: index
    ///   - btn: button
    private func event(index: Int, btn: UIButton) {
        setSubTitle()
        self.delegate?.selectIndex?(self, selectIndex: btn.tag)
    }
    
    
    /// 서브타이틀 셋팅
    private func setSubTitle() {
        
        buttons.enumerated().forEach { [weak self] (idx, button) in
            
            guard let self = self, let buttonTitles = self.buttonTitles else { return }
            let sub = self.subTitles[idx]
            let title = buttonTitles[idx] + " "
            
            let attributedString = NSMutableAttributedString()
            
            // 선택된 부분과 선택안된 부분의 색이 달라져야 함
            if let titleFont = self.titleFont, let titleSelectColor = self.titleSelectColor, let titleDeSelectColor = self.titleDeSelectColor {
                if currentIndex == idx {
                    attributedString.append(title.setAttributedStr(font: titleFont, color: titleSelectColor))
                    attributedString.append(sub.subTitle.setAttributedStr(font: sub.subTitleFont ?? titleFont, color: sub.titleSelectColor ?? titleSelectColor))
                } else {
                    attributedString.append(title.setAttributedStr(font: titleFont, color: titleDeSelectColor))
                    attributedString.append(sub.subTitle.setAttributedStr(font: sub.subTitleFont ?? titleFont, color: sub.titleDeSelectColor ?? titleDeSelectColor))
                }
            }
            button.setAttributedTitle(attributedString, for: .normal)
        }
    }
    
    
    
    /// 커스텀뷰를 호출할때 쓴다.
    private func addView() {
        let className = String(describing: type(of: self))
        let nib = UINib(nibName: className, bundle: Bundle.main)
        
        guard let xibView = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return }
        xibView.frame = self.bounds
        xibView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(xibView)
    }
    
    func selectIndex(_ view: UIView, selectIndex: Int) {
        
    }
}

@objc protocol CustomSegmentedControlDelegate: AnyObject {
    
    @objc optional func selectIndex(_ view: UIView, selectIndex: Int)
    
}

class RxCustomSegmentedControlDelegateProxy: DelegateProxy<CustomSegmentedControl, CustomSegmentedControlDelegate>, DelegateProxyType, CustomSegmentedControlDelegate {
    
    static func registerKnownImplementations() {
        self.register { (segmentView) -> RxCustomSegmentedControlDelegateProxy in
            RxCustomSegmentedControlDelegateProxy(parentObject: segmentView, delegateProxy: self)
        }
    }
    
    static func currentDelegate(for object: CustomSegmentedControl) -> CustomSegmentedControlDelegate? {
        object.delegate
    }
    
    static func setCurrentDelegate(_ delegate: CustomSegmentedControlDelegate?, to object: CustomSegmentedControl) {
        object.delegate = delegate
    }
    
    
}

extension Reactive where Base: CustomSegmentedControl {
    var delegate: DelegateProxy<CustomSegmentedControl, CustomSegmentedControlDelegate> {
        return RxCustomSegmentedControlDelegateProxy.proxy(for: self.base)
    }
    
    var selectChagne: Observable<Int> {
        
        return delegate.methodInvoked(#selector(CustomSegmentedControlDelegate.selectIndex(_:selectIndex:)))
            .map { paramater in
                guard paramater.count >= 2, let index = paramater[1] as? NSNumber else { return -1 }
                return index.intValue
        }
    }
}
