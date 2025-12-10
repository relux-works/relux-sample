import AuthModels

extension Auth.Business.Model.BiometryType {
    public static func stub(allowed: Bool = true) -> Self {
        .face(allowed: allowed)
    }
}
