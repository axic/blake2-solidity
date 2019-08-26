pragma experimental ABIEncoderV2;

import "./Blake2b.sol";

contract Blake2bTest {
    using Blake2b for Blake2b.Instance;

    function testOneBlock(bytes memory input, uint input_len) public returns (bytes memory) {
        Blake2b.Instance memory instance = Blake2b.init(hex"", 64);
        return instance.finalize(input, input_len);
    }
}
