//
//  BiometricAuthManager.swift
//  MONO
//
//  Created by Akash01 on 2025-08-22.
//

import Foundation
import LocalAuthentication
import SwiftUI

class BiometricAuthManager: ObservableObject {
    static let shared = BiometricAuthManager()
    
    @Published var isBiometricEnabled: Bool = false
    @Published var biometricType: LABiometryType = .none
    @Published var isAvailable: Bool = false
    @Published var errorMessage: String = ""
    
    private let context = LAContext()
    private let userDefaults = UserDefaults.standard
    private let biometricEnabledKey = "BiometricAuthEnabled"
    
    // Simulator support for testing
    var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
    
    init() {
        checkBiometricAvailability()
        loadBiometricPreference()
    }
    
    // MARK: - Biometric Availability Check
    func checkBiometricAvailability() {
        var error: NSError?
        
        // Check if biometric authentication is available
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            isAvailable = true
            biometricType = context.biometryType
            errorMessage = ""
        } else if isSimulator {
            // In simulator, even if canEvaluatePolicy fails, we can still simulate Face ID
            print("🔐 [BiometricAuth] Simulator detected - Face ID simulation will be available")
            isAvailable = true
            biometricType = .faceID
            errorMessage = ""
        } else {
            isAvailable = false
            biometricType = .none
            
            if let error = error {
                switch error.code {
                case LAError.biometryNotAvailable.rawValue:
                    errorMessage = "Biometric authentication is not available on this device"
                case LAError.biometryNotEnrolled.rawValue:
                    errorMessage = "No biometric data is enrolled. Please set up Face ID or Touch ID in Settings"
                case LAError.biometryLockout.rawValue:
                    errorMessage = "Biometric authentication is locked. Please use passcode to unlock"
                default:
                    errorMessage = "Biometric authentication is not available"
                }
            }
        }
    }
    
    // MARK: - Biometric Type Description
    var biometricTypeDescription: String {
        switch biometricType {
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        case .opticID:
            return "Optic ID"
        case .none:
            return "Biometric Authentication"
        @unknown default:
            return "Biometric Authentication"
        }
    }
    
    var biometricIcon: String {
        switch biometricType {
        case .faceID:
            return "faceid"
        case .touchID:
            return "touchid"
        case .opticID:
            return "opticid"
        case .none:
            return "lock.fill"
        @unknown default:
            return "lock.fill"
        }
    }
    
    // MARK: - Enable/Disable Biometric Authentication
    func enableBiometricAuth(completion: @escaping (Bool, String?) -> Void) {
        guard isAvailable else {
            completion(false, errorMessage)
            return
        }
        
        authenticateUser(reason: "Enable \(biometricTypeDescription) to securely access your account") { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    self?.isBiometricEnabled = true
                    self?.saveBiometricPreference(enabled: true)
                    completion(true, nil)
                } else {
                    completion(false, error)
                }
            }
        }
    }
    
    func disableBiometricAuth() {
        isBiometricEnabled = false
        saveBiometricPreference(enabled: false)
    }
    
    // MARK: - Authentication
    func authenticateUser(reason: String, completion: @escaping (Bool, String?) -> Void) {
        // Use the real LocalAuthentication framework even in simulator
        let context = LAContext()
        context.localizedFallbackTitle = "Use Passcode"
        
        // Add simulator-specific logging
        if isSimulator {
            print("🔐 [BiometricAuth] Simulator detected - triggering Face ID authentication")
            print("🔐 [BiometricAuth] Reason: \(reason)")
        }
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
            DispatchQueue.main.async {
                if self.isSimulator {
                    print("🔐 [BiometricAuth] Authentication result - Success: \(success)")
                    if let error = error {
                        print("🔐 [BiometricAuth] Error: \(error.localizedDescription)")
                    }
                }
                
                if success {
                    completion(true, nil)
                } else {
                    if let error = error as? LAError {
                        let errorMessage = self.getErrorMessage(for: error)
                        completion(false, errorMessage)
                    } else {
                        completion(false, "Authentication failed")
                    }
                }
            }
        }
    }
    
    // MARK: - Error Handling
    private func getErrorMessage(for error: LAError) -> String {
        switch error.code {
        case LAError.userCancel:
            return "Authentication was cancelled"
        case LAError.userFallback:
            return "User chose to use passcode"
        case LAError.systemCancel:
            return "Authentication was cancelled by system"
        case LAError.passcodeNotSet:
            return "Passcode is not set on the device"
        case LAError.biometryNotAvailable:
            if isSimulator {
                return "Face ID not available in simulator. Go to Device > Face ID > Enrolled in simulator menu"
            }
            return "Biometric authentication is not available"
        case LAError.biometryNotEnrolled:
            if isSimulator {
                return "Face ID not enrolled in simulator. Go to Device > Face ID > Enrolled in simulator menu"
            }
            return "Biometric authentication is not set up"
        case LAError.biometryLockout:
            return "Biometric authentication is locked"
        case LAError.authenticationFailed:
            if isSimulator {
                return "Face ID failed. In simulator, go to Device > Face ID > Matching Face to simulate success"
            }
            return "Authentication failed"
        case LAError.appCancel:
            return "Authentication was cancelled by app"
        case LAError.invalidContext:
            return "Authentication context is invalid"
        case LAError.notInteractive:
            return "Authentication is not interactive"
        default:
            return "Authentication failed with unknown error"
        }
    }
    
    // MARK: - UserDefaults Management
    private func saveBiometricPreference(enabled: Bool) {
        userDefaults.set(enabled, forKey: biometricEnabledKey)
    }
    
    private func loadBiometricPreference() {
        isBiometricEnabled = userDefaults.bool(forKey: biometricEnabledKey)
    }
    
    // MARK: - Quick Authentication Check
    func authenticateForQuickAccess(completion: @escaping (Bool) -> Void) {
        guard isBiometricEnabled && isAvailable else {
            completion(false)
            return
        }
        
        authenticateUser(reason: "Authenticate to access your account") { success, _ in
            completion(success)
        }
    }
}
