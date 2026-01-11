//
//  RoutineRowView.swift
//  Nunchuck Routine Tracker
//
//  Created by Max Rivera on 1/11/26.
//

import SwiftUI

struct RoutineRowView: View {
    let routine: Routine
    let onSuccess: () -> Void
    let onFailure: () -> Void
    
    private var successCount: Int {
        routine.attempts.filter { $0.isSuccess }.count
    }
    
    private var missCount: Int {
        routine.attempts.filter { !$0.isSuccess }.count
    }
    
    private var accuracy: Int {
        guard !routine.attempts.isEmpty else { return 0 }
        return Int((Double(successCount) / Double(routine.attempts.count)) * 100)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with name and accuracy
            HStack(alignment: .top, spacing: 12) {
                Text(routine.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(spacing: 8) {
                    if !routine.attempts.isEmpty {
                        HStack(spacing: 6) {
                            HStack(spacing: 2) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(.green)
                                Text("\(successCount)")
                                    .font(.title3.bold())
                                    .foregroundStyle(.white)
                                    .monospacedDigit()
                            }
                            
                            HStack(spacing: 2) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(.red)
                                Text("\(missCount)")
                                    .font(.title3.bold())
                                    .foregroundStyle(.white)
                                    .monospacedDigit()
                            }
                        }
                    }
                    Text("\(accuracy)%")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .monospacedDigit()
                }
                .fixedSize()
            }
            
            // Visual history bar
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    if routine.attempts.isEmpty {
                        Text("READY TO ROLL")
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(.secondary.opacity(0.3))
                    } else {
                        ForEach(Array(routine.attempts.suffix(20).enumerated()), id: \.offset) { _, attempt in
                            Image(systemName: attempt.isSuccess ? "checkmark" : "xmark")
                                .foregroundStyle(attempt.isSuccess ? .green : .red)
                                .font(.caption)
                                .fontWeight(.bold)
                        }
                    }
                }
            }
            
            // Action buttons - side by side
            HStack(spacing: 12) {
                Button {
                    onSuccess()
                } label: {
                    Label("Success", systemImage: "checkmark")
                        .font(.body.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.yellow)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                }
                .buttonStyle(.plain)
                
                Button {
                    onFailure()
                } label: {
                    Label("Miss", systemImage: "xmark")
                        .font(.body.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
                .stroke(Color(uiColor: .separator).opacity(0.3), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    let sampleRoutine = Routine(
        name: "Basic Spin",
        attempts: [
            Attempt(isSuccess: true),
            Attempt(isSuccess: true),
            Attempt(isSuccess: false),
            Attempt(isSuccess: true),
            Attempt(isSuccess: true),
            Attempt(isSuccess: true),
            Attempt(isSuccess: false),
            Attempt(isSuccess: true)
        ]
    )
    
    return RoutineRowView(
        routine: sampleRoutine,
        onSuccess: {},
        onFailure: {}
    )
    .padding()
    .background(Color(uiColor: .systemGroupedBackground))
    .preferredColorScheme(.dark)
}
