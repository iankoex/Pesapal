//
//  Problem4ViewModel.swift
//  Pesapal
//
//  Created by Ian on 31/01/2023.
//

import Combine
import SwiftUI

class Problem4ViewModel: ObservableObject {
    @Published var text: String = ""
    @Published var entries: [HistoryEntry] = []
    @Published var infoString: String? = nil
    private var variables: [Variable] = []
    private var timer: Timer?
    private var cancellables: [AnyCancellable] = []
    
    let operatorRegex: String = #"(?:(&&)|(\|\|))"#
    let equalSignRegex = #"(?:(=))"#
    let variablePrefixRegex = #"(?:(let)) \w+"#
    
    init() {
        $infoString
            .dropFirst()
            .sink { _ in
                self.scheduleTimer()
            }
            .store(in: &cancellables)
    }
    
    private var boolRegex: String {
        var openBoolRegex = #"(?:!(true)|!(false)|(true)|(false)"#
        for variable in variables {
            openBoolRegex += "|!(\(variable.name))|(\(variable.name))"
        }
        openBoolRegex += ")"
        return openBoolRegex
    }
    
    private var variableSuffixRegex : String {
        return "\(equalSignRegex) \(boolRegex)"
    }
    
    private var variableRegex : String {
        return "\(variablePrefixRegex) \(equalSignRegex) \(boolRegex)"
    }
    
    private var beforeOperatorRegex: String {
        "\(boolRegex) \(operatorRegex)"
    }
    
    private var afterOperatorRegex: String {
        "\(operatorRegex) \(boolRegex)"
    }
    
    private var unifiedRegex: String {
        "\(boolRegex) \(operatorRegex) \(boolRegex)"
    }
    
    func processText() {
        Task(priority: .userInitiated) {
            if text.match(by: unifiedRegex) {
                processLogicalOperators()
            } else if text.match(by: variableRegex) {
                processVariableInitialisation()
            } else {
                showError("Syntax Error. Check the documentation for Help")
            }
        }
    }
    
    private func processLogicalOperators() {
        let before = text.matchResult(by: beforeOperatorRegex)
        guard let beforeBool = getBoolFromString(before[0].trimmingOperators()) else {
            showError("Check the LHS")
            return
        }
        let after = text.matchResult(by: afterOperatorRegex)
        guard let afterBool = getBoolFromString(after[0].trimmingOperators()) else {
            showError("Check the RHS")
            return
        }
        let operatorStrArray = text.matchResult(by: operatorRegex)
        let operatorStr = operatorStrArray[0].trimmed()
        if let finalBool = evaluateBools(beforeBool, bool2: afterBool, using: operatorStr) {
            let entry = HistoryEntry(text: text, result: "\(finalBool)")
            insertEntry(entry)
        }
    }
    
    private func processVariableInitialisation() {
        let nameArray = text.matchResult(by: variablePrefixRegex)
        let name = nameArray[0].replacingOccurrences(of: "let", with: "").trimmed()
        let boolArray = text.matchResult(by: variableSuffixRegex)
        let boolStr = boolArray[0].replacingOccurrences(of: "=", with: "").trimmed()
        guard let bool = getBoolFromString(boolStr) else {
            showError("Check Everything")
            return
        }
        let variable = Variable(name: name, bool: bool)
        variables.append(variable)
        let text = "\(name) = \(bool)"
        let entry = HistoryEntry(text: text, result: "")
        insertEntry(entry)
    }
    
    private func evaluateBools(_ bool1: Bool, bool2: Bool, using operatorStr: String) -> Bool? {
        if operatorStr == "&&" {
            return bool1 && bool2
        } else if operatorStr == "||" {
            return bool1 || bool2
        } else {
            return nil
        }
    }
    
    private func getBoolFromString(_ str: String) -> Bool? {
        if str.contains(where: { $0 == "!" }) {
            let newStr = str.trimmingNOTOperator()
            guard let bool = getBoolFromString(newStr) else {
                return nil
            }
            return !bool
        } else {
            if str == "true" {
                return true
            } else if str == "false" {
                return false
            } else {
                if let variable = variables.first(where: { $0.name == str }) {
                    return variable.bool
                }
                return nil
            }
        }
    }
    
    private func insertEntry(_ entry: HistoryEntry) {
        DispatchQueue.main.async {
            withAnimation(.easeInOut) {
                self.entries.insert(entry, at: 0)
                self.infoString = entry.result.isEmpty ? entry.text : entry.result
            }
        }
    }
    
    private func showError(_ str: String) {
        let base = "Something went wrong. "
        DispatchQueue.main.async {
            withAnimation(.spring()) {
                self.infoString = base + str
            }
        }
    }
    
    private func scheduleTimer() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
            DispatchQueue.main.async {
                withAnimation(.easeInOut) {
                    self.infoString = nil
                }
            }
        }
    }
    
    @Published var helpText: String = """
        This is a Boolean Logic Interpreter. \n
        Getting Started
        - To initialise a variable:
                let someBool = true
                let someOtherBool = !true
        - To Evaluate using Logic Operators
        Use Swift standard logic operators
                • Logical NOT (!a)
                • Logical AND (a && b)
                • Logical OR (a || b)
        Use Swift standard Boolen types
                • true
                • false \n
        Examples:
        AND(&&) Examples
                true && true // true
                true && false // false
                true && !true // false read as true and not true
        OR(||) Examples
                true || true // true
                true || false // true
                false || false // false
                false || !false // true
        Variables Examples
                let someBool = true // true
                let someOtherBool = !true // false
                someBool && true // true, same as true && true
                !someBool && someOtherBool // false, same as false && false
                false || !someOtherBool // false, same as false || false
        """
}

fileprivate extension StringProtocol {
    func matchResult(
        by rawRegex: String,
        options: NSRegularExpression.Options = [.anchorsMatchLines]
    ) -> [String] {
        let text = String(self)
        if let regex = try? NSRegularExpression(pattern: rawRegex, options: options) {
            let matches = regex.matches(
                in: text,
                options: [],
                range: NSRange(text.startIndex..., in: text)
            )
            return matches.map { match in
                if let range = Range(match.range) {
                    let lowerBound = text.index(text.startIndex, offsetBy: range.lowerBound)
                    let upperBound = text.index(text.startIndex, offsetBy: range.upperBound)
                    return String(text[lowerBound..<upperBound])
                } else {
                    return "[ERROR] match error"
                }
            }
        } else {
            return [""]
        }
    }
    
    func match(
        by regexText: String,
        options: NSRegularExpression.Options = [.anchorsMatchLines]
    ) -> Bool {
        let text = String(self)
        if let regex = try? NSRegularExpression(pattern: regexText, options: options) {
            let matches = regex.matches(
                in: text,
                options: [],
                range: NSRange(text.startIndex..., in: text)
            )
            
            if matches.count == 1 && Range(matches.first!.range) == 0..<text.count {
                return true
            }
        }
        return false
    }
    
    func trimmed() -> String {
        self.trimmingCharacters(in: [" ", "\n"])
    }
    
    func trimmingOperators() -> String {
        self.trimmingCharacters(in: [" ", "\n", "&", "|"])
    }
    
    func trimmingNOTOperator() -> String {
        self.trimmingCharacters(in: ["!"])
    }
}

