//
//  IntroViewController.swift
//

import UIKit

class IntroViewController: UIViewController, UIScrollViewDelegate {
  
  //MARK: - Commons
  
  let LCK_DEFAULT_CORNER_RADIUS: Float = 5
  
  //MARK: - IBOutlet
  
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var pageControl: UIPageControl!
  
  @IBOutlet weak var signInButton: UIButton!
  @IBOutlet weak var signUpButton: UIButton!
  
  //MARK: - Property
  
  var guideImageViews: [UIImageView] = []
  var guideTitleViews: [UIImageView] = []
  
  var screenWidth: CGFloat = UIScreen.mainScreen().bounds.size.width
  
  let pageTotal: Int = 4
  var isRotating: Bool = false
  
  //MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()

    // setup button
    signInButton.layer.borderColor = UIColor.whiteColor().CGColor
    signInButton.layer.borderWidth = 1
    signInButton.layer.cornerRadius = CGFloat(LCK_DEFAULT_CORNER_RADIUS)
    
    signUpButton.layer.borderColor = UIColor.whiteColor().CGColor
    signUpButton.layer.borderWidth = 1
    signUpButton.layer.cornerRadius = CGFloat(LCK_DEFAULT_CORNER_RADIUS)
    
    
    // setup scrollView and images
    scrollView.pagingEnabled = true
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.delegate = self
    
    scrollView.contentSize = CGSizeMake(screenWidth * (CGFloat)(pageTotal), 0)
    
    pageControl.numberOfPages = pageTotal
    pageControl.currentPageIndicatorTintColor = UIColor.whiteColor()
    pageControl.pageIndicatorTintColor = UIColor(white: 1, alpha: 0.5)
    
    for index in 1...pageTotal {
      let width = screenWidth * (CGFloat)(index - 1)
      
      var guideImageView: UIImageView = UIImageView()
      guideImageView.image = UIImage(named: "ico_guide_\(index)")
      scrollView.addSubview(guideImageView)
      guideImageViews.append(guideImageView)
      
      guideImageView.setTranslatesAutoresizingMaskIntoConstraints(false)
      
      _addConstraintsTo(guideImageView: guideImageView, centerXConstant: width)
      
      var guideTitleView:UIImageView = UIImageView()
      let titleImageSuffix = NSLocalizedString("S_INTRO_TITLE_IMAGE_SUFFIX", comment: "en")
      guideTitleView.image = UIImage(named: "ico_guide_title_\(titleImageSuffix)_\(index)")
      scrollView.addSubview(guideTitleView)
      guideTitleViews.append(guideTitleView)
      
      guideTitleView.setTranslatesAutoresizingMaskIntoConstraints(false)
      
      _addConstraintsTo(guideTitleView: guideTitleView, guideImageView: guideImageView, centerXConstant: width)
      
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    // statusBar
    UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
  }
  
  override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
    isRotating = true
  }
  
  override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
    isRotating = false
    
    let screenWidth: CGFloat = UIScreen.mainScreen().bounds.width
    
    scrollView.contentSize = CGSizeMake(screenWidth * (CGFloat)(pageTotal), 0)
    self.scrollView.setContentOffset(CGPointMake(screenWidth * (CGFloat)(pageControl.currentPage), 0), animated: false)
    
    
    scrollView.removeConstraints(scrollView.constraints())
    
    for index in 0..<pageTotal {
      let width = screenWidth * (CGFloat)(index)
      
      var subView: UIView = scrollView.subviews[index] as! UIView
      
      var guideImageView: UIImageView = guideImageViews[index]
      
      _addConstraintsTo(guideImageView: guideImageView, centerXConstant: width)
      
      var guideTitleView: UIImageView = guideTitleViews[index]
      _addConstraintsTo(guideTitleView: guideTitleView, guideImageView: guideImageView, centerXConstant: width)
    }
  }
  
  func scrollViewDidScroll(scrollView: UIScrollView) {
    if !isRotating {
      let scrollViewWidth: CGFloat = scrollView.frame.size.width
      let x: CGFloat = scrollView.contentOffset.x
      let page: Int = Int((x + scrollViewWidth * 0.5) / scrollViewWidth)
      pageControl.currentPage = page
      
      animationDragged(scrollView)
    }
  }
  
  
  func _addConstraintsTo(#guideImageView: UIImageView, centerXConstant: CGFloat) {
    scrollView.addConstraint(NSLayoutConstraint(item: guideImageView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: scrollView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: centerXConstant))
    scrollView.addConstraint(NSLayoutConstraint(item: guideImageView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: scrollView, attribute: NSLayoutAttribute.CenterY, multiplier: 0.67, constant: 0))
  }
  
  func _addConstraintsTo(#guideTitleView: UIImageView, guideImageView: UIImageView, centerXConstant: CGFloat) {
    scrollView.addConstraint(NSLayoutConstraint(item: guideTitleView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: scrollView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: centerXConstant))
    scrollView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[guideImageView]-20-[guideTitleView]", options: NSLayoutFormatOptions(0), metrics: nil, views: ["guideImageView": guideImageView, "guideTitleView": guideTitleView]))
  }
  
  func animationDragged(scrollView: UIScrollView) {
    if scrollView.contentOffset.x < screenWidth / 4 {
      var position: CGPoint = scrollView.contentOffset
      var angle: CGFloat = position.x / (self.view.frame.size.width / 2) * CGFloat(M_PI_2)
      
      var alphaOne: CGFloat = 1 - position.x / (self.view.frame.size.width / 6)
      var alphaTwo: CGFloat = -position.x / (self.view.frame.size.width / 8)
      
      guideImageViews[0].alpha = position.x > 0 ? alphaOne : (1 - alphaTwo)
      guideImageViews[0].transform = CGAffineTransformMakeTranslation(-scrollView.contentOffset.x * 2, 0)
      
      var affineOne: CGAffineTransform = CGAffineTransformMakeTranslation(-scrollView.contentOffset.x * 2, 0)
      var affineTwo: CGAffineTransform = CGAffineTransformMakeRotation(angle)
      guideTitleViews[0].transform = CGAffineTransformConcat(affineOne, affineTwo)
    }
  }

}
