---
layout: post
title: "Ruby nezná symbol _i2d_ECPKParameters"
date: 2010-07-05 22:09
comments: true
categories:
---

Špatná instalace Ruby 1.8.7 - hlásí "Symbol not found: _i2d_ECPKParameters". Proč?

Chtěl jsem nainstalovat Ruby 1.8.7-p299 na MacbookPro se systémem Mac OS X Leopard 10.5.8. Stáhnul jsem zdrojáky z [www.ruby-lang.org](http://www.ruby-lang.org/en/news/2010/06/23/ruby-1-8-7-p299-released/) a kompiloval jsem obvyklým způsobem:

``` bash
./configure
make
sudo make install
```

Výsledkem bylo jinak funkční Ruby, do kterého šly úspěšně nainstalovat všechny potřebné Gemy. Problém nastal až v okamžiku, kdy jsem chtěl cokoliv spustit. Všechny knihovny závislé na OpenSSL nefungovaly. Samotné načtení openssl.rb totiž padalo s tímto hlášením:

```
irb(main):002:0> require "openssl.rb"
LoadError: dlopen(/Users/minarik/tmp/rubytest/lib/ruby/1.8/i686-darwin9.8.0/openssl.bundle, 9): Symbol not found: _i2d_ECPKParameters
  Referenced from: /Users/minarik/tmp/rubytest/lib/ruby/1.8/i686-darwin9.8.0/openssl.bundle
  Expected in: flat namespace
 - /Users/minarik/tmp/rubytest/lib/ruby/1.8/i686-darwin9.8.0/openssl.bundle
	from /Users/minarik/tmp/rubytest/lib/ruby/1.8/i686-darwin9.8.0/openssl.bundle
	from /Users/minarik/tmp/rubytest/lib/ruby/1.8/openssl.rb:17
	from (irb):2:in `require'
	from (irb):2
```

Na internetu se nedalo cokoliv najít a tak se chci podělit o svoje řešení.

Příčina chyby je dvojí:

1. Ruby 1.8.7 nefunguje s verzí OpenSSL menší než 0.9.8.
2. OpenSSL 0.9.8 se nezkompiluje správně, pokud máte nainstalovanou starší verzi.

Proč?

Proč Ruby nefunguje a nikde se o tom nepíše, to nevím. Ale OpenSSL se správně nezkompiluje vinou Applu. Jde o chybné chování funkce ld, což je funkce operačního systému pro nahrávání dynamických knihoven. Ta se chová podivně a v případě OpenSSL načte vždy lokální nainstalovanou verzi v /usr/lib místo té, která se právě vytvořila v rámci kompilace.

Řešení - otevřete adresář se zdrojovými kódy OpenSSL 0.9.8 a z něho proveďte následující tři kroky:

1. Přesuňte všechny soubory libcrypto a libssl z /usr/lib na nějaké jiné místo.
``` bash
  mkdir ~/tmp
  mkdir ~/tmp/openssl
  sudo mv /usr/lib/libcrypto* ~/tmp/openssl/
  sudo mv /usr/lib/libssl* ~/tmp/openssl/
```

2. Zkompilujte OpenSSL 0.9.8 jako dynamickou knihovnu. Já jsem kompiloval 32bitovou verzi kvůli kompatibilitě s MySQL Gemem.
``` bash
  ./configure --prefix=/usr darwin-i386-cc
  make
  make build-shared
```

3. Nyní vraťte původní soubory do /usr/lib a doplňte je nově zkompilovanými verzemi.
``` bash
  sudo cp ~/tmp/openssl/* /usr/lib/
  sudo cp lib*.dylib /usr/lib/</pre>
```

__POZOR! DŮLEŽITÉ!!!__
Ve chvíli, kdy dočasně přesunete libcrypto a libssl soubory, přestane fungovat systémová autentifikace, tedy například příkaz sudo! Vše musíte dokončit v limitu, po který po vás sudo nebude chtít znovu vložit heslo! Ideální je v jiném okně jednou za minutu spustit nějaký dummy sudo příkaz, například:
sudo ls

V případě, že limit překročíte a sudo po vás bude chtít heslo, už se nepřihlásíte a nebudete moci libcrypto a libssl soubory vrátit zpátky jinak než nabootováním instalačního CD a použitím jeho administrační konzole.
