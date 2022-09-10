import Foundation
import BigInt

public func int_from_bytes<T>(blob: Data) -> T where T: SignedInteger {
    let size = blob.count
    if size == 0 {
        return 0
    }
    return T.from_bytes(blob, endian: .big, signed: true)
}

public func int_to_bytes<T>(v: T) -> Data where T: SignedInteger {
    if v == 0 {
        return Data()
    }
    let byte_count = (v.bitWidth + 8) >> 3
    var r = [UInt8](v.to_bytes(byte_count: byte_count, endian: .big, signed: true))
    // make sure the string returned is minimal
    // ie. no leading 00 or ff bytes that are unnecessary
    while r.count > 1 && r[0] == (r[1] & 0x80 != 0 ? 0xFF : 0) {
        r.removeFirst()
    }
    return Data(r)
}

/// Return the number of bytes required to represent this integer.
func limbs_for_int(v: BigInt) -> Int {
    return (v.bitWidth + 7) >> 3
}


public enum Endianness {
    case big
    case little
}

// These functions should have the same interface and behavior as the corresponding python methods
#warning("hacky, likely broken")
public extension SignedInteger {
    static func from_bytes<T>(_ bytes: Data, endian: Endianness, signed: Bool = false) -> T where T: SignedInteger {
        var signed = signed
        if signed {
            signed = bytes.first! >= 0x80
        }
        
        var bytes = bytes
        if endian == .big {
            bytes.reverse()
        }
        
        var carry: UInt8 = 1
        var accum: T = 0
        var accumbits: UInt = 0
        
        bytes.enumerated().forEach { (index, byte) in
            var thisbyte: UInt16 = UInt16(byte)
            if signed {
                thisbyte = (0xff ^ thisbyte) + UInt16(carry)
                carry = UInt8(thisbyte >> 8)
                thisbyte &= 0xff
            }
            
            accum |= T(thisbyte) << accumbits
            accumbits += 8
        }
        
        if signed {
            accum *= -1
        }
        
        return accum
    }

    func to_bytes(byte_count: Int, endian: Endianness, signed: Bool = false) -> Data {
        var bytes: [UInt8] = Array(repeating: 0, count: byte_count)
        let ndigits: Int
        let do_twos_comp: Bool
        
        #warning("a bit hacky but should work")
        var self_bytes: [UInt8] = []
        for word in self.words {
            self_bytes.append(contentsOf: word.bytes)
        }
        
        // trim trailing zero bytes to match python behavior
        while self_bytes.last == 0 {
            self_bytes.removeLast()
        }
        
        ndigits = self_bytes.count
        
        if self < 0  {
            assert(signed)
            if !signed {
                return Data()
            }
            do_twos_comp = true
        } else {
            do_twos_comp = false
        }
                
        var p: Int
        var pincr: Int
        if endian == .little {
            p = 0
            pincr = 1
        } else {
            p = byte_count - 1
            pincr = -1
        }
        
        assert(ndigits == 0 || self_bytes[ndigits - 1] != 0);
        var j = 0
        var accum: UInt16 = 0
        var accumbits: Int = 0
        var carry: UInt8 = 0
        for i in 0..<ndigits {
            var thisdigit: UInt8 = self_bytes[i]
            if do_twos_comp {
                thisdigit = (thisdigit ^ 0xff) + carry
                carry = thisdigit >> 8
                thisdigit &= 0xff
            }
            
            accum |= UInt16(thisdigit) << accumbits
            
            if i == ndigits - 1 {
                var s: UInt8 = do_twos_comp ? thisdigit ^ 0xff : thisdigit
                while (s != 0) {
                    s >>= 1
                    accumbits += 1
                }
            } else {
                accumbits += 8
            }
            
            while accumbits >= 8 {
                j += 1
                bytes[p] = UInt8(accum & 0xff)
                p += pincr
                accumbits -= 8
                accum >>= 8
            }
        }
        
        assert(accumbits < 8)
        assert(carry == 0)  /* else do_twos_comp and *every* digit was 0 */
        if (accumbits > 0) {
//            if (j >= byte_count) {
//                //goto Overflow;
//            }
            j += 1
            if (do_twos_comp) {
                /* Fill leading bits of the byte with sign bits
                   (appropriately pretending that the int had an
                   infinite supply of sign bits). */
                accum |= (~0) << accumbits
            }
            bytes[p] = UInt8(accum & 0xff)
            p += pincr
        }
        else if (j == byte_count && byte_count > 0 && signed) {
            /* The main loop filled the byte array exactly, so the code
               just above didn't get to ensure there's a sign bit, and the
               loop below wouldn't add one either.  Make sure a sign bit
               exists. */
            let msb: UInt8 = bytes[p - pincr]
            let sign_bit_set = msb >= 0x80
            assert(accumbits == 0)
            if (sign_bit_set == do_twos_comp) {
                return Data(bytes)
            }
            else {
                print("overflow")
//                goto Overflow;
            }
        }

        /* Fill remaining bytes with copies of the sign bit. */
        let signbyte: UInt8 = do_twos_comp ? 0xff : 0
        while j < byte_count {
            bytes[p] = signbyte
            j += 1
            p += pincr
        }
        
        return Data(bytes)
    }
}
