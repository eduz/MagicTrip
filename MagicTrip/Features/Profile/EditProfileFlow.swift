import SwiftUI

struct EditProfileFlow: View {
    let profile: TripProfile
    var vm: ChecklistViewModel
    var onClose: () -> Void

    var body: some View {
        OnboardingFlow(
            profile: profile,
            onFinish: { updated in
                vm.evaluate(profile: updated)
                onClose()
            },
            onCancel: onClose
        )
    }
}
