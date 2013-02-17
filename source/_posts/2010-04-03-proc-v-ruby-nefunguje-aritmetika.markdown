---
layout: post
title: "Proč v Ruby nefunguje aritmetika"
date: 2010-04-03 19:07
comments: true
categories:
---

(100 * 9.95).to_i v Ruby vrací výsledek 994. Jak je to možné? Lze vůbec Ruby komerčně nasadit?

Před pár dny mě na tenhle špek upozornil Petr Krontorád ([@aprilchild](http://twitter.com/aprilchild)) a protože se mě od té doby pár lidí ptalo, proč tomu tak je, dovolil jsem si na to téma menší zamyšlení.

## V čem je problém

Každý si to může jednoduše vyzkoušet. Jde o to, že zadáme-li do Ruby konzole příklad:

``` ruby
(100 * 9.95).to_i       # => 994
```

Povídali, že mu hráli. Samotný výpočet bez převodu na celé číslo přece funguje:

``` ruby
(100 * 9.95)         # => 995
```

Teď každého asi napadne: co když stejný kód pustíme jinde než v Ruby? Mnohé asi překvapí, že ostatní jazyky vrací zhola stejný výsledek.<br /> Java:

``` java
System.out.println((int)(100 * 9.95));   // => 994
```

PHP:

``` php
echo floor(100 * 9.95)   # => 994
```

V čem je tedy játro pudla?

## Proč to tak je

Float, to je prevít, ten vám rozbil počty. Není špatně odpověď, ale otázka. Pokusím se vysvětlit.

Všichni jsme zvyklí, že soustava, ve které je číslo zobrazeno, neovlivňuje jeho přesnost. Číslo 123 v desítkové soustavě odpovídá číslu 1111011. Každému asi jasné:

<cite>
1&#215;10<sup>2</sup> + 2&#215;10<sup>1</sup> + 3&#215;10<sup>0</sup> = 1&#215;2<sup>6</sup> + 1&#215;2<sup>5</sup> + 1&#215;2<sup>4</sup> + 1&#215;2<sup>3</sup> + 1&#215;2<sup>1</sup> + 1&#215;2<sup>0</sup>
</cite>

Není třeba dokazovat, že jde-li nějaké číslo složit ze součtu násobků 1, 10, 100, 1000, atd, půjde určitě složit také ze součtu násobků 1, 2, 4, 8, 16, 32, apod.

Problém ale nastane v okamžiku, kdy chceme převést číslo desetinné. To lze opět vyjádřit součtem mocnin desíti:

<cite>
10<sup>-1</sup>, 10<sup>-2</sup>, 10<sup>-3</sup>, 10<sup>-4</sup>... = 0.1, 0.01, 0.001, 0.0001...
</cite>

Ve dvojkové soustavě je samozřejmě rozvoj čísel za desetinnou čárkou vyjádřen mocninami dvou. To jsou ale o dost ošklivější čísla:

<cite>
2<sup>-1</sup>, 2<sup>-2</sup>, 2<sup>-3</sup>, 2<sup>-4</sup>, 2<sup>-5</sup>... = 0.5, 0.25, 0.125, 0.0625, 0.03125...
</cite>

A opět není potřeba důkazu na to, že určitě najdeme číslo v desítkové soustavě, které pomocí takových hausnumer vyjádřit nepůjde. Ano, například 9.95. To má totiž ve dvojkové soustavě za desetinnou čárkou nekonečný rozvoj, stejně jako v desítkové soustavě např. číslo 1/3. Ve dvojkové soustavě tedy:

<cite>
995 / 100 = 9.9499999...
</cite>

Převedeme-li toto na celé číslo oříznutím desetinné části (.to_i v Ruby, floor v PHP, (int) v Javě), dostaneme 994. Tím je záhada téměř vysvětlena.

## Proč ne vždy

Jestli je problém v desetinné části čísla 9.95, jakto, že na 0.95 vrací počítač výsledek správný?

``` ruby
(100 * 0.95).to_i    # => 95
```

Jak už jsme si řekli, některá desetinná čísla nelze převést na dvojková zcela přesně. Při převodu je nutné číslo aproximovat, neboli hledat nejbližší možné vyjádření pomocí mocnin dvou. Toto ale platí i obráceně, při převodu dvojkového čísla na desítkové.

Řekněme, že máme dvojkové číslo x coby výsledek našeho příkladu, číslo někde blízko 995, ale ne úplně přesně. Podíváme se, jakými desítkovými čísly bychom ho mohli aproximovat a jaká by byla odchylka od skutečné hodnoty x:

<pre>
   desítkové číslo         odchylka od x
  ====================================================
     994.99999999        -0.00000000386843...
     995.0               +0.00000000613154...
</pre>

Vybereme pochopitelně to z obou čísel, které je blíž, tj. má menší absolutní hodnotu odchylky. Tedy 994.99999999.

Pokud ale budeme mít v zadání 0.95 místo 9.95, pro výpočet můžeme využít 4 bity navíc, které jsme prve použili pro číslo 9. Naše výsledné dvojkové číslo x tedy bude o 4 bity přesnější. Tím bude o něco blíž číslu 95 a převede se tedy tak, jak jsme zvyklí ze základní školy.

## Závěr, jak tedy na to?

Nepřesnosti při operacích s desetinnou čárkou se vyhnout nelze. Co tedy mám dělat, když potřebuju řešit kritické operace s desetinnou čárkou, jako například jakékoliv finanční transakce, od košíku v e-shopu přes výpočet mezd?

Jak už jsem říkal, špatná není odpověď, nýbrž otázka. Každý ví, že 1/3 není v desítkové soustavě přesně určitelné číslo. Všichni s tím počítají a pochybuji, že někdy někde uvidíte smlouvu, ve které figuruje např. částka 1/3 milionu korun. Pokud je přesto takové číslo použito, dopředu se předpokládá, že bude nějak zaokrouhleno.

V desítkové soustavě zkrátka existují čísla, u kterých je nepřesnost obecně promíjena. Řešení je tedy více než prosté: omezme nepřesnost jen na tato čísla tak, že budeme výpočet provádět přímo v desítkové soustavě. K tomu slouží v Ruby i v Javě třída BigDecimal.

``` ruby
require "bigdecimal"
(BigDecimal.new("9.95") * 100).to_i       # => 995
```

Věřím, že tento problém asi nebyl pro mnohé překvapením a všichni minimálně tak nějak tuší, že peníze se neukládají ve floatu. Chtěl jsem probrat tuto věc do hloubky a srozumitelně, tak doufám, že mi odbornější čtenáři prominou vysvětlování zřejmého a případně mě doplní. Budu rád za dotazy a připomínky.