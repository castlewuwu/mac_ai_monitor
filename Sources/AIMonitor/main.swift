//
//  main.swift
//  AI Monitor
//
//  应用入口
//

import AppKit

let delegate = AppDelegate()
NSApplication.shared.delegate = delegate

_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)