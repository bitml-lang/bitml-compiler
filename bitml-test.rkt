#lang bitml

(participant A @ "addressA")
(participant B @ "addressB")

(advertise (guards (deposit A 1 "txA@0")
                   (deposit A 1 "txA1@0")
                   (deposit B 2 "txB@0"))
           (withdraw B))