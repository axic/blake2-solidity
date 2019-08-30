# blake2-solidity

This is a Solidity library aiming to implement BLAKE2.

Currently it tries to only support BLAKE2B using the [EIP-152] precompile.

## Usage

It requires a recent go-ethereum develop version, since it uses the precompile.

Use the `geth-genesis.json`, run a local node and use `truffle test`.

1. Download and build `go-ethereum` commit `cc9eb91d30a5d4806154b832b9665aecc617b6d8`
2. To prepare, run `geth --datadir ./dataDir init ./geth-genesis.json`
3. To start the node `geth --port 4321 --networkid 1234 --datadir=./dataDir  --rpc --rpcport 8543 --rpcaddr 127.0.0.1  --rpcapi "eth,net,web3,personal,miner" --gasprice 0 --etherbase 0x627306090abab3a6e1400e9345bc60c78a8bef57 --mine`
4. Install prerequisite to truffle: `npm install --save truffle-hdwallet-provider`
4. And finally run `truffle test` to see tests succeed (or fail)

## References

- Official specification: https://blake2.net/blake2.pdf
- RFC7693 (contains a shorter, but less comprehensive description): https://tools.ietf.org/html/rfc7693
- Test vectors: https://github.com/BLAKE2/BLAKE2/tree/master/testvectors
- EIP-152 (Ethereum specific application): https://eips.ethereum.org/EIPS/eip-152

## Maintainer(s)

- Alex Beregszaszi [@axic]

## License

Apache-2.0

[EIP-152]: https://eips.ethereum.org/EIPS/eip-152
[@axic]: https://github.com/axic
