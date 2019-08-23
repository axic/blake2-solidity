/*
 * Blake2b library in Solidity using EIP-152
 *
 * Copyright (C) 2019 Alex Beregszaszi
 *
 * License: Apache 2.0
 */

pragma experimental ABIEncoderV2;

library Blake2b {
    struct Instance {
        // This is a bit misleadingly called state as it not only includes the Blake2 state,
        // but every field needed for the "blake2 f function precompile".
        //
        // This is a tightly packed buffer of:
        // - rounds: 32-bit BE
        // - h: 8 x 64-bit LE
        // - m: 16 x 64-bit LE
        // - t: 2 x 64-bit LE
        // - f: 8-bit
        bytes state;
        // Expected output hash length. (Used in `finalize`.)
        uint out_len;
        // Data passed to "function F".
        // NOTE: this is limited to 24 bits.
        uint input_counter;
    }

    // Initialise the state with a given `key` and required `out_len` hash length.
    function init(bytes memory key, uint out_len)
        internal
        returns (Instance memory instance)
    {
        instance.out_len = out_len;

        // This is entire state transmitted to the precompile.
        // It is byteswapped for the encoding requirements, additionally
        // the IV has the initial parameter block 0 XOR constant applied, but
        // not the key and output length.
        instance.state = hex"0000000c08c9bdf267e6096a3ba7ca8485ae67bb2bf894fe72f36e3cf1361d5f3af54fa5d182e6ad7f520e511f6c3e2b8c68059b6bbd41fbabd9831f79217e1319cde05b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
        bytes memory state = instance.state;

        // Update parameter block 0 with key length and output length.
        uint key_len = key.length;
        assembly {
            let ptr := add(state, 36)
            let tmp := mload(ptr)
            let p0 := or(shl(240, key_len), shl(248, out_len))
            tmp := xor(tmp, p0)
            mstore(ptr, tmp)
        }

        // TODO: support salt and personalization

        if (key_len > 0) {
            update(instance, key, key_len);
        }
    }

    // This calls the blake2 precompile ("function F of the spec").
    // It expects the state was updated with the next block. Upon returning the state will be updated,
    // but the supplied block data will not be cleared.
    function call_function_f(Instance memory instance)
        private
    {
        bytes memory state = instance.state;
        assembly {
            let state_ptr := add(state, 32)
            if iszero(staticcall(not(0), 0x09, state_ptr, 0xd5, add(state_ptr, 4), 0x40)) {
                revert(0, 0)
            }
        }
    }

    // This function will split blocks correctly and repeatedly call the precompile.
    // NOTE: this is dumb right now and expects `data` to be 128 bytes long and padded with zeroes,
    //       hence the real length is indicated with `data_len`
    function update_loop(Instance memory instance, bytes memory data, uint data_len, bool last_block)
        private
    {
        bytes memory state = instance.state;
        uint input_counter = instance.input_counter;

        // This is the memory location where the "data block" starts for the precompile.
        uint state_ptr;
        assembly {
            // The `rounds` field is 4 bytes long and the `h` field is 64-bytes long.
            // Also adjust for the size of the bytes type.
            state_ptr := add(state, 100)
        }

        // This is the memory location where the input data resides.
        uint data_ptr;
        assembly {
            data_ptr := add(data, 32)
        }

        uint len = data.length;
        while (len > 0) {
            if (len >= 128) {
                assembly {
                    // FIXME: consider the little endian encoding required by the precompile here..
                    mstore(state_ptr, mload(data_ptr))
                    state_ptr := add(state_ptr, 32)
                    data_ptr := add(data_ptr, 32)

                    mstore(state_ptr, mload(data_ptr))
                    state_ptr := add(state_ptr, 32)
                    data_ptr := add(data_ptr, 32)

                    mstore(state_ptr, mload(data_ptr))
                    state_ptr := add(state_ptr, 32)
                    data_ptr := add(data_ptr, 32)

                    mstore(state_ptr, mload(data_ptr))
                    state_ptr := add(state_ptr, 32)
                    data_ptr := add(data_ptr, 32)
                }

                len -= 128;
                input_counter += 128;
            } else {
                // FIXME: implement support for smaller than 128 byte blocks
                revert();
            }

            input_counter = data_len;

            // Set length field (little-endian) for maximum of 24-bits.
            assembly {
                mstore8(add(state, 228), and(input_counter, 0xff))
                mstore8(add(state, 229), and(shr(8, input_counter), 0xff))
                mstore8(add(state, 230), and(shr(16, input_counter), 0xff))
            }

            // Set the last block indicator.
            assembly {
                // Writing byte 212 here.
                mstore8(add(state, 244), last_block)
            }

            // Call the precompile
            call_function_f(instance);
        }

        instance.input_counter = input_counter;
    }

    // Update the state with a non-final block.
    function update(Instance memory instance, bytes memory data, uint data_len)
        internal
    {
        update_loop(instance, data, data_len, false);
    }

    // Update the state with a final block and return the hash.
    function finalize(Instance memory instance, bytes memory data, uint data_len)
        internal
        returns (bytes memory output)
    {
        update_loop(instance, data, data_len, true);
        // FIXME: return ouput from state
        // It is the `out_len` bytes of `state.h` – but that is formatted as 64-bit little endian words,
        // while we want continuous output here.
        return instance.state;
    }
}
