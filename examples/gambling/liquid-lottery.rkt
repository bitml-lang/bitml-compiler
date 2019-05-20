#lang bitml

(debug-mode)

(auto-generate-secrets)

(define (txA) "tx:02000000000101124327402f588c4b46cfa8b1670495bd9f6f57b969212af5b8afe5da191e349f0000000017160014ca98e2fc277b25dfe48db007419b4b6f7eff7cb2feffffff0205f717000000000017a914ffe4b939f7384b08ec04b2f605b0dca4413af16a87e0930400000000001976a914ded135b86a7ff97aece531c8b97dc8a3cb3ddc7488ac024730440220197c12bf078c2bbc8f86ce93cb42042e3d528ee62de5647c1827229fe9b809ef02205e6faf5a1af59aefe493055e2cdc9d435e3524bba1cc9179e343aa8ae311de30012102a0a9937b3273031c28c1c1c4f87d7d89e4d6f973bdb00e6447a708d2c91991b2cd271700@1")
(define (txB) "tx:02000000000101bb536c381e14e1edf2d460d2e0a9ed649da2b61733d0a5d101489c5ba7fba8400100000017160014023b9558d3736f47b3ff16dcb66800ae89fc681dfeffffff025c8c3e000000000017a9140cd0faeac9fd6f23f57e206d170cd9df909e9ac987e0930400000000001976a914ce07ee1448bbb80b38ae0c03b6cdeff40ff326ba88ac02473044022059ed91550240d9da58e3cef4dabc2b2719ce36c5e05a7af35c6c321fd914c5e70220149e461c53c155706ad6b27bf1f6b08f40a2ad3a2f4c23d41481df840caafce7012102407baf142709a99a67a19c6e9ea8af329e5b1cd6ba1d178f0a5fce3a94db8eb9e1271700@1")
(define (txFee) "tx:02000000000101cc1a7d72cd7c5f64d2e0f34a0f929532b11e18a0802a2cd9d2503fd60b19585e00000000171600149e7b7e6acb6c7d0b613bb3c72f55afc723686683feffffff0240420f00000000001976a914ce07ee1448bbb80b38ae0c03b6cdeff40ff326ba88acfedd33000000000017a914677fd79b9ab537dea966e328afa6fb27d8e9aa3b870247304402201bf5adf5fdea7f1939798fb5acd8a5e75aecddee47a0d101f1113ba5f4a28a3e02205461cd71f3e757d92a0d0635937a13e219508c1be7464473b717e92cf622d642012103fa6e338afbb1bd9ffe0abc107dc15eb38811babac4d2a67fa6b78a2bd38a0809e1271700@0")

(participant "A" "0339bd7fade9167e09681d68c5fc80b72166fe55bbb84211fd12bde1d57247fbe1")
(participant "B" "034a7192e922118173906555a39f28fa1e0b65657fc7f403094da4f85701a5f809")

(contract (pre
           (deposit "A" 0.003 (ref (txA)))(secret "A" a "b472a266d0bd89c13706a4132ccfb16f7c3b9fcb")
           (deposit "B" 0.003 (ref (txB)))(secret "B" b "c51b66bced5e4491001bd702669770dccf440982")
           (fee "B" 0.01 (ref (txFee))))
         
          (split
           (0.002 -> (choice
                  (revealif (b) (pred (between b 0 1)) (withdraw "B"))
                  (after 1500000 (withdraw "A"))))
           (0.002 -> (choice
                  (reveal (a) (withdraw "A"))
                  (after 1500000 (withdraw "B"))))
           (0.002 -> (choice
                  (revealif (a b) (pred (= a b)) (withdraw "A"))
                  (revealif (a b) (pred (!= a b)) (withdraw "B"))
                  (after 1500000 (split (0.001 -> (withdraw "A")) (0.001 -> (withdraw "B")))))))

          (check-liquid))