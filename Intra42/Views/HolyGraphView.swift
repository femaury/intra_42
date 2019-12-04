//
//  HolyGraphView.swift
//  Intra42
//
//  Created by Felix Maury on 2019-12-01.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit

class HolyGraphView: UIView {
    
    let label = UILabel()
    let borderView = UIView()
    
    weak var delegate: HolyGraphViewController?
    var shouldPassTouchesToNextView = false
    
    var id: Int = 0
    var kind: String = String()
    var state: String = String()
    var name: String = String()
    var duration: String = String()
    var cornerRadius: CGFloat {
        return kind == "piscine" ? 0 : self.frame.height / 2
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard shouldPassTouchesToNextView else {
            return super.point(inside: point, with: event)
        }
        return subviews.contains(where: {
          !$0.isHidden
          && $0.isUserInteractionEnabled
          && $0.point(inside: self.convert(point, to: $0), with: event)
        })
    }
    
    init(cursus: Int, id: Int, kind: String, state: String, position: CGPoint, title: String) {
        super.init(frame: .zero)
        self.id = id
        self.kind = kind
        self.state = state
        self.name = title
        
        frame = CGRect(origin: position, size: getViewSize(cursus))
        layer.cornerRadius = cornerRadius
        clipsToBounds = true
        backgroundColor = getBackgroundColor()

        borderView.isUserInteractionEnabled = false
        borderView.layer.borderWidth = 5
        borderView.layer.cornerRadius = cornerRadius
        borderView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        borderView.frame = bounds
        borderView.layer.borderColor = getBorderColor()
        
        label.numberOfLines = 0
        label.text = title
        label.font = label.font.withSize(14)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.textColor = .white
        label.sizeToFit()
        
        switch cursus {
        case 21:
            _init_cursus_21()
        default:
            _init_cursus_1()
        }
        
        addSubview(borderView)
        addSubview(label)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func _init_cursus_1() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
        if kind == "first_internship" || kind == "second_internship" {
            clipsToBounds = false
            backgroundColor = .clear
            borderView.layer.borderWidth = 10
            label.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
            label.center = CGPoint(x: bounds.maxX - bounds.maxX / 6.8, y: bounds.maxY - bounds.maxY / 6.8)
            label.layer.cornerRadius = 100
            label.layer.borderColor = getBorderColor()
            label.layer.borderWidth = 10
            label.backgroundColor = getBackgroundColor()
            label.layer.masksToBounds = true
            label.addGestureRecognizer(tapGesture)
            label.isUserInteractionEnabled = true
        } else {
            label.center = convert(center, from: label)
            addGestureRecognizer(tapGesture)
        }
    }
    
    private func _init_cursus_21() {
        // swiftlint:disable line_length
        let specialViews = ["ft_transcendance", "Exam Rank 06", "ft_containers", "Exam Rank 05", "webserv", "ft_irc", "Philosophers", "Exam Rank 04", "CPP Module 00", "CPP Module 01", "CPP Module 02", "CPP Module 03", "CPP Module 04", "CPP Module 05", "CPP Module 06", "CPP Module 07", "CPP Module 08", "libasm", "Exam Rank 03", "minishell", "ft_services", "ft_server", "Exam Rank 02", "cub3d", "miniRT", "netwhat", "ft_printf", "get_next_line"]
        // swiftlint:enable line_length
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
        if specialViews.contains(name) {
            clipsToBounds = false
            if name.contains("Exam") || name == "ft_printf" {
                backgroundColor = UIColor(hexRGB: "#041923")
                borderView.layer.borderWidth = 10
            } else {
                backgroundColor = .clear
                borderView.layer.borderWidth = 0
            }
            _setCursus21Labels()
            label.layer.borderColor = getBorderColor()
            label.layer.borderWidth = 5
            label.backgroundColor = getBackgroundColor()
            label.layer.masksToBounds = true
            label.addGestureRecognizer(tapGesture)
            label.isUserInteractionEnabled = true
            shouldPassTouchesToNextView = true
        } else {
            label.center = convert(center, from: label)
            addGestureRecognizer(tapGesture)
        }
    }
    
    // swiftlint:disable cyclomatic_complexity
    private func _setCursus21Labels() {
        if name == "ft_transcendance" {
            label.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
            label.center = CGPoint(x: bounds.maxX - 225, y: bounds.maxY - 365)
            label.layer.cornerRadius = 75
        } else if name.contains("Exam") {
            label.frame = CGRect(x: 0, y: 0, width: 120, height: 60)
            label.layer.cornerRadius = 30
        } else if name.contains("CPP") {
            if name.contains("08") {
                label.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
                label.layer.cornerRadius = 30
            } else {
                label.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
                label.layer.cornerRadius = 20
            }
        } else {
            label.frame = CGRect(x: 0, y: 0, width: 105, height: 105)
            label.center = CGPoint(x: bounds.maxX - bounds.maxX / 6, y: bounds.maxY - bounds.maxY / 7.6)
            label.layer.cornerRadius = 105 / 2
        }
        switch name {
        case "Exam Rank 06":
            label.center = CGPoint(x: bounds.maxX / 9, y: bounds.maxY / 5.5)
        case "Exam Rank 05":
            label.center = CGPoint(x: bounds.maxX, y: bounds.maxY / 2)
        case "Exam Rank 04":
            label.center = CGPoint(x: bounds.maxX / 2 + 300, y: bounds.maxY - 70)
        case "Exam Rank 03":
            label.center = CGPoint(x: bounds.maxX / 2 - 200, y: 50)
        case "Exam Rank 02":
            label.center = CGPoint(x: bounds.maxX / 7, y: bounds.maxY / 1.2)
        case "netwhat":
            label.center = CGPoint(x: bounds.maxX / 9.05, y: bounds.maxY / 5.45)
        case "ft_printf":
            label.center = CGPoint(x: bounds.maxX / 1.15, y: bounds.maxY / 5.45)
        case "get_next_line":
            label.center = CGPoint(x: bounds.maxX / 2 + 10, y: bounds.maxY - 10)
        case "miniRT":
            label.center = CGPoint(x: bounds.maxX - 45, y: bounds.maxY / 2 + 158)
        case "cub3d":
            label.center = CGPoint(x: bounds.maxX - 15, y: bounds.maxY / 2 + 60)
        case "ft_server":
            label.center = CGPoint(x: bounds.maxX / 2 - 80, y: 10)
        case "minishell":
            label.center = CGPoint(x: bounds.maxX / 2 + 200, y: bounds.maxY - 50)
        case "libasm":
            label.center = CGPoint(x: bounds.maxX - 50, y: bounds.maxY / 2 - 200)
        case "ft_services":
            label.center = CGPoint(x: 50, y: bounds.maxY / 2 + 200)
        case "Philosophers":
            label.center = CGPoint(x: 10, y: bounds.maxY / 2)
        case "CPP Module 08":
            label.center = CGPoint(x: bounds.maxX / 2 + 330, y: 90) // +80 +30
        case "CPP Module 07":
            label.center = CGPoint(x: bounds.maxX / 2 + 280, y: 135)
        case "CPP Module 06":
            label.center = CGPoint(x: bounds.maxX / 2 + 265, y: 90)
        case "CPP Module 05":
            label.center = CGPoint(x: bounds.maxX / 2 + 280, y: 40)
        case "CPP Module 04":
            label.center = CGPoint(x: bounds.maxX / 2 + 330, y: 25)
        case "CPP Module 03":
            label.center = CGPoint(x: bounds.maxX / 2 + 380, y: 40)
        case "CPP Module 02":
            label.center = CGPoint(x: bounds.maxX / 2 + 400, y: 90)
        case "CPP Module 01":
            label.center = CGPoint(x: bounds.maxX / 2 + 380, y: 135)
        case "CPP Module 00":
            label.center = CGPoint(x: bounds.maxX / 2 + 330, y: 160)
        case "ft_containers":
            label.center = CGPoint(x: 420, y: bounds.maxY - 120)
        case "webserv":
            label.center = CGPoint(x: 390, y: 140)
        case "ft_irc":
            label.center = CGPoint(x: 480, y: 90)
        default:
            break
        }
    }
    // swiftlint:enable cyclomatic_complexity
    
    func getViewSize(_ cursus: Int) -> CGSize {
        switch cursus {
        case 6, 12:
            return _getViewSizeCursus6()
        case 21:
            return _getViewSizeCursus21()
        default:
            return _getViewSizeCursus1()
        }
    }
    
    private func _getViewSizeCursus1() -> CGSize {
        switch kind {
        case "piscine":
            return CGSize(width: 170, height: 40)
        case "big_project":
            return CGSize(width: 130, height: 130)
        case "project":
            return CGSize(width: 105, height: 105)
        case "first_internship":
            return CGSize(width: 2000, height: 2000)
        case "second_internship":
            return CGSize(width: 4500, height: 4500)
        case "part_time":
            return CGSize(width: 300, height: 300)
        default:
            return CGSize(width: 150, height: 150)
        }
    }
    
    private func _getViewSizeCursus6() -> CGSize {
        switch kind {
        case "piscine":
            return CGSize(width: 170, height: 60)
        case "rush":
            return CGSize(width: 120, height: 60)
        default:
            return _getViewSizeCursus1()
        }
    }
    
    private func _getViewSizeCursus21() -> CGSize {
        switch name {
        case "ft_transcendance", "Exam Rank 06":
            return CGSize(width: 2000, height: 2000)
        case "ft_containers", "Exam Rank 05", "webserv", "ft_irc":
            return CGSize(width: 1680, height: 1680)
        case "Philosophers",
             "Exam Rank 04",
             "CPP Module 00",
             "CPP Module 01",
             "CPP Module 02",
             "CPP Module 03",
             "CPP Module 04",
             "CPP Module 05",
             "CPP Module 06",
             "CPP Module 07",
             "CPP Module 08":
            return CGSize(width: 1360, height: 1360)
        case "libasm", "Exam Rank 03", "minishell", "ft_services":
            return CGSize(width: 1040, height: 1040)
        case "ft_server", "Exam Rank 02", "cub3d", "miniRT":
            return CGSize(width: 720, height: 720)
        case "netwhat", "ft_printf", "get_next_line":
            return CGSize(width: 400, height: 400)
        default:
            return _getViewSizeCursus1()
        }
    }

    func getBorderColor() -> CGColor? {
        switch state {
        case "fail":
            return UIColor(hexRGB: "#CC6256")?.cgColor
        case "done":
            return Colors.intraTeal?.cgColor
        case "in_progress":
            return Colors.intraTeal?.cgColor
        case "available":
            return UIColor.white.cgColor
        default:
            return UIColor.gray.cgColor
        }
    }
    
    func getBackgroundColor() -> UIColor? {
        if state == "fail" { return UIColor(hexRGB: "#CC6256") }
        return state == "done" ? Colors.intraTeal : .darkGray
    }
    
    @objc func tapHandler(gesture: UIGestureRecognizer) {
        let name = label.text
        let showProjectAction = UIAlertController(title: name, message: nil, preferredStyle: .actionSheet)
        let showProfile = UIAlertAction(title: "Show Project", style: .default) { [weak self] (_) in
            guard let self = self else { return }
            self.delegate?.selectedProjectId = self.id
            self.delegate?.selectedProjectState = self.state
            self.delegate?.selectedProjectDuration = self.duration
            self.delegate?.performSegue(withIdentifier: "ProjectInfoSegue", sender: self.delegate)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        showProjectAction.addAction(showProfile)
        showProjectAction.addAction(cancel)
        
        delegate?.present(showProjectAction, animated: true, completion: nil)
    }
}
