import AuthModels
import Relux

extension Auth.Business {
    public enum Effect: Relux.Effect { case authenticate }
}
