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
        if case let .tuple(tuple) = v {
            self.pair = (CLVMObject(v: tuple.0), CLVMObject(v: tuple.1))
            self.atom = nil
        }
        else {
            switch v {
            case .bytes(let bytes):
                self.atom = bytes
                self.pair = nil
                return
            case .object(let object):
                self.atom = object.atom
                self.pair = object.pair
                return
            case .list(let list):
                self.atom = nil
                if list.count != 2 {
//                    throw(ValueError("expected tuple"))
                    print("WARNING THIS SHOULD NEVER BE REACHED")
                } else {
                    self.pair = (CLVMObject(v: list[0]), CLVMObject(v: list[1]))
                }
                return
            case .sexp(let sexp):
                self.atom = sexp.atom
                self.pair = sexp.pair
            case .string(let string):
                self.atom = string.data(using: .utf8)
                self.pair = nil
            case .int(let int):
                self.atom = int_to_bytes(v: int)
                self.pair = nil
            case .g1(_):
                assert(false)
                self.atom = nil
                self.pair = nil
            case .tuple((_, _)):
                assert(false)
                self.atom = nil
                self.pair = nil
            }
        }
    }
}
