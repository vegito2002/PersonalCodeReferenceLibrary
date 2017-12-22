# Analysis of Noise Protocol Framework
Team Members:
* Shiwe Weng  (wengshiwei@jhu.edu)
* Qiang Zhang (qzhang46@jhu.edu)

# 1. Noise Protocol Overview
Noise Protocol(Noise) is a framework based on `Diffie-Hellman(DH)` key agreement.

`Noise` has two phases, `handshake phase` and `transport phase`. In the former, two parties exchange DH public keys and perform a sequence of DH operations, hashing the DH results into a shared secret key incrementally, eventually resulting in a final shared secret that can be used to encrypt all traffic during subsequent `transport phase`. 

`Noise` supports handshakes where each party has a long-term `static key pair` and/or an `ephemeral key pair`. In terminology of `Noise`, `s` denotes a `static key` and `e` denotes an `ephemeral key`. `r` denotes a remote party, therefore `rs` and `re` denote such keys in remote party. Certain subtle semantic variations may apply when `r` is used in special occasions such as pattern name parameters etc. 

# 2. Noise Protocol Handshake
`Noise` use a `handshake pattern` to specify a handshake. Here is an example:

```
NN():
  -> e
  <- e, ee
```

This is just naive unauthenticated DH exchange protocol, but specified as a `Noise` pattern. 

In general, a `handshake pattern` consists of
- `pre-message pattern` for the initiator, indicating pre-shared secrecy from the initiator, before the `Noise` process starts. 
- `pre-message pattern` for the responder, indicating pre-shared secrecy from the responder, before the `Noise` process starts. 
- a sequence of `message pattern` for the actual handshake messages. The example above only consists two `message pattern`s.

One `message pattern` is a sequence of tokens chosen from, usually headed by either `->` or `<-`, and followed by sequence of token specifying the pattern content. The tokens can be:
* `e`: ephemeral public key sent in the message.
* `s`: static public key sent in the message, encrypted if at least one DH is performed already. 
* `ee`: perform one DH between the *initiator’s ephemeral* key pair and the *responder’s ephemeral* key pair. 
* `es`: perform one DH between the *initiator’s ephemeral* key pair and the *responder’s static* key pair. 
* `se`: perform one DH between the *initiator’s static* key pair and the *responder’s ephemeral* key pair. 
* `ss`: perform one DH between the *initiator’s static* key pair and the *responder’s static* key pair. 
* `psk`: special symbol to deal with 8*pre-shared symmetric key**. 

In the aforementioned example at the beginning of this section: 
- `-> e` is a `message pattern` for the initiator
- `<- e` is a `message pattern` for the responder
- `ee` is a `pattern token`. As explained above, a `pattern` consists of one or more `tokens`.

Incidentally, though not shown in action in the example above, it is worth mentioning that one `pre-message pattern` is usually one token chosen from (`e`, `s`, `e,s`, `empty`).  The arrow in front of the `pre-message pattern` itself denotes the direction of the particular `pre-message`:  `->` denotes one sent by the initiator, while `<-` denotes one from the responder. 

`pre-message` is in cleartext if no DH is performed before and no pre-knowledge of shared keys. Otherwise, `pre-message` is encrypted.

A `handshake pattern` has a name. `Noise` has predefined names for some one-way and interactive patterns. One-way patterns are named with *one* single character, which indicates the status of the sender's static key. Interactive patterns are named with *two* characters, which indicate the status of the initiator’s and responder's static keys respectively in order.

`N` means normal DH public-key encryption, therefore no static keys are shared before handshake. `K` means static key is `k`nown to the other party beforehand. `X` means static key is transmitted  to the other party. `Noise` mostly use `N` `K` `X` in names of one-way and interactive patterns.

Interactive patterns can use `I` as the first (the initiator’s) character, and that means initiator’s static public key immediately transmitted to responder.

After the two characters, the `pattern` name has a parameter form, in the form of  a list of tokens in parentheses indicating the pre-knowledge status of the initiator and the responder. Acceptable tokens as parameters are "s" "e" "e, s", "rs", "re", "re, rs". `zero-RTT encryption` (encrypted payload in the first message) uses this pre-knowledge of keys.

Back to our pre DH example:
* `NN()`: no pre-shared message for either party, indicated by the two `N` characters, and the empty parameter list.
* `-> e`: the initiator sends its own ephemeral public key in the first message.
* `<- e, ee`: the responder sends its own ephemeral public key to the initiator in the response. Since now either party possesses the ephemeral public key of the opponent, a DH between the two ephemeral key pairs is possible and thus is performed. Usually, this opens up the possibility of encryption in later handshake messages and transport messages.

# 3. Crypto Primitives
`Noise` itself is just a permissive framework, or a little language, that specifies the framework of actual communication protocols. To get one actual protocol, one has to instantiate `Noise` with concrete hash functions, encryption functions etc. Expectably, these argument functions has to adhere to certain requirements specified by `Noise`. 

`Noise` protocol define signatures for crypto primitives `DH functions`, `cipher functions` and `hash functions`. `Noise` provides implementation choices for these primitives. Encryption (`ENCRYPT(k, n, ad, plaintext)`) must be in Authenticated Encryption with Associated Data(`AEAD`) mode with associated data `ad`. Key Derivation Function (KDF, `HKDF`) is based on `hash functions`. It would be a better idea to the `Noise` documentation per se for the verbose version of these function definition requirements. Here, we provide these explanations in a more intuitive form as a typical workflow. 

# 4. Noise Protocol Workflow
```python
# For simplicity we omit `self` argument in function signature.
# All functions defined here are instance methods.

class CipherState:
    k # encryption key, 32 bytes or empty
    n # counter nouce, 8 bytes unsigned integer, unique to each k

    def InitializeKey(key):
        self.k = key
        self.n = 0

    def EncryptWithAd(ad, plaintext):
        if k is not None:
            return ENCRYPT(k, n++, ad, plaintext)
        else:
            return plaintext

    def DecryptWithAd(ad, ciphertext):
        if k is not None:
            return DECRYPT(k, n++, ad, ciphertext)
        else:
            return ciphertext

class SymmetricState:
    cipherState
    ck # a chaining key of HASHLEN bytes
    h  # a hash output of HASHLEN bytes

    def InitializeSymmetric(protocol_name):
        self.h = HASH(protocol_name ...)
        self.ck = h
        self.cipherState.InitializeKey(empty)

    def MixKey(input_key_material):
        self.ck, temp_k = HKDF(self.ck, input_key_material, 2)
        if HASHLEN == 64:
            temp_k = truncate(temp_k, 32)
        self.cipherState.InitializeKey(temp_k)
    
    def MixHash(data):
        self.h = HASH(h || data)

    def MixKeyAndHash(input_key_material):
        '''handle pre-shared symmetric keys'''
        self.ck, temp_h, temp_k = HKDF(self.ck, input_key_material, 3)
        self.MixHash(temp_h)
        if HASHLEN == 64:
            temp_k = truncate(temp_k, 32)
        self.cipherState.InitializeKey(temp_k)

    def EncryptAndHash(plaintext):
        ciphertext = cipherState.EncryptWithAd(h, plaintext)
        self.MixHash(ciphertext)
        return ciphertext

    def DecryptAndHash(ciphertext):
        plaintext = cipherState.DecryptWithAd(h, ciphertext)
        self.MixHash(ciphertext)
        return plaintext

    def Split():
        temp_k1, temp_k2 = HKDF(ck, zerolen, 2)
        if HASHLEN == 64:
            temp_k1 = truncate(temp_k1, 32)
            temp_k2 = truncate(temp_k2, 32)
        c1, c2 = new CipherState(), new CipherState()
        c1.InitializeKey(temp_k1)
        c2.InitializeKey(temp_k2)
        return c1, c2

class HandShakeState:
    symmetricState
    # DH public keys
    s  # local static key pair
    e  # local ephemeral key pair
    rs # remote static public key
    re # remote ephemeral public key
    # role variables
    initiator # a bool indicating the initiator or responder role
    message_patterns # a sub-sequence of ["e", "s", "ee", "es", "se", "ss", "psk"]

    def Initialize(handshake_pattern, initiator, prologue, s, e, rs, re):
        '''
        prologue: a byte sequence which may be zero-length, or which may contain context    information that both parties want to confirm is identical
        public keys are only passed in if the handshake_pattern uses pre-messages
        ephemeral values (e, re) are typically left empty
        '''
        protocol_name <- handshake_pattern, crypto_functions
        self.symmetricState.InitializeSymmetric(protocol_name)
        self.symmetricState.MixHash(prologue)
        self.initiator, self.prologue, self.s, self.e, self.rs, self.re = initiator, prologue, s, e, rs, re
        self.symmetricState.MixHash(useful pub keys <- handshake_pattern)
        handshake_pattern <- handshake_pattern

    # payload -> handshake message
    def WriteMessage(payload, message_buffer):
        next_message_pattern = pop(message_patterns)
        switch next_message_pattern:
            "e":
                e = GENERATE_KEYPAIR()
                message_buffer.append(e.public_key)
                symmetricState.MixHash(e.public_key)
            "s":
                message_buffer.append( symmetricState.EncryptAndHash(s.public_key) )
            "ee":
                symmetricState.MixKey(DH(e, re))
            "es":
                if self.initiator:
                    symmetricState.MixKey(DH(e, rs))
                else:
                    symmetricState.MixKey(DH(s, re))
            "se":
                if self.initiator:
                    symmetricState.MixKey(DH(s, re))
                else:
                    symmetricState.MixKey(DH(e, rs))
            "ss":
                symmetricState.MixKey(DH(s, rs))
        message_buffer.append( symmetricState.EncryptAndHash(payload) )
        
        if message_patterns.empty():
            return symmetricState.Split() # a pair of CipherState

    # handshake message -> payload
    def ReadMessage(message, payload_buffer):
        next_message_pattern = pop(message_patterns)
        switch next_message_pattern:
            "e":
                assert(re is None)
                re = pop(message, DHLEN)
                symmetricState.MixHash(re.public_key)
            "s":
                if symmetricState.cipherState.k is not None:
                    temp = pop(message, DHLEN + 16)
                else:
                    temp = pop(message, DHLEN)
                assert(rs is None)
                rs = symmetricState.DecryptAndHash(temp)
            "ee":
                symmetricState.MixKey(DH(e, re))
            "es":
                if self.initiator:
                    symmetricState.MixKey(DH(e, rs))
                else:
                    symmetricState.MixKey(DH(s, re))
            "se":
                if self.initiator:
                    symmetricState.MixKey(DH(s, re))
                else:
                    symmetricState.MixKey(DH(e, rs))
            "ss":
                symmetricState.MixKey(DH(s, rs))
        payload_buffer = symmetricState.DecryptAndHash(message) # remaining part of message

        if message_patterns.empty():
            return self.symmetricState.Split() # a pair of CipherState
```

Caveat is certain parts regarding error handling are omitted. During actual implementation, the programmer has to take extra caution to that part. 

We re-phrase `Noise` workflow using our Python-ish language above. `Noise` uses three objects with fields and methods: `HandshakeState`, `SymmetricState` and `CipherState`. A `HandshakeState` object contains a `SymmetricState` object. A `SymmetricState` object contains a `CipherState`. This hierarchy of composition makes the interaction between different functions easier to organize.

A `CipherState` object contains encryption key `k`, counter nonce  `n`, with encryption and decryption methods in `AEAD` mode. There is *one* such object alive during `handshake`, to handle necessary encryptions, including public static key encryption and handshake payload encryption. Two `CipherState` objects are produced at the termination of the `handshake` phase, and the commence of `transport` phase, to be used respectively by the two parties. Thus this type does serve two purposed throughout the entire communication process.

A `SymmetricState` object contains chaining hash key `ck` and hash output `h` . Both `ck` and `h` are updated frequently during the handshake, refer to the pseudocode above or the documentation for details. In a nutshell, `h` is a running hash of all handshake message contents (sent public keys and optional payloads), and `ck` is a running hash of all DH operation outputs. Each update to `ck` during the handshake also update the `k` used for handshake encryption, and the final `ck` is used to generate the two `k`s for two `CipherState` objects that would be used for the **transport** phase.  These methods call corresponding ones in the `CipherState` methods and update `h` with `ck`. `Split()` is used at the end of handshake to generate shared transport secrets.

A `HandshakeState` object contains DH variables `(s, e, rs, re)` and a variable for handshake pattern. It has `WriteMessage()` and `ReadMessage()` method that delegates to its instance of `SymmetricState`, and subsequently to `CipherState`.

Intuitively, each parties `Initialize()` a `HandshakeState` object. Then parties call `WriteMessage()` and `ReadMessage()` , which perform according to the `handshake pattern`. After dealing with all message patterns in the handshake, these functions will return two `CipherState` objects for the later `transport phase`.

# 5. Noise Protocol Workflow Example
`Handshake pattern` defines `message patterns`. `Message patterns` determines sequence of `WriteMessage()` and `ReadMessage()` in handshake. 

```
XX(s, rs):
  -> e
  <- e, ee, s, es
  -> s, se
```

An [illustration](https://noiseprotocol.org/docs/noise_stanford_seminar_2016.pdf):

<!-- <img src="http://i65.tinypic.com/28jd0y9.png" height="300"/> -->

The initiator and responder perform three DHs in handshake between two ephemeral keys (`ee`), the initiator's ephemeral key and responder's static key (`es`), initiator's static key and responder's ephemeral key (`se`). The pattern name `XX` means in the handshake, each party send its static key to the other party even before the handshake starts: they both *pre-shares* their own static public key.

This figure shows some typical `Noise` implementation. `h` is always updated after any message. After each DH, `ck` and `k` are generated by `HKDF()` and `n` is reset to `0`.

Also note how it is possible for the initiator to authenticate the responder from the second message: the fact that the initiator can decrypt the payload of the second message testifies to the message’s sender’s possession of the private key corresponding to `s` sent. 

# 6. Security Analysis
## 6.1 Overview
In `Noise`, the choice of `handshake pattern` largely determines security properties. Other factors include pattern validity, choice of crypto primitives, protocol implementation etc. We can instantiate a handshake pattern with `DH functions`, `cipher functions` and `hash functions` to give a concrete `Noise protocol`.

[Forward Security](https://en.wikipedia.org/wiki/Forward_secrecy)(FS) is a property of secure communication in which compromises of long-term keys does not compromise past session keys. FS protects past sessions against future compromises of secret keys[Wiki for FS](https://en.wikipedia.org/wiki/Forward_secrecy). `Noise` support FS in some handshake pattern.

Different protocol patterns lead to different security properties. The two major kinds of security property that we are concerned about, are **authentication** and **confidentiality**. `Noise` categorizes common levels of security properties achievable. 

For **authentication**:
- `0`: No authentication.
- `1`: Sender authentication vulnerable to key-compromise impersonation (KCI). The sender authentication is based on DH involving both parties' static key pairs. If the recipient's static key has been compromised, this authentication can be forged.
- `2`: Sender authentication resistant to key-compromise impersonation (KCI). The sender authentication is based on DH involving both sender's static key and the recipient's ephemeral key pair.

The key difference between `1` and `2` is whether the payload is being encrypted with the recipient's static key or ephemeral key. If authentication is done based on`ss`, compromise of the recipient’s private static key may enable an active attacker to forge any message without being detected by the recipient. But if the recipient’s private ephemeral key is used for the authentication instead, this compromise is no longer a serious danger. 

For **confidentiality**:
- `0`: No confidentiality. Payload is in cleartext.
- `1`: Encryption to an ephemeral recipient, 
- `2`: Encryption to a known recipient, forward secrecy for sender compromise only, vulnerable to replay.
- `3`: Encryption to a known recipient, weak forward secrecy.
- `4`: Encryption to a known recipient, weak forward secrecy if the sender's private key has been compromised.
- `5`: Encryption to a known recipient, strong forward secrecy.

The key difference between `2` and `3` is whether payload is encrypted with the recipient's static key or ephemeral key, similar to how level `1` and level `2`  is different in authentication. The similarities between `3` and `4` are they both use two DH based on ephemeral-ephemeral key pair and ephemeral-static key pair. However, in `3`'s second DH, recipient's keys are not verified by the sender, while in `4` these keys are verified by the sender. Confidentiality `5` is reached if recipient's static private key isn't stolen by an attacker.

For integrity, `Noise` ultimately use `CipherState.EncryptWithAd()` and `CipherState.DecryptWithAd()` to send and receive messages. In `handshake phase`, `ad` uses `h`, which is the running hash of each message. To forge a message without breaking authentication, an attacker will have to achieve the presumably impossible task of  breaking a hash function (`HMAC()` based on used hash function). This robustness does rely on the implementer’s caution on choosing the particular cryptographically secure hash function. 

## 6.2 Analysis of Handshake Patterns
### 6.2.1 Pattern Validity

`Noise` can describe many handshake patterns. A `Noise` pattern is `valid` if
1. Parties can only send a static public key if they were initialized with a static key pair, and can only perform DH between private keys and public keys they possess.
  * This is trivially required because you can’t send anything you don’t’ own.
2. Parties must not send their static public key or ephemeral public key more than once per handshake, including the pre-messages.
  * This seemingly arbitrary restriction is for transmission conciseness to the aid of ease of implementation and testing
3. After performing a DH between a remote public key and any local private key that is *not* the ephemeral private key, the local party must *not* call `ENCRYPT()` unless it has also performed a DH between the ephemeral private key and the remote public key. 
  * Subtle but critical requirement for the sake of Forward Secrecy. A `ee` DH is required before you use the result of a `es` DH’s results for encryption. The preliminary `ee` DH is to ensure randomization into `ck`, which will eventually be used as the transport shared secrecy. This randomization property is among `Noise`’s key strengths in the first place.  For example, `->e; <- s, es;`  followed by `ENCRYPT` would not be an acceptable pattern, while `->e;  <-e, ee, s, es;` is legitimate.

As in any cryptographic settings, home-brew is always dangerous. `Noise` itself arises for the purpose of limiting the design freedom that programmers are allowed to, thus reducing the possibilities for implementation errors. That being said, even the freedom regarding pattern design alone can be dangerous. `Noise` provides *recommended* one-way and interactive patterns. `Noise` also lists the security properties for these patterns. We take a few for example analyses.

## 6.3 Analysis of a One-way Pattern
```
N(rs):
  <- s
  ...
  -> e, es

Authentication: 0
Confidentiality: 2

K(s, rs):
  -> s
  <- s
  ...
  -> e, es, ss

Authentication: 1
Confidentiality: 2

X(s, rs):
  <- s
  ...
  -> e, es, s, ss

Authentication: 1
Confidentiality: 2
```

`One-way` means after handshake, only the sender(left party, using `->` in patterns) sends data to the recipient(right party, using `<-` in patterns). The recipient must not send any message. These patterns `N` `K` and `X` are three variants of DH. Intuitively, `N` is a conventional DH-based public-key encryption. The sender get the public key `s` from the recipient and perform a DH involving sender's ephemeral key and recipient public key. The other patterns add sender authentication. In `K`, sender's public key `s` is pre-shared. In `X`, sender's public key `s` is sent after a DH.

The **confidentiality** level is `2` for all of them. This means 
- 1. encryption to an known recipient
- 2. forward secrecy for sender compromise only
- 3. vulnerable to replay

Recipient is known because sender has pre-knowledge of recipient's static public key, therefore `1`. `2` is trivial since recipient won't send messages after handshake. These patterns are vulnerable to replay because the recipient doesn't provide ephemeral keys.

The **authentication** level is `0` for `N` and `1` for `K` and `X`. `0` is caused by no server authentication. `1` is caused by server authentication.

## 6.4 Analysis of an Interactive Pattern
```
XX(s, rs):
  -> e              A:0 C:0
  <- e, ee, s, es   A:2 C:1
  -> s, se          A:2 C:5
  <-                A:2 C:5
```

Let's analyze the most generically useful `XX` pattern as an example. In `XX`, parties first perform a DH on both ephemeral keys, then the recipient send its static public key using this shared key. They perform the second DH on the sender's ephemeral key and recipient’s static key. The sender sends its static key using this shared key, then perform the third DH on sender's static key and the recipient’s ephemeral key, to finish the handshake.

This handshake finally gain **authentication** level `2` and **confidentiality** level `5`. The idea of `XX` is to send static keys stepwise using a __better__ DH result. Authentication level is `2` because either side is authenticated by its static key and a DH on one side's static key and the other side's ephemeral key. Confidentiality level is `5`, which means
- 1. encryption to a known recipient
- 2. strong forward secrecy.

Strong forward secrecy is reached by the final DH on recipient ephemeral key. If the recipient's private key is compromised in the future, the attacker can never gain any information of this ephemeral key.

```
NN()
  -> e      A:0 C:0
  <- e, ee  A:0 C:1
  ->        A:0 C:1
```

Let's analyze this interactive pattern that is similar to a textbook DH. This DH is performed on both parties' ephemeral keys. There is no authentication, so the level is `0`. Payload is encrypted after DH but it's vulnerable to an active attack.

## 6.5 Other security problem discussion
### 6.5.1 Resistance to Downgrade Attack
TLS is vulnerable to `man-in-the-middle` downgrade attack even either party support strong ciphers. `Noise` hashes `protocol name` and `prologue` in the beginning of handshake. Each party must confirm their `prologue` are identical before next steps. This freedom to include pre-shared possibility into the handshake can securely rule out attacker’s downgrade attempts.

# 7. Comparison between Noise Pipe and TLS
`Noise pipe` is a TLS-like protocol. `Noise pipe` use three handshakes including
- 1. normal `full handshake`
- 2. `zero-RTT handshake`
- 3. `fallback handshake` when 2 fails

It's similar to TLS 1.2, where it support `normal handshake` and `resumption`.

```
=== figure: Noise Pipes === 
XX(s, rs):  
  -> e
  <- e, ee, s, es
  -> s, se

IK(s, rs):                   
  <- s                         
  ...
  -> e, es, s, ss          
  <- e, ee, se

XXfallback(e, s, rs):                   
  -> e
  ...
  <- e, ee, s, es
  -> s, se
=== figure: Noise Pipes === 
```

We have talked about workflow of `XX` in previous section. In `IK`, `I` means static key for initiator(right party, or `client` in TLS) `I`mmediately transmitted to responder(left party, or `server` in TLS), `K` means static key for initiator is `K`nown to responder. In this interaction, the initiator has pre-stored public key, thus it can encrypt payload in the first message (achieving `zero RTT`). 

If the recipient can decrypt this payload,  pre-stored key is still valid, After that, both parties perform a new series of DH to use new ephemeral keys. However, if the recipient fails to decrypt the payload, then the pre-stored key can no longer be trusted, and the recipient launches `XXfallback` handshake. `XXFallback` is almost the same as `XX`, except that the ephemeral key in the first message in `XXFallback` is generated in `IK`.

As for TSL1.2, here is a message flow from [RFC 5246 - The Transport Layer Security (TLS) Protocol Version 1.2](https://tools.ietf.org/html/rfc5246)
```
=== figure: TLS 1.2 ===
      Client                                               Server

      ClientHello                  -------->
                                                      ServerHello
                                                     Certificate*
                                               ServerKeyExchange*
                                              CertificateRequest*
                                   <--------      ServerHelloDone
      Certificate*
      ClientKeyExchange
      CertificateVerify*
      [ChangeCipherSpec]
      Finished                     -------->
                                               [ChangeCipherSpec]
                                   <--------             Finished
      Application Data             <------->     Application Data

             Figure 1.  Message flow for a full handshake
=== figure: TLS 1.2 ===
```

The [TLS Handshake Protocol](https://tools.ietf.org/html/rfc5246) involves the following steps:
1. Exchange hello messages to agree on algorithms, exchange random values, and check for session resumption.
2. Exchange the necessary cryptographic parameters to allow the client and server to agree on a premaster secret.
3. Exchange certificates and cryptographic information to allow the client and server to authenticate themselves.
4. Generate a master secret from the premaster secret and exchanged random values.
5. Provide security parameters to the record layer.
6. Allow the client and server to verify that their peer has calculated the same security parameters and that the handshake occurred without tampering by an attacker.

In TLS 1.2, if `check for session resumption` passes in step 1, the handshake is done, therefore it's `1 RTT`. In TLS 1.3 draft, payload is encrypted in the first message in handshake, which is `0 RTT` if check passes.

`Forward secrecy` in TLS is subtle, depending on the ciphers it used. While in `Noise`, if you use appropriate handshake patterns, you are guaranteed to at least weak Forward Secrecy, and sometimes even strong Forward Secrecy.

# 8. Miscellaneous
## 8.1 Subtleties in Specification
We believe that some levels in authentication and confidentiality in `Noise`'s specification are worth a little more discussion. The difference between authentication level `1` and `2` is to defend against the situation where the recipient’s static private key getting compromised. The differences in such properties might not entirely be from the nature of the design or implementation of patterns, but rather a combined implication of possible facts.  As shown in the documentation, proper implementation can achieve any of the three possible levels. 

It's the same case for confidentiality level `4` and `5`, where forward secrecy can be weak or strong depending on whether the recipient's static private key is secure. It’s not something that `Noise` itself can speaks strongly of.

## 8.2 Future extentions
Among crypto primitives, `Noise` hasn't use signature functions. In some patterns, sender verification is based on DH involving the sender's static private keys. It's vulnerable to some attacks if sender's private key is compromised. `Noise` might include signatures in a future version, but bring other trade-offs as brought up in the documentation. The details of such extensions and complications remains to be learned. But one can generally be ensured that extra complexity will be brought into the system, because more keys, more patterns, more handshake rounds might become necessitated. 

# 9. Summary
`Noise` is a secure protocol based on Diffie-Hellman key agreement. `Noise` can describe handshake protocols of various communication patterns. `WhatsApp`'s `Signal Protocol` shares the core ideas with `Noise`: Double Ratchet Algorithm, prekeys and a triple Diffie–Hellman (3-DH) handshake. `Noise` has suggestions and requirements for application responsibilities and cryptographic functions. A concrete and secure `Noise` protocol can come into shape with these suggestions properly taken into consideration during instantiation.

# 10. Reference
[The Noise Protocol Framework, Trevor Perrin (noise@trevp.net), Revision: 33, Date: 2017-10-04](http://noiseprotocol.org/noise.html)

[Video: The Noise Protocol Framework, by David Wong](https://cryptoservices.github.io/cryptography/protocols/2016/04/27/noise-protocol.html) 

[Slide for Noise Protocol Framework, Trevor Perrin](https://noiseprotocol.org/docs/noise_stanford_seminar_2016.pdf)

[Wiki for FS](https://en.wikipedia.org/wiki/Forward_secrecy)

https://en.wikipedia.org/wiki/Authenticated_encryption

https://en.wikipedia.org/wiki/Signal_Protocol#CITEREFUngerDechandBonneauFahl2015

[WhatsApp Security Whitepaper](https://www.whatsapp.com/security/WhatsApp-Security-Whitepaper.pdf)

Page 33, 35, The Transport Layer Security (TLS) Protocol Version 1.2 in [RFC5246](https://tools.ietf.org/html/rfc5246)

[Wiki for TLS](https://en.wikipedia.org/wiki/Transport_Layer_Security)

[An overview of TLS 1.3 and Q&A](https://blog.cloudflare.com/tls-1-3-overview-and-q-and-a/)

[Forward Secrecy](https://en.wikipedia.org/wiki/Forward_secrecy)