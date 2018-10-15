# bitml-compiler
Compiles from BitML smart contracts to Bitcoin transactions.

BitML is a high-level language used to specify Bitcoin smart contracts, abstracting from transactions.
More at https://eprint.iacr.org/2018/122.pdf

## Installation

* Install [Racket](https://download.racket-lang.org/)
* Execute the following commands:

```bash
git clone https://github.com/bitml-lang/bitml-compiler.git
cd bitml-compiler
raco pkg install
```

## Tutorial

#### Definitions

BitML files start with

```racket
#lang bitml
```

followed by participants declarations and public keys declaration.

##### Declaring a participant

`(participant "A" "029c5f6f5ef0095f547799cb7861488b9f4282140d59a6289fbc90c70209c1cced")`

`"A"` is the participant name, followed by its public key.

##### Declaring public keys

Each contract sub-term needs a public key for each participant.

`(key "B" (withdraw "B") "027ae230e6f92cc9e96bf58ca9d46f454d2078a5246d29938ba7fb1fa2e2e7e599")`

`"B"` is the owner of the key, followed by the contract sub-term`(withdraw "B")`, and the public key.

#### Compiling contracts

A contract declaration adheres to the following structure:

```
(compile 
	(guards (guard)...)        
    (sum (contract) ...))
```

#### Guards

##### Persistent deposit

```
(deposit "A" 1 "801db83ddf7bc0c4d028150974562002f5877a4fc9088e5574cc2a7b491a7931@0")
```

`"A"` is the owner of the deposit, `1` is its value, and the last item is a transaction output in the form `tx-id@output-number`.

##### Volatile deposit

```
(deposit "B" 2 x "801db83ddf7bc0c4d028150974562002f5877a4fc9088e5574cc2a7b491a7931@1")
```

`"B"` is the owner of the volatile deposit, `2` is its value, `x` is the name of the deposit to be used in the rest of the contract, and the last item is a transaction output in the form `tx-id@output-number`.

##### Secrets

```
(secret a "df31a65089fe25501f7245a9c84740addf66dad2097bdee68c58f446245f6ffb")
```

`a` is the name of the secret to be used in the rest of the contract, followed by its hash.


