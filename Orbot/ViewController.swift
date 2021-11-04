//
//  ViewController.swift
//  Orbot
//
//  Created by Benjamin Erhart on 20.05.20.
//  Copyright © 2020 Guardian Project. All rights reserved.
//

import UIKit
import Tor

class ViewController: UIViewController {

    @IBOutlet weak var statusIcon: UIImageView!
    @IBOutlet weak var controlBt: UIButton!
    @IBOutlet weak var statusLb: UILabel!

    private static let nf: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .percent
        nf.maximumFractionDigits = 1

        return nf
    }()


    override func viewDidLoad() {
        super.viewDidLoad()

        let nc = NotificationCenter.default

        nc.addObserver(self, selector: #selector(updateUi), name: .vpnStatusChanged, object: nil)
        nc.addObserver(self, selector: #selector(updateUi), name: .vpnProgress, object: nil)

        updateUi()
    }


    // MARK: Actions

    @IBAction func changeConf() {
        switch VpnManager.shared.confStatus {
        case .notInstalled:
            VpnManager.shared.install()

        case .disabled:
            VpnManager.shared.enable()

        case .enabled:
            VpnManager.shared.disable()
        }
    }

    @IBAction func changeTransport() {
//        VpnManager.shared.switch(to: .init(rawValue: transportSc.selectedSegmentIndex) ?? .direct)
    }

    @IBAction func control() {

        // Enable, if disabled.
        if VpnManager.shared.confStatus == .disabled {
            VpnManager.shared.enable()
        }
        // Install first, if not installed.
        else if VpnManager.shared.confStatus == .notInstalled {
            return VpnManager.shared.install()
        }

        switch VpnManager.shared.sessionStatus {
        case .connected, .connecting:
            VpnManager.shared.disconnect()

        case .disconnected, .disconnecting:
            VpnManager.shared.connect()

        default:
            break
        }
    }


    // MARK: Observers

    @objc func updateUi(_ notification: Notification? = nil) {

        switch VpnManager.shared.sessionStatus {
        case .connected, .connecting:
            statusIcon.image = UIImage(named: "TorOn")
            controlBt.setTitle(NSLocalizedString("Stop", comment: ""))

        case .invalid:
            statusIcon.image = UIImage(named: "TorOff")
            controlBt.setTitle(NSLocalizedString("Install", comment: ""))

        default:
            statusIcon.image = UIImage(named: "TorOff")
            controlBt.setTitle(NSLocalizedString("Start", comment: ""))
        }

        if let error = VpnManager.shared.error {
            statusLb.text = error.localizedDescription
        }
        else if VpnManager.shared.confStatus != .enabled {
            statusLb.text = VpnManager.shared.confStatus.description
        }
        else {
            var progress = ""

            if notification?.name == .vpnProgress,
                let raw = notification?.object as? Float {

                progress = ViewController.nf.string(from: NSNumber(value: raw)) ?? ""
            }

            statusLb.text = [VpnManager.shared.sessionStatus.description, progress]
                .joined(separator: " ")
        }
    }
}
