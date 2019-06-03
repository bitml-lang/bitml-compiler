#lang bitml

(participant "A" "0339bd7fade9167e09681d68c5fc80b72166fe55bbb84211fd12bde1d57247fbe1")
(participant "I" "034a7192e922118173906555a39f28fa1e0b65657fc7f403094da4f85701a5f809")

(debug-mode)

(define (txA) "tx:0200000001fbcee70062cab1cbe78f158851ee2351b3ce7d549201ac9f87c961225fb7ce4600000000e5483045022100fff909e25bcc800deebce554eb24b68080f2b02290b41076ad5cfb8b026453740220725b65455de27a643d74ac2deeccc3cb2bb3ba5c486bd19a2fc7c9034228e0f801483045022100fd976972a047c57e22b791c19d1ffdad25a9fb5240278cb923626d0285f6de0c02200820d34a98f7c7cc658412ec7053b3f14709ff86fd5b4532a46419181cfbbbaf014c516b6b006c766c766b7c6b5221034a7192e922118173906555a39f28fa1e0b65657fc7f403094da4f85701a5f809210339bd7fade9167e09681d68c5fc80b72166fe55bbb84211fd12bde1d57247fbe152aeffffffff011a760c00000000001976a914ded135b86a7ff97aece531c8b97dc8a3cb3ddc7488ac00000000@0")
(define (txFee) "tx:0200000001961c3539383d133a2d08606f2606b5db969a4a44e29f7e2e07cafcb95dc001fb00000000e347304402202960aa1cb055984f522b6ce3f0516c28bb1b732752edb8e2601651ac8bf178200220402b32a19d8be4fca5cb4e7b39a2ca9f3c08b9bb8aa7377929b83ae1dcc9acb10147304402207d34f6bb8690412560913a9f11e1cd4d1b37a9bb5dd1e877c8a46f062aa19bf002206da20009c6dc5ac2ff4a78550f7f0be6f61bc7a924770266602faff973fe2e0c014c516b6b006c766c766b7c6b5221034a7192e922118173906555a39f28fa1e0b65657fc7f403094da4f85701a5f809210339bd7fade9167e09681d68c5fc80b72166fe55bbb84211fd12bde1d57247fbe152aeffffffff01d5ea0600000000001976a914ded135b86a7ff97aece531c8b97dc8a3cb3ddc7488ac00000000@0")

;; parties agree to execute the Contract before t
(define (ExecuteBefore t Contract)
  (choice
   Contract
   (after t (split (0.00408333 -> (withdraw "A"))
                   (0.00408333 -> (withdraw "I"))))))

;; Part can choose at time t whether to execute Contract1 or Contract2
(define (AmericanOption Part t Contract1 Contract2)
  (choice
   (auth Part (tau (ref (ExecuteBefore t Contract1))))
   (auth Part (tau (ref (ExecuteBefore t Contract2))))))

(contract
 (pre (deposit "A" 0.00816666 (ref (txA)))
      (fee "A" 0.00453332 (ref (txFee))))
 
 (ref (AmericanOption "A" 1550000 (withdraw "A") (withdraw "I")))
 
 (check-liquid
  (strategy "A" (do-auth))))