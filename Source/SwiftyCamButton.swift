/*Copyright (c) 2016, Andrew Walz.
 
 Redistribution and use in source and binary forms, with or without modification,are permitted provided that the following conditions are met:
 
 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 
 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS
 BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. */


import UIKit

//MARK: Public Protocol Declaration

public enum SwiftyCamButtonStyle {
    case tapPhotoLongVideo
    case tapVideoLongVideo
    case tapPhoto
    case longVideo
    case tapVideo

    var supportsLongVideo: Bool {
        switch self {
        case .tapPhotoLongVideo, .longVideo, .tapVideoLongVideo:
            return true
        default:
            return false
        }
    }
}

/// Delegate for SwiftyCamButton

public protocol SwiftyCamButtonDelegate: AnyObject {
    /// Sets the maximum duration of the video recording
    func setMaxiumVideoDuration() -> Double

    func shouldTakePhoto()
    func shouldToggleVideoRecording()
    func shouldStopVideoRecording()
}

// MARK: Public View Declaration


/// UIButton Subclass for Capturing Photo and Video with SwiftyCamViewController

open class SwiftyCamButton: UIButton {
    
    /// Delegate variable
    
    public weak var delegate: SwiftyCamButtonDelegate?
    
    // Sets whether button is enabled
    
    public var buttonEnabled = true

    public var buttonStyle: SwiftyCamButtonStyle = .tapPhotoLongVideo
    
    /// Maximum duration variable
    
    fileprivate var timer : Timer?
    
    /// Initialization Declaration
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        createGestureRecognizers()
    }
    
    /// Initialization Declaration

    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createGestureRecognizers()
    }
    
    /// UITapGestureRecognizer Function
    
    @objc fileprivate func Tap() {
        guard buttonEnabled == true else {
            return
        }

        switch buttonStyle {
        case .tapPhoto, .tapPhotoLongVideo:
            delegate?.shouldTakePhoto()
        case .tapVideo, .tapVideoLongVideo:
            delegate?.shouldToggleVideoRecording()
            handleTimer()
        default:
            break
        }
    }
    
    /// UILongPressGestureRecognizer Function
    @objc fileprivate func LongPress(_ sender:UILongPressGestureRecognizer!)  {
        guard buttonEnabled == true, buttonStyle.supportsLongVideo else {
            return
        }
        
        switch sender.state {
        case .began:
            delegate?.shouldToggleVideoRecording()
            startTimer()
        case .cancelled, .ended, .failed:
            invalidateTimer()
            delegate?.shouldStopVideoRecording()
        default:
            break
        }
    }
    
    /// Timer Finished
    
    @objc fileprivate func timerFinished() {
        invalidateTimer()
        delegate?.shouldStopVideoRecording()
    }

    private func handleTimer() {
        if timer != nil {
            invalidateTimer()
        } else {
            startTimer()
        }
    }
    
    /// Start Maximum Duration Timer
    
    fileprivate func startTimer() {
        if let duration = delegate?.setMaxiumVideoDuration() {
            //Check if duration is set, and greater than zero
            if duration != 0.0 && duration > 0.0 {
                timer = Timer.scheduledTimer(timeInterval: duration, target: self, selector:  #selector(SwiftyCamButton.timerFinished), userInfo: nil, repeats: false)
            }
        }
    }
    
    // End timer if UILongPressGestureRecognizer is ended before time has ended
    
    fileprivate func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // Add Tap and LongPress gesture recognizers
    
    fileprivate func createGestureRecognizers() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SwiftyCamButton.Tap))
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(SwiftyCamButton.LongPress))
        self.addGestureRecognizer(tapGesture)
        self.addGestureRecognizer(longGesture)
    }
}
