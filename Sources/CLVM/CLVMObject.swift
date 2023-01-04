import Foundation

public protocol CLVMObjectProtocol {
    var atom: Data? { get }
    // this is always a 2-tuple of an object implementing the CLVM object
    // protocol.
    var pair: (CLVMObjectProtocol?, CLVMObjectProtocol?)? { get set }
}

#warning("hacky but should work alright")
extension CLVMObjectProtocol {
    func isEqual(_ obj: CLVMObjectProtocol?) -> Bool {
        if obj?.pair == nil && self.pair != nil {
            return false
        }
        
        if obj?.pair != nil && self.pair == nil {
            return false
        }
        
        if obj?.pair != nil && self.pair != nil {
            if obj!.pair?.0 != nil && self.pair?.0 == nil {
                return false
            }
            if obj!.pair?.1 != nil && self.pair?.1 == nil {
                return false
            }
            if !obj!.pair!.0!.isEqual(self.pair!.0) || !obj!.pair!.1!.isEqual(self.pair!.1)  {
                return false
            }
        }
        
        return obj?.atom == self.atom
    }
}

// This struct implements the CLVM Object protocol in the simplest possible way,
// by just having an "atom" and a "pair" field
public class CLVMObject: CLVMObjectProtocol {
    
    public let atom: Data?
    public var pair: (CLVMObjectProtocol?, CLVMObjectProtocol?)?
    
    static func new(v: CastableType) -> CLVMObjectProtocol {
        switch v {
        case .object(let object):
            return object
        default:
            return CLVMObject(v: v)
        }
        
    }

    public init(v: CastableType) {
        switch v {
        case .tuple(let tuple):
            // The python comments say the values in pair always conform to the clvm object protocol.
            // However, the type is declared as (Any, Any) and the code will pass through non clvm objects.
            // Adding `to_sexp_type` here converts the values to clvm objects. It adds some overhead
            // and may be incorrect but it resolves the undefined behavior and tests are passing.
            self.pair = try! (to_sexp_type(v: tuple.0), to_sexp_type(v: tuple.1))
            self.atom = nil
        case .bytes(let bytes):
            self.atom = bytes
            self.pair = nil
            return
        case .object(let object):
            self.atom = object.atom
            self.pair = object.pair
            return
        case .list(let list):
            if list.count != 2 {
//                throw(ValueError("expected tuple"))
                print("WARNING THIS SHOULD NEVER BE REACHED")
                precondition(false)
                self.atom = nil
                self.pair = nil
            } else {
                self.atom = nil
                self.pair = (CLVMObject(v: list[0]), CLVMObject(v: list[1]))
            }
        case .sexp(let sexp):
            self.atom = sexp.atom
            self.pair = sexp.pair
        case .string(let string):
            self.atom = string.data(using: .utf8)
            self.pair = nil
        case .int(let int):
            self.atom = int_to_bytes(v: int)
            self.pair = nil
        case .g1(let g1):
            self.atom = g1.get_bytes()
            self.pair = nil
        }
    }
}
