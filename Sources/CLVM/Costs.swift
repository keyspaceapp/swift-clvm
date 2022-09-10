let IF_COST = 33
let CONS_COST = 50
let FIRST_COST = 30
let REST_COST = 30
let LISTP_COST = 19

let MALLOC_COST_PER_BYTE = 10

let ARITH_BASE_COST = 99
let ARITH_COST_PER_BYTE = 3
let ARITH_COST_PER_ARG = 320

let LOG_BASE_COST = 100
let LOG_COST_PER_BYTE = 3
let LOG_COST_PER_ARG = 264

let GRS_BASE_COST = 117
let GRS_COST_PER_BYTE = 1

let EQ_BASE_COST = 117
let EQ_COST_PER_BYTE = 1

let GR_BASE_COST = 498
let GR_COST_PER_BYTE = 2

let DIVMOD_BASE_COST = 1116
let DIVMOD_COST_PER_BYTE = 6

let DIV_BASE_COST = 988
let DIV_COST_PER_BYTE = 4

let SHA256_BASE_COST = 87
let SHA256_COST_PER_ARG = 134
let SHA256_COST_PER_BYTE = 2

let POINT_ADD_BASE_COST = 101094
let POINT_ADD_COST_PER_ARG = 1343980

let PUBKEY_BASE_COST = 1325730
let PUBKEY_COST_PER_BYTE = 38

let MUL_BASE_COST = 92
let MUL_COST_PER_OP = 885
let MUL_LINEAR_COST_PER_BYTE = 6
let MUL_SQUARE_COST_PER_BYTE_DIVIDER = 128

let STRLEN_BASE_COST = 173
let STRLEN_COST_PER_BYTE = 1

let PATH_LOOKUP_BASE_COST = 40
let PATH_LOOKUP_COST_PER_LEG = 4
let PATH_LOOKUP_COST_PER_ZERO_BYTE = 4

let CONCAT_BASE_COST = 142
let CONCAT_COST_PER_ARG = 135
let CONCAT_COST_PER_BYTE = 3

let BOOL_BASE_COST = 200
let BOOL_COST_PER_ARG = 300

let ASHIFT_BASE_COST = 596
let ASHIFT_COST_PER_BYTE = 3

let LSHIFT_BASE_COST = 277
let LSHIFT_COST_PER_BYTE = 3

let LOGNOT_BASE_COST = 331
let LOGNOT_COST_PER_BYTE = 3

let APPLY_COST = 90
let QUOTE_COST = 20
