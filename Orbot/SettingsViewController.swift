//
//  SettingsViewController.swift
//  Orbot
//
//  Created by Benjamin Erhart on 08.03.22.
//  Copyright © 2022 Guardian Project. All rights reserved.
//

import UIKit
import Eureka

class SettingsViewController: BaseFormViewController {

	private let explanation1 = NSLocalizedString("Comma-separated lists of:", comment: "") + "\n"
		+ String(format: NSLocalizedString("%1$@ node fingerprints, e.g. \"%2$@\"", comment: ""), "\u{2022}", "ABCD1234CDEF5678ABCD1234CDEF5678ABCD1234") + "\n"
		+ String(format: NSLocalizedString("%1$@ 2-letter country codes in braces, e.g. \"%2$@\"", comment: ""), "\u{2022}", "{cc}") + "\n"
		+ String(format: NSLocalizedString("%1$@ IP address patterns, e.g. \"%2$@\"", comment: ""), "\u{2022}", "255.254.0.0/8") + "\n"

	private let explanation2 = String(format: NSLocalizedString("%1$@ Options need 2 leading minuses: %2$@", comment: ""), "\u{2022}", "--Option") + "\n"
		+ String(format: NSLocalizedString("%@ Arguments to an option need to be in a new line.", comment: ""), "\u{2022}") + "\n"
		+ String(format: NSLocalizedString("%1$@ Some options might get overwritten by %2$@.", comment: ""), "\u{2022}", Bundle.main.displayName)


	override func viewDidLoad() {
		super.viewDidLoad()

		navigationItem.title = NSLocalizedString("Settings", comment: "")

		closeBt.accessibilityIdentifier = "close_settings"

		form
		+++ LabelRow() {
			$0.value = NSLocalizedString("Settings will only take effect after restart.", comment: "")
			$0.cellStyle = .subtitle
			$0.cell.detailTextLabel?.numberOfLines = 0
		}

		+++ Section(NSLocalizedString("Node Configuration", comment: ""))

		<<< LabelRow() {
			$0.title = NSLocalizedString("Entry Nodes", comment: "")
			$0.value = NSLocalizedString("Only use these nodes as first hop. Ignored, when bridging is used.", comment: "")
			$0.cellStyle = .subtitle
			$0.cell.detailTextLabel?.numberOfLines = 0
		}

		<<< TextAreaRow() {
			$0.value = Settings.entryNodes
		}
		.onChange({ row in
			Settings.entryNodes = row.value
		})

		+++ LabelRow() {
			$0.title = NSLocalizedString("Exit Nodes", comment: "")
			$0.value = NSLocalizedString("Only use these nodes to connect outside the Tor network. You will degrade functionality if you list too few!", comment: "")
			$0.cellStyle = .subtitle
			$0.cell.detailTextLabel?.numberOfLines = 0
		}

		<<< TextAreaRow() {
			$0.value = Settings.exitNodes
		}
		.onChange({ row in
			Settings.exitNodes = row.value
		})

		+++ Section(footer: explanation1)

		<<< LabelRow() {
			$0.title = NSLocalizedString("Exclude Nodes", comment: "")
			$0.value = NSLocalizedString("Do not use these nodes. Overrides entry and exit node list. May still be used for management purposes.", comment: "")
			$0.cellStyle = .subtitle
			$0.cell.detailTextLabel?.numberOfLines = 0
		}

		<<< TextAreaRow() {
			$0.value = Settings.excludeNodes
		}
		.onChange({ row in
			Settings.excludeNodes = row.value
		})

		<<< SwitchRow() {
			$0.title = NSLocalizedString("Also don't use excluded nodes for network management", comment: "")
			$0.cell.textLabel?.numberOfLines = 0

			$0.cell.textLabel?.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
		}
		.onChange({ row in
			if let value = row.value {
				Settings.strictNodes = value
			}
		})

		+++ Section(NSLocalizedString("Advanced Tor Configuration", comment: ""))

		<<< ButtonRow() {
			$0.title = NSLocalizedString("Tor Configuration Reference", comment: "")
		}
		.onCellSelection({ cell, row in
			UIApplication.shared.open(URL(string: "https://2019.www.torproject.org/docs/tor-manual.html")!)
		})

		+++ MultivaluedSection(multivaluedOptions: [.Insert, .Delete], footer: explanation2) {
			$0.addButtonProvider = { _ in
				return ButtonRow()
			}

			$0.multivaluedRowToInsertAt = { [weak self] index in
				return TextRow() {
					$0.tag = String(index)

					self?.turnOffAutoCorrect($0.cell.textField)
				}
			}

			if let conf = Settings.advancedTorConf {
				var i = 0
				for item in conf {
					let r = $0.multivaluedRowToInsertAt!(i)
					r.baseValue = item
					$0 <<< r
					i += 1
				}
			}
			else {
				$0 <<< TextRow() {
					$0.tag = "0"

					turnOffAutoCorrect($0.cell.textField)

					$0.placeholder = "--ReachableAddresses"
					}
					<<< TextRow() {
						$0.tag = "1"

						turnOffAutoCorrect($0.cell.textField)

						$0.placeholder = "99.0.0.0/8, reject 18.0.0.0/8, accept *:80"
				}
			}
		}
	}


	// MARK: Private Methods

	 private func turnOffAutoCorrect(_ textField: UITextField) {
		 textField.autocorrectionType = .no
		 textField.autocapitalizationType = .none
		 textField.smartDashesType = .no
		 textField.smartQuotesType = .no
		 textField.smartInsertDeleteType = .no
	 }
}
