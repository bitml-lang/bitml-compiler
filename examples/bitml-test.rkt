#lang bitml

(participant "A" "029c5f6f5ef0095f547799cb7861488b9f4282140d59a6289fbc90c70209c1cced")
(participant "B" "02e76d1d57d47b549d9b297e0a3d71d69139cac2698eb1caa033c5e42322e833d8")

(generate-keys)

(define txA "txid:546abe624f7cdcc3c2411d012dbdfba7088f250c64c8065b68524c3ad4691a7a@0")

(contract
 (pre (deposit "A" 1 (ref txA)))         
 (withdraw "B"))

