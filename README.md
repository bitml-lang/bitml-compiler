# bitml-compiler
Compiles BitML smart contracts to Bitcoin transactions.

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

`(key "participant-name" contract "public-key")`

#### Compiling contracts

A contract declaration adheres to the following structure:

```
(compile 
	(guards 
	   	guard
		...)        
    (sum 
    	contract
	...))
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
(after block-height contract)
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
	continuation-contract) 
```

The alternative forms are:

```
(put (vol-deposit-id ...)
	continuation-contract) 
```

```
(reveal (secret-id ...)
	continuation-contract) 
```

```
(revealif (secret-id ...) (pred predicate) 
	continuation-contract) 
```


###### Predicates

```

P,Q ::= true
	(and P Q)
        (not P)
        (= E F)
	(!= E F)
        (< E F)
	(<= E F)
```

```
E,F ::= number            
        (size secret-id)   
	(+ E F)
        (- E F)
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

(generate-keys)

(compile 
  (guards
  	(deposit "A" 1 "801db83ddf7bc0c4d028150974562002f5877a4fc9088e5574cc2a7b491a7931@0")			
	(secret a "df31a65089fe25501f7245a9c84740addf66dad2097bdee68c58f446245f6ffb"))

  (sum 
  	(reveal (a) (withdraw "A")) 
  	(after 600000 (withdraw "B"))))

```

The contract is a sum with two branches:

* The first one requires the secret `a` to be revealed, then `"A"` can withdraw the bitcoin in the contract.
* The second one requires the current block height to be greater than 600000, then `"B"` can withdraw the bitcoin in the contract.

