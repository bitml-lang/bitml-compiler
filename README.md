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

`(participant "participant-name" "public-key")`

##### Declaring public keys

Each contract sub-term needs a public key for each participant.

`(key "participant-name" (contract) "public-key")`

#### Compiling contracts

A contract declaration adheres to the following structure:

```
(compile 
	(guards (guard)...)        
    (sum (contract) ...))
```

#### Guards

##### Persistent deposit

Defines a transaction to be used as deposit for the contract.

```
(deposit "participant-name" value "tx-id@output-number")
```

##### Volatile deposit

Defines a transaction to be used as volatile deposit for the contract,
i.e. a deposit to be authorized during the execution of the contract

```
(vol-deposit "participant-name" value deposit-id "tx-id@output-number")
```

##### Secrets

Defines a secret by committing its hash.

```
(secret secret-id "secret-hash")
```

#### Contracts

##### Withdraw

The participant can withdraw all the bitcoins in the contract.

```
(withdraw "participant-name")
```

##### Time locks

The continuation `contract` is enabled after `block-height`.

```
(after block-height _contract)
```

##### Authorization

The authorization of `"participant-name"` is required at runtime to execute 
the continuation `contract`.

```
(auth "part-name" contract)
```

##### Put *x, y, ...* and *a, b, ...* reveal if *predicate*

Used to unlock the volatile deposits *x, y, ...*, reveal the secrets *a, b, ...* that must satisfy the *predicate*.
All parameter are optional
(they can be replaced with empty pairs of parentheses)
but either the deposit or the secret must be specified. The predicate can only be specified together with a secret.

```
(putrevealif (vol-deposit-id ...) (secret-id ...) (pred predicate) 
	(sum 
    	(contract) 
        ...)) 
```

The continuation ```(sum (contract)... )``` is optional.

###### Predicates

```

P,Q ::= true
		(and P Q)
        (not P)
        E
```

```
E,F ::= number
		string
        secret-id
        (= E F)
        (< E F)
        (+ E F)
        (- E F)
        (size E)   
```

##### Split

```
(split
	(value (sum 
    		(contract) 
            ...) 
    ...)
```

Splits the current value of the contract between the continuations ```(sum (contract)... )```,
as instructed by each ```value```.


#### Examples

##### Timed commitment

```
#lang bitml

(participant "A" "029c5f6f5ef0095f547799cb7861488b9f4282140d59a6289fbc90c70209c1cced")
(participant "B" "034ad689068b553800500c7a741e055027680ed802a310357359fdf319de28ce87")

(key "A" (sum (putrevealif () (a) (withdraw "A")) (after 10 (withdraw "B"))) "03f2ccc71d33db5bec1cda1c9a3327d35f937faa25e0f2a14c62227034a43a2e23")
(key "B" (sum (putrevealif () (a) (withdraw "A")) (after 10 (withdraw "B"))) "021154731ef2173fa49097766c69103fcc94806b8b7de7b3b26fc7c658fbd30c3e")
(key "A" (putrevealif () (a) (withdraw "A")) "0209ca9e650d387ad3d958091fd5efd8aabfa29f9e5f2d83ccf50ee10accae521b")
(key "B" (putrevealif () (a) (withdraw "A")) "026285c32226a509439769d2ca795ed8df7c4c8dc79d79297651ce78a2a097252a")
(key "A" (after 10 (withdraw "B")) "03ab93ed8a7dee6ab74daf509273feab25f2ecd9104ff547a37f06829fdfb5da8a")
(key "B" (after 10 (withdraw "B")) "034068366d0221652c6354241e50ee06da58d5a85bed7128f048f5779cc80049a2")
(key "A" (withdraw "A") "020c75dfe83ed24316b1398412b1c32c5286566a3f6cf73b6422b9471c2e9ccbbe")
(key "B" (withdraw "A") "03d04f4db0148db7f069d01c0802ac0c533d5e04d87d7fb31cec8b2472f2e93d1c")
(key "A" (withdraw "B") "03b778745076527a76a5aa6e8e9f56ad38c5cba0800094bf9bbd4fb3739e367bff")
(key "B" (withdraw "B") "03f34c8dbb264c31672ef8372fb73d23c7ee44c0c0693ff765cf85f88ea9bc4a06")



(compile 
  (guards
  	(deposit "A" 1 "801db83ddf7bc0c4d028150974562002f5877a4fc9088e5574cc2a7b491a7931@0")			(secret a "df31a65089fe25501f7245a9c84740addf66dad2097bdee68c58f446245f6ffb"))

  (sum 
  	(putrevealif () (a) (withdraw "A")) 
  	(after 600000 (withdraw "B"))))

```

The contract is a sum with two branches:

* The first one requires the secret `a` to be revealed, then `"A"` can withdraw the bitcoin in the contract.
* The second one requires the current block height to be greater than 600000, then `"B"` can withdraw the bitcoin in the contract.

