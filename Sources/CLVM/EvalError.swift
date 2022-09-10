public struct EvalError: Error {
    public let sexp: SExp
    public let message: String?
    
    init(message: String, sexp: SExp) {
        self.sexp = sexp
        self.message = message
    }
}
