module Lemmachine.Format.Request where
open import Data.Product
open import Lemmachine.Data hiding ([_])
open import Lemmachine.HTTP
open import Lemmachine.Format

Simple-Request-Format =
  str "GET" >>
  SP >>
  Base REQUEST-URI >>-
  CRLF >>
  End

Shared-Headers-Format : Format
Shared-Headers-Format =
  Optional-Header Pragma >>-
  Optional-Header Authorization >>-
  Optional-Header From >>-
  Optional-Header Referer >>-
  Optional-Header User-Agent >>-
  End

HEAD-Format : Format
HEAD-Format =
  Shared-Headers-Format >>-
  Disallow-Other-Headers >>
  CRLF >>
  End

GET-Format =
  Optional-Header If-Modified-Since >>-
  HEAD-Format

POST-Format : Format
POST-Format =
  Optional-Header Date >>-
  Shared-Headers-Format >>-
  Optional-Header Content-Encoding >>-
  Required-Header Content-Length >>= λ c-l →
  Required-Header Content-Type >>-
  Optional-Header Expires >>-
  Disallow-Other-Headers >>
  f (proj₁ c-l) (proj₁ (proj₂ c-l))
  where
  f : (s : Single Content-Length) → Header-Value (proj s) → Format
  f (single ._) n = CRLF >> Base (STR n)

Remaining-Format : Method → Format
Remaining-Format GET  = GET-Format
Remaining-Format HEAD = HEAD-Format
Remaining-Format POST = POST-Format

Full-Request-Format =
  Base METHOD >>= λ m →
  SP >>
  Base REQUEST-URI >>-
  SP >>
  Base VERSION >>-
  CRLF >>  
  Remaining-Format m

Request-Format =
  Full-Request-Format ∣ Simple-Request-Format

