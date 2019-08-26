const Blake2bTest = artifacts.require('Blake2bTest.sol');
const TestVectors = require('./blake2ref/testvectors/blake2-kat.json');

contract('Blake2bTest', function (accounts) {
    let contract;

    before(async () => {
        contract = await Blake2bTest.new();
    });

    it('smoke', async () => {
        let ret = await contract.testOneBlock.call(Buffer.alloc(0), 0);
        assert.equal(ret, '0x48c9bdf267e6096a3ba7ca8485ae67bb2bf894fe72f36e3cf1361d5f3af54fa5d182e6ad7f520e511f6c3e2b8c68059b6bbd41fbabd9831f79217e1319cde05b', 'hash mismatch');
    });

    it('eip-152 test vector 5', async () => {
        let input = Buffer.from('6162630000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000', 'hex');
        let ret = await contract.testOneBlock.call(input, 3);
        assert.equal(ret, '0xba80a53f981c4d0d6a2797b69f12f6e94c212f14685ac4b74b12bb6fdbffa2d17d87c5392aab792dc252d5de4533cc9518d38aa8dbf1925ab92386edd4009923', 'hash mismatch');
    });

    it('blake2b reftest (8 bytes input)', async () => {
        let input = Buffer.from('0001020304050607000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000', 'hex');
        let ret = await contract.testOneBlock.call(input, 8);
        assert.equal(ret, '0xe998e0dc03ec30eb99bb6bfaaf6618acc620320d7220b3af2b23d112d8e9cb1262f3c0d60d183b1ee7f096d12dae42c958418600214d04f5ed6f5e718be35566', 'hash mismatch');
    });

    it('blake2b reftest (25 bytes input)', async () => {
        let input = Buffer.from('000102030405060708090a0b0c0d0e0f10111213141516171800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000', 'hex');
        let ret = await contract.testOneBlock.call(input, 25);
        assert.equal(ret, '0x54e6dab9977380a5665822db93374eda528d9beb626f9b94027071cb26675e112b4a7fec941ee60a81e4d2ea3ff7bc52cfc45dfbfe735a1c646b2cf6d6a49b62', 'hash mismatch');
    });

    it('blake2b reference test vectors', async () => {
        for (var i in TestVectors) {
            const testCase = TestVectors[i];
            if (testCase.hash !== 'blake2b' || testCase.key.length !== 0 || testCase.in.length > 128) {
                continue;
            }

            let input = Buffer.from(testCase.in, 'hex');
            let input_length = input.length;
            // Pad with zeroes.
            // FIXME: this should not be needed once the library is finished.
            if (input_length < 128) {
                input = Buffer.concat([input,  Buffer.alloc(128 - input_length)]);
            }

            let ret = await contract.testOneBlock.call(input, input_length);
            assert.equal(ret, '0x' + testCase.out, 'hash mismatch');
        }
    });
});
